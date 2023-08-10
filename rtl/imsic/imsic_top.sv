/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
* 
* Description: Implements the IMSIC IP; 
*               
*/ 
module imsic_top #(
   parameter int                                    NR_SRC           = 32   ,
   parameter int                                    MIN_PRIO         = 6    ,
   parameter int                                    NR_INTP_FILES    = 2    ,
   parameter int unsigned                           AXI_ADDR_WIDTH   = 64   ,
   parameter int unsigned                           AXI_DATA_WIDTH   = 64   ,
   parameter int unsigned                           AXI_ID_WIDTH     = 10   ,
   parameter type                                   axi_req_t        = ariane_axi::req_t ,
   parameter type                                   axi_resp_t       = ariane_axi::resp_t,
   // DO NOT EDIT BY PARAMETER
   parameter int                                    NR_BITS_SRC      = 32,//(NR_SRC > 31) ? 32 : NR_SRC,
   parameter int                                    NR_REG           = (NR_SRC < 32) ? 1 : NR_SRC/32,
   parameter int                                    VS_INTP_FILE_LEN = $clog2(NR_INTP_FILES-2),
   parameter int                                    NR_SRC_LEN       = $clog2(NR_SRC)
) (
   input  logic                                     i_clk           ,
   input  logic                                     ni_rst          ,
   /** AXI interface */
   input  axi_req_t                                 i_req           ,
   output axi_resp_t                                o_resp          ,
   /** CSR interface*/
   input  logic [1:0]                               i_priv_lvl      ,
   input  logic [VS_INTP_FILE_LEN:0]                i_vgein         ,
   input  logic [32-1:0]                            i_imsic_addr    ,
   input  logic [32-1:0]                            i_imsic_data    ,
   input  logic                                     i_imsic_we      ,
   input  logic                                     i_imsic_claim   ,
   output logic [32-1:0]                            o_imsic_data    ,
   output logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0] o_xtopei        ,
   output logic [NR_INTP_FILES-1:0]                 o_Xeip_targets  ,
   output logic                                     o_imsic_exception
);

localparam MAX_INTP_FILE_LEN                        = $clog2(NR_INTP_FILES);

/** to be removed */
localparam PRIV_LVL_M                               = 2'b11;
localparam PRIV_LVL_HS                              = 2'b10;
localparam PRIV_LVL_S                               = 2'b01;
localparam PRIV_LVL_U                               = 2'b00;

localparam M_FILE                                   = 0;
localparam S_FILE                                   = 1;
localparam VS_FILE                                  = 2;

localparam EIDELIVERY_OFF                           = 'h70;
localparam EITHRESHOLD_OFF                          = 'h72;
localparam EIP0_OFF                                 = 'h80;
localparam EIP63_OFF                                = 'hBF;
localparam EIE0_OFF                                 = 'hC0;
localparam EIE63_OFF                                = 'hFF;

logic [MAX_INTP_FILE_LEN-1:0]                       select_intp_file_i;
/** Interrupt files registers */
logic [NR_INTP_FILES-1:0][0:0]                      eidelivery_d,   eidelivery_q;
logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]           eithreshold_d,  eithreshold_q;
logic [(NR_INTP_FILES*NR_REG)-1:0][NR_BITS_SRC-1:0] eip_d,          eip_q;
logic [(NR_INTP_FILES*NR_REG)-1:0][NR_BITS_SRC-1:0] eie_d,          eie_q;

logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]           xtopei;
logic [NR_INTP_FILES-1:0]                           xeip_targets;

// ======================= CONTROL LOGIC ==========================
    always_comb begin
        case (i_priv_lvl)
            PRIV_LVL_M: select_intp_file_i  = M_FILE;
            PRIV_LVL_S: select_intp_file_i  = S_FILE + i_vgein;
            default: select_intp_file_i     = '0;
        endcase
    end
// ================================================================

// ======================== REGISTER MAP ==========================
    
    logic [NR_INTP_FILES-1:0]                   setipnum_we;
    logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]   setipnum;

    imsic_regmap #( 
        .NR_SRC_LEN     ( NR_SRC_LEN            ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH        ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH          ),
        .NR_INTP_FILES  ( NR_INTP_FILES         ),
        .axi_req_t      ( axi_req_t             ),
        .axi_resp_t     ( axi_resp_t            )
    ) imsic_regmap_i (
        .i_clk          ( i_clk                 ),
        .ni_rst         ( ni_rst                ),
        .i_setipnum     ( '0                    ),
        .o_setipnum     ( setipnum              ),
        .o_setipnum_we  ( setipnum_we           ),
        .o_setipnum_re  (                       ),
        .i_req          ( i_req                 ),
        .o_resp         ( o_resp                )
    );
// ================================================================

// ================== SELECT REG IN INTP FILE =====================
    always_comb begin
        /** reset val */
        o_imsic_data        = '0;
        o_imsic_exception   = '0;
        eidelivery_d        = eidelivery_q;
        eithreshold_d       = eithreshold_q;
        eip_d               = eip_q;
        eie_d               = eie_q;

        /** IMSIC channel handler for interrupt file CSRs */
        if (i_imsic_we) begin
            case (i_imsic_addr) inside
                EIDELIVERY_OFF: begin
                    eidelivery_d[select_intp_file_i] = i_imsic_data[0];
                end
                EITHRESHOLD_OFF:begin
                    eithreshold_d[select_intp_file_i] = i_imsic_data[NR_SRC_LEN-1:0];
                end
                [EIP0_OFF:EIP63_OFF]:begin
                    if((i_imsic_addr-EIP0_OFF) <= NR_REG-1) begin
                        eip_d[(i_imsic_addr-EIP0_OFF)+(select_intp_file_i*NR_REG)] = i_imsic_data[NR_BITS_SRC-1:0];
                    end
                end
                [EIE0_OFF:EIE63_OFF]:begin
                    if((i_imsic_addr-EIE0_OFF) <= NR_REG-1) begin
                        eie_d[(i_imsic_addr-EIE0_OFF)+(select_intp_file_i*NR_REG)] = i_imsic_data[NR_BITS_SRC-1:0];
                    end
                end
                default: o_imsic_exception = 1'b1;
            endcase
        end else begin
            case (i_imsic_addr) inside
                EIDELIVERY_OFF: begin
                    o_imsic_data = {{31{1'b0}}, eidelivery_q[select_intp_file_i]};
                end
                EITHRESHOLD_OFF:begin
                    o_imsic_data = {{32-NR_SRC_LEN{1'b0}}, eithreshold_q[select_intp_file_i]};
                end
                [EIP0_OFF:EIP63_OFF]:begin
                    if((i_imsic_addr-EIP0_OFF) <= NR_REG-1) begin
                        o_imsic_data = {{32-NR_BITS_SRC{1'b0}}, 
                                        eip_q[(i_imsic_addr-EIP0_OFF)+(select_intp_file_i*NR_REG)]};
                    end
                end
                [EIE0_OFF:EIE63_OFF]:begin
                    if((i_imsic_addr-EIE0_OFF) <= NR_REG-1) begin
                        o_imsic_data = {{32-NR_BITS_SRC{1'b0}}, 
                                        eie_q[(i_imsic_addr-EIE0_OFF)+(select_intp_file_i*NR_REG)]};
                    end
                end
                default: o_imsic_exception = 1'b1;
            endcase
        end

        /** For each priv lvl evaluate if some device triggered 
            an interrupt, and make this interrupt pending */
        for (int i = 0; i < NR_INTP_FILES; i++) begin
            if (setipnum_we[i] && 
                ({{32-NR_SRC_LEN{1'b0}}, setipnum[i]} <= NR_SRC)) begin
                eip_d[({{32-NR_SRC_LEN{1'b0}}, setipnum[i]}/32)+(i*NR_REG)]
                     [{{32-NR_SRC_LEN{1'b0}}, setipnum[i]}%32] = 1'b1;
            end 
        end

        /** If a priv lvl is claiming the intp, unpend the intp */
        if (i_imsic_claim) begin
            eip_d[({{32-NR_SRC_LEN{1'b0}}, xtopei[select_intp_file_i]}/32)+(select_intp_file_i*NR_REG)]
                 [{{32-NR_SRC_LEN{1'b0}}, xtopei[select_intp_file_i]}%32] = 1'b0;
        end

    end
// ================================================================

// ========================= NOTIFIER =============================
    /** For each interrupt file look for the highest pending and 
        enable interrupt 
        k - interrupt file;
        i - register number;
        j - interrupt number in i; 
        
        k*NR_REG - select the interrupt file */
    for (genvar k = 0; k < NR_INTP_FILES; k++) begin
        always_comb begin
            /** reset val */
            xtopei[k]           = '0;
            xeip_targets[k]     = '0;
            for (int i = 0; i < NR_REG; i++) begin
                for (int j = 0; j <= NR_BITS_SRC; j++) begin
                    if ((eie_q[(k*NR_REG)+i][j] && eip_q[(k*NR_REG)+i][j]) &&
                        ((eithreshold_q[k] == 0) || (j[NR_SRC_LEN-1:0] < eithreshold_q[k]))) begin
                        xtopei[k]           = j[NR_SRC_LEN-1:0];
                        /** If delivery is enable for this intp file, notify the hart */
                        if (eidelivery_q[k]) begin
                            xeip_targets[k]     = 1'b1;
                        end
                        break;
                    end
                end
            end
        end
    end
// ================================================================

// ======================= ASSIGN VALUES ==========================
    assign o_xtopei         = xtopei;
    assign o_Xeip_targets   = xeip_targets;
    always_ff @( posedge i_clk or negedge ni_rst ) begin
        if (!ni_rst) begin
            for (int i = 0; i <= NR_INTP_FILES; i++) begin
                eidelivery_q[i]    <= '0;
                eithreshold_q[i]   <= '0;
            end
            for (int i = 0; i < (NR_INTP_FILES*NR_REG); i++) begin
                eip_q[i]           <= '0;
                eie_q[i]           <= '0;
            end
        end else begin
            for (int i = 0; i <= NR_INTP_FILES; i++) begin
                eidelivery_q[i]    <= eidelivery_d[i];
                eithreshold_q[i]   <= eithreshold_d[i];
            end
            for (int i = 0; i < (NR_INTP_FILES*NR_REG); i++) begin
                eip_q[i]           <= eip_d[i];
                eie_q[i]           <= eie_d[i];
            end
        end
    end
// ================================================================


endmodule