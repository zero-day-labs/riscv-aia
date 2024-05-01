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
* NOTE 2:      This module is part of minimal APLIC. Our minimal APLIC implements only
*              two domains (M and S). From the AIA specification can be read (section 4.5):
*              "APLIC implementations can exploit the fact that each source is ultimately active 
*              in only one domain."
*              As so, this minimal version implements only one domain and relies on logic to mask 
*              the interrupt to the correct domain.
*/
module aplic_domain_notifier #(
    parameter int                                                   NR_DOMAINS      = 2,
    parameter int                                                   NR_SRC          = 32,
    parameter int                                                   NR_IDCs         = 1,
    parameter int                                                   MIN_PRIO        = 6,
    // MSI mode parameters
    parameter int unsigned                                          AXI_ADDR_WIDTH  = 64,
    parameter int unsigned                                          AXI_DATA_WIDTH  = 64,
    parameter unsigned                                              NR_VS_FILES_PER_IMSIC= 64'h1,
    parameter unsigned                                              IMSIC_M_ADDR_TARGET= 64'h24000000,
    parameter unsigned                                              IMSIC_S_ADDR_TARGET= 64'h28000000,
    // DO NOT EDIT BY PARAMETER
    parameter int                                                   NR_BITS_SRC     = (NR_SRC > 32) ? 32 : NR_SRC,
    parameter int                                                   NR_REG          = (NR_SRC-1)/32,
    parameter int                                                   IPRIOLEN        = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO)
) (
    input   logic                                                   i_clk           ,
    input   logic                                                   ni_rst          ,
    input   logic [NR_DOMAINS-1:0]                                  i_domaincfgIE   ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_setip_q       ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_setie_q       ,
    input   logic [NR_SRC-1:1][31:0]                                i_target_q      ,
    input   logic [NR_SRC-1:1]                                      i_intp_domain   
    `ifdef DIRECT_MODE
    /** interface for direct mode */
    ,input  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                i_idelivery     ,
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                i_iforce        ,
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0]       i_ithreshold    ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][25:0]               o_topi_sugg     ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     o_topi_update   ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     o_Xeip_targets  
    `elsif MSI_MODE
    /** interface for MSI mode */
    ,input  logic [NR_DOMAINS-1:0][31:0]                            i_genmsi         ,
    output  logic [NR_DOMAINS-1:0]                                  o_genmsi_sent    ,
    output  logic                                                   o_forwarded_valid,
    output  logic [10:0]                                            o_intp_forwd_id  ,
    output  ariane_axi::req_t                                       o_req            ,
    input   ariane_axi::resp_t                                      i_resp
    `endif
);

localparam TARGET_HART_IDX          = 18;
localparam TARGET_GUEST_IDX_MASK    = 64'h3F000;
localparam NR_IDC_W                 = (NR_IDCs == 1) ? 1 : $clog2(NR_IDCs);

`ifdef DIRECT_MODE
    
    logic [NR_DOMAINS-1:0][NR_IDCs-1:0]         has_valid_intp;
    logic [NR_DOMAINS-1:0][NR_IDC_W-1:0]        idc_index;
    logic [NR_DOMAINS-1:0][9:0]                 intp_id;
    logic [NR_DOMAINS-1:0][7:0]                 intp_prio;
    logic [NR_DOMAINS-1:0][IPRIOLEN-1:0]        prev_higher_prio;

    /** Detect highest pending-enabled interrut and notify the hart */
    always_comb begin
        /** internal signals reset values*/
        has_valid_intp      = '0;
        idc_index           = '0;
        intp_id             = '0;
        intp_prio           = '0;
        prev_higher_prio    = '1;
        /** outputs reset values */
        o_topi_sugg         = '0;
        o_topi_update       = '0;

        for (int i = 0; i < NR_DOMAINS; i++) begin
            /** Find the the highest pend. and en. intp per domain algorithm */
            for (int j = 1; j < NR_SRC; j++) begin
                /** Check if the interrupt is pending and enabled, active in the domain, 
                    and is also the higher (lower number) priority*/
                if (i_setip_q[j/32][j%32] && i_setie_q[j/32][j%32] &&
                    (i_intp_domain[j] == i[0]) &&
                    (i_target_q[j][IPRIOLEN-1:0] < prev_higher_prio[i][IPRIOLEN-1:0])) begin
                    intp_id[i]          = j[9:0];
                    intp_prio[i]        = i_target_q[j][7:0];
                    prev_higher_prio[i] = intp_prio[i][IPRIOLEN-1:0];
                    idc_index[i]        = i_target_q[j][TARGET_HART_IDX +: NR_IDC_W];
                end
            end

            /** Hart/IDC related logic */
            if (intp_id[i] != '0) begin
                /** Is the interrupt able to contribute to IDC interrupt? */
                if((intp_prio[i][IPRIOLEN-1:0] < i_ithreshold[i][idc_index[i]]) || 
                   (i_ithreshold[i][idc_index[i]] == 0)) begin
                    has_valid_intp[i][idc_index[i]] = 1'b1;
                    o_topi_sugg[i][idc_index[i]]    = {intp_id[i], 8'b0, intp_prio[i]};
                    o_topi_update[i][idc_index[i]]  = 1'b1;
                end
            end
        end 
    end

    /** CPU line logic*/
    for (genvar i = 0; i < NR_DOMAINS; i++) begin
        for (genvar j = 0; j < NR_IDCs; j++) begin
            assign o_Xeip_targets[i][j] =   i_domaincfgIE[i] & i_idelivery[i][j] & 
                                            (has_valid_intp[i][j] | i_iforce[i][j]);
        end
    end

`elsif MSI_MODE
    // signals from AXI 4 Lite
    logic [AXI_ADDR_WIDTH-1:0] addr_d, addr_q;
    logic [AXI_DATA_WIDTH-1:0] data_d, data_q;

    logic                      axi_busy, axi_busy_q;
    logic [10:0]               intp_forwd_id_d, intp_forwd_id_q;
    logic                      ready_i;
    logic                      forwarded_valid;
    logic [NR_DOMAINS-1:0]     genmsi_sent;
    logic [AXI_ADDR_WIDTH-1:0] base_addr_target;
    logic [AXI_ADDR_WIDTH-1:0] hart_addr_offset;

    always_comb begin : find_pen_en_intp
        ready_i             = '0;
        intp_forwd_id_d     = intp_forwd_id_q;
        forwarded_valid     = '0;
        genmsi_sent         = '0;
        data_d              = data_q;
        addr_d              = addr_q;
        base_addr_target    = '0;
        hart_addr_offset    = '0;

        for (int i = 1 ; i < NR_SRC ; i++) begin
            /** If the interrupt is pending and enabled in its domain*/
            if (i_setip_q[i/32][i%32] && i_setie_q[i/32][i%32] && i_domaincfgIE[i_intp_domain[i]] && !axi_busy_q) begin
                intp_forwd_id_d = i[10:0];
                data_d          = {{AXI_DATA_WIDTH-11{1'b0}}, i_target_q[i][10:0]};
                base_addr_target= (!i_intp_domain[i]) ? IMSIC_M_ADDR_TARGET : 
                                   IMSIC_S_ADDR_TARGET  + ({{AXI_ADDR_WIDTH-32{1'b0}}, i_target_q[i]} & TARGET_GUEST_IDX_MASK);
                hart_addr_offset= (!i_intp_domain[i]) ? {{AXI_ADDR_WIDTH-14{1'b0}}, i_target_q[i][31:18]} * 'h1000 : 
                                   {{AXI_ADDR_WIDTH-14{1'b0}}, i_target_q[i][31:18]} * 'h1000 * (NR_VS_FILES_PER_IMSIC + 'h1);
                addr_d          = base_addr_target + hart_addr_offset; 
                ready_i         = 1'b1;
                forwarded_valid = 1'b1;
            end
        end

        /** Lastly, check if genmsi wants to send a MSI*/
        for (int i = 0; i < NR_DOMAINS; i++) begin
            if (i_genmsi[i][12] && !axi_busy_q) begin
                intp_forwd_id_d = '0;
                data_d          = {32'b0, {21{1'b0}}, i_genmsi[i][10:0]};
                base_addr_target= (!i_intp_domain[i]) ? IMSIC_M_ADDR_TARGET : IMSIC_S_ADDR_TARGET  + ({{AXI_ADDR_WIDTH-32{1'b0}}, i_target_q[i]} & TARGET_GUEST_IDX_MASK);
                hart_addr_offset= (!i_intp_domain[i]) ? {{AXI_ADDR_WIDTH-14{1'b0}}, i_target_q[i][31:18]} * 'h1000 : 
                                   {{AXI_ADDR_WIDTH-14{1'b0}}, i_target_q[i][31:18]} * 'h1000 * (NR_VS_FILES_PER_IMSIC + 'h1);
                addr_d          = base_addr_target + hart_addr_offset; 
                genmsi_sent[i]  = 1'b1;
                ready_i         = 1'b1;
            end
        end
    end

    assign o_genmsi_sent        = genmsi_sent;
    assign o_forwarded_valid    = forwarded_valid;
    assign o_intp_forwd_id      = intp_forwd_id_q;

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
        .addr_i         ( addr_d            ),
        .data_i         ( data_d            ),
        .busy_o         ( axi_busy          ),
        .req_o          ( o_req             ),
        .resp_i         ( i_resp            )
    );

    always_ff @(  posedge i_clk, negedge ni_rst ) begin
        if (!ni_rst) begin
            axi_busy_q      <= '0;
            intp_forwd_id_q <= '0;
            data_q          <= '0;
            addr_q          <= '0;
        end else begin
            axi_busy_q      <= axi_busy;
            intp_forwd_id_q <= intp_forwd_id_d;
            data_q          <= data_d;
            addr_q          <= addr_d;
        end
    end
`endif

endmodule