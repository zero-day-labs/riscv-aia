/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*
* Description: This module can have two possible implementations, depending on the 
*              chosen delivery mode. Therefore, if the delivery mode is direct, the 
*              notifier will implement a basic algorithm to detect the highest-priority 
*              interrupt that is pending and enabled. If the chosen delivery mode is MSI, 
*              the notifier does not make any judgment regarding the priority of an interrupt 
*              (which is done in the IMSIC and RISC-V core), limiting itself to forwarding 
*              an interrupt as soon as it becomes pending and enabled.
*
* NOTE:        4.5.3 " For APLICs that support MSI delivery mode, it is recommended, 
*              if feasible, that the APLIC internally hardwire the physical addresses 
*              for all target IMSICs, putting those addresses beyond the reach of 
*              software to change"
*/
module aplic_domain_notifier #(
    parameter int                                   NR_SRC          = 32,
    parameter                                       MODE            = "DIRECT",
    parameter                                       APLIC           = "LEAF",
    parameter int                                   NR_IDCs         = 1,
    parameter int                                   NR_HARTs        = 1,
    parameter int                                   MIN_PRIO        = 6,
    parameter int unsigned                          AXI_ADDR_WIDTH  = 64,
    parameter int unsigned                          AXI_DATA_WIDTH  = 64,
    parameter unsigned                              IMSIC_ADDR_TARGET= 64'h24000000,
    parameter unsigned                              ID              = 4'b0001,
    // DO NOT EDIT BY PARAMETER
    parameter int                                   NR_BITS_SRC     = (NR_SRC > 32) ? 32 : NR_SRC,
    parameter int                                   NR_REG          = (NR_SRC-1)/32,
    parameter int                                   IPRIOLEN        = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO)
) (
    input   logic                                   i_clk           ,
    input   logic                                   ni_rst          ,
    input   logic                                   i_domaincfgIE   ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]       i_setip_q       ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]       i_setie_q       ,
    input   logic [NR_SRC-1:1][31:0]                i_target_q      ,
    `ifdef DIRECT_MODE
    /** interface for direct mode */
    input   logic [NR_IDCs-1:0][0:0]                i_idelivery     ,
    input   logic [NR_IDCs-1:0][0:0]                i_iforce        ,
    input   logic [NR_IDCs-1:0][IPRIOLEN-1:0]       i_ithreshold    ,
    output  logic [NR_IDCs-1:0][25:0]               o_topi_sugg     ,
    output  logic [NR_IDCs-1:0]                     o_topi_update   ,
    output  logic [NR_IDCs-1:0]                     o_Xeip_targets  
    `elsif MSI_MODE
    /** interface for MSI mode */
    input   logic [31:0]                            i_genmsi         ,
    output  logic                                   o_genmsi_sent    ,
    output  logic                                   o_forwarded_valid,
    output  logic [10:0]                            o_intp_forwd_id  ,
    output  logic                                   o_busy           ,
    output  ariane_axi::req_t                       o_req            ,
    input   ariane_axi::resp_t                      i_resp
    `endif
);

localparam DOMAINCFG_IE     = 8;
localparam TARGET_HART_IDX  = 18;
localparam TARGET_GUEST_IDX_MASK  = 64'h3F000;
localparam NR_IDC_W         = (NR_IDCs == 1) ? 1 : $clog2(NR_IDCs);
localparam NR_HART_W        = (NR_IDCs == 1) ? 1 : $clog2(NR_IDCs);

`ifdef DIRECT_MODE
    
    logic [NR_IDCs-1:0]         has_valid_intp_i;
    logic [NR_IDC_W-1:0]        hart_index_i;
    logic [IPRIOLEN-1:0]        prev_higher_i;

    /** Detect highest pending-enabled interrut and discover hart index*/
    always_comb begin
        prev_higher_i = 3'b111;
        has_valid_intp_i = '0;
        o_topi_sugg = '0;
        for (int i = NR_SRC-1 ; i > 0 ; i--) begin
            hart_index_i = i_target_q[i][TARGET_HART_IDX +: NR_IDC_W];
            /** If the interrupt is pending and enabled*/
            if (i_setip_q[i/32][i%32] && i_setie_q[i/32][i%32]) begin
                /** Is the interrupt able to contribute to IDC interrupt? */
                /** "interrupt sources with priority numbers P and higher DO NOT
                *   contribute to signaling interrupts to the hart" 
                *   If threshold is 0 all insterrupt can contribute 
                *   Finally, check if the current pend/en intp has a higher (smaller number)
                *   priority than the previous pend/en intp. */
                if(((i_target_q[i][2:0] < i_ithreshold[i_target_q[i][TARGET_HART_IDX +: NR_IDC_W]]) || 
                    (i_ithreshold[i_target_q[i][TARGET_HART_IDX +: NR_IDC_W]] == 0)) &&
                    (i_target_q[i][IPRIOLEN-1:0] < prev_higher_i[IPRIOLEN-1:0])) begin
                    has_valid_intp_i[hart_index_i] = 1'b1;
                    prev_higher_i                  = i_target_q[i][IPRIOLEN-1:0];
                    o_topi_sugg[hart_index_i]      = {i[9:0], 8'b0, i_target_q[i][7:0]};
                end
            end
        end 
    end

    /** Update outputs with IDC validation */
    for (genvar i = 0; i < NR_IDCs; i++) begin
        assign o_Xeip_targets[i] = i_domaincfgIE & i_idelivery[i] & 
                                   (has_valid_intp_i[i] | i_iforce[i]);
        assign o_topi_update[i]  = has_valid_intp_i[i];
    end

`elsif MSI_MODE
    // signals from AXI 4 Lite
    logic [AXI_ADDR_WIDTH-1:0] addr_i;
    logic [AXI_DATA_WIDTH-1:0] data_i;
    logic [10:0]               intp_forwd_id_d, intp_forwd_id_q;
    logic                      ready_i;
    logic                      genmsi_sent;
    logic                      axi_busy, axi_busy_q;
    logic [3:0]                id_i;

    assign id_i = ID;

    always_comb begin : find_highest_pen_en
        ready_i             = '0;
        genmsi_sent         = '0;
        intp_forwd_id_d     = intp_forwd_id_q;

        for (int i = 1 ; i < NR_SRC ; i++) begin
            /** If the interrupt is pending and enabled*/
            if (i_setip_q[i/32][i%32] && i_setie_q[i/32][i%32] && i_domaincfgIE && !axi_busy_q) begin
                intp_forwd_id_d = i[10:0];
                data_i          = {{64-11{1'b0}}, i_target_q[i][10:0]};
                addr_i          = IMSIC_ADDR_TARGET + ({{64-32{1'b0}}, i_target_q[i]} & TARGET_GUEST_IDX_MASK);
                ready_i         = 1'b1;
            end
        end

        /** Lastly, check if genmsi wants to send a MSI*/
        if (i_genmsi[12] && !axi_busy_q) begin
            intp_forwd_id_d = '0;
            data_i          = {32'b0, {21{1'b0}}, i_genmsi[10:0]};
            addr_i          = IMSIC_ADDR_TARGET + ({{64-32{1'b0}}, i_target_q[i_genmsi[10:0]]} & TARGET_GUEST_IDX_MASK);
            genmsi_sent     = 1'b1;
            ready_i         = 1'b1;
        end
    end

    assign o_genmsi_sent        = genmsi_sent;
    /** the intp is considered forwarded when the axi interface becomes available again */
    assign o_forwarded_valid    = axi_busy_q & ~axi_busy;
    assign o_intp_forwd_id      = intp_forwd_id_q;
    assign o_busy               = axi_busy;

    // -----------------------------
    // AXI Interface
    // -----------------------------
    axi_lite_write_master#(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH    )
    ) axi_lite_write_master_i (
        .clk_i          ( i_clk             ),
        .rst_ni         ( ni_rst            ),
        .ready_i        ( ready_i           ),
        .id_i           ( id_i              ),
        .addr_i         ( addr_i            ),
        .data_i         ( data_i            ),
        .busy_o         ( axi_busy          ),
        .req_o          ( o_req             ),
        .resp_i         ( i_resp            )
    );

    always_ff @(  posedge i_clk, negedge ni_rst ) begin
        if (!ni_rst) begin
            axi_busy_q      <= '0;
            intp_forwd_id_q <= '0;
        end else begin
            axi_busy_q      <= axi_busy;
            intp_forwd_id_q <= intp_forwd_id_d;
        end
    end

`endif

endmodule