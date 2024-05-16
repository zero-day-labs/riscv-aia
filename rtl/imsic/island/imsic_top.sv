/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*               
*/ 
module imsic_top #(
   parameter int unsigned         NR_IMSICS        = 1    ,
   parameter int unsigned         NR_VS_FILES_PER_IMSIC  = 0,
   parameter int unsigned         NR_SRC           = 32   ,
   parameter int unsigned         AXI_ADDR_WIDTH   = 64   ,
   parameter int unsigned         AXI_DATA_WIDTH   = 64   ,
   parameter int unsigned         AXI_ID_WIDTH     = 10   ,
   parameter int unsigned         XLEN             = 64   ,
   parameter type                 axi_req_t        = logic,
   parameter type                 axi_resp_t       = logic,
   // DO NOT EDIT BY PARAMETER
   parameter int                  NR_BITS_SRC      = 32,
   parameter int unsigned         NR_INTP_FILES    = 2 + NR_VS_FILES_PER_IMSIC,
   parameter int                  NR_REG           = (NR_SRC < NR_BITS_SRC) ? 1 : NR_SRC/NR_BITS_SRC,
   parameter int                  VS_INTP_FILE_LEN = $clog2(NR_VS_FILES_PER_IMSIC),
   parameter int                  NR_SRC_LEN       = $clog2(NR_SRC)
) (
   input  logic                                     i_clk           ,
   input  logic                                     ni_rst          ,
   /** AXI interface */
   input  axi_req_t                                 i_req           ,
   output axi_resp_t                                o_resp          ,
   /** CSR interface*/
   input  logic [NR_IMSICS-1:0][1:0]                               i_priv_lvl      ,
   input  logic [NR_IMSICS-1:0][VS_INTP_FILE_LEN:0]                i_vgein         ,
   input  logic [NR_IMSICS-1:0][31:0]                              i_imsic_addr    ,
   input  logic [NR_IMSICS-1:0][XLEN-1:0]                          i_imsic_data    ,
   input  logic [NR_IMSICS-1:0]                                    i_imsic_we      ,
   input  logic [NR_IMSICS-1:0]                                    i_imsic_claim   ,
   output logic [NR_IMSICS-1:0][XLEN-1:0]                          o_imsic_data    ,
   output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0] o_xtopei        ,
   output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                 o_Xeip_targets  ,
   output logic [NR_IMSICS-1:0]                                    o_imsic_exception
);

localparam MAX_INTP_FILE_LEN                        = $clog2(NR_INTP_FILES);

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

logic [NR_IMSICS-1:0][MAX_INTP_FILE_LEN-1:0]                       select_intp_file_i;
/** Interrupt files registers */
logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][0:0]                      eidelivery_d,   eidelivery_q;
logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]           eithreshold_d,  eithreshold_q;
logic [NR_IMSICS-1:0][(NR_INTP_FILES*NR_REG)-1:0][NR_BITS_SRC-1:0] eip_d,          eip_q;
logic [NR_IMSICS-1:0][(NR_INTP_FILES*NR_REG)-1:0][NR_BITS_SRC-1:0] eie_d,          eie_q;

logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]           xtopei;
logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                           xeip_targets;

// ======================= CONTROL LOGIC ==========================
    for (genvar i = 0; i < NR_IMSICS; i++) begin
        always_comb begin
            case (i_priv_lvl[i])
                PRIV_LVL_M: select_intp_file_i[i]  = M_FILE;
                PRIV_LVL_S: select_intp_file_i[i]  = S_FILE + i_vgein[i];
                default: select_intp_file_i[i]     = '0;
            endcase
        end
    end
// ================================================================

// ======================== REGISTER MAP ==========================

    logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                   setipnum_we;
    logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]   setipnum;

    imsic_regmap #( 
        .NR_SRC_LEN     ( NR_SRC_LEN            ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH        ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH          ),
        .NR_IMSICS      ( NR_IMSICS             ),
        .NR_VS_FILES_PER_IMSIC  ( NR_VS_FILES_PER_IMSIC         ),
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
    logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][31:0] aux;
    for (genvar i = 0; i < NR_IMSICS; i++) begin
        always_comb begin
            /** reset val */
            o_imsic_data[i]        = '0;
            o_imsic_exception[i]   = '0;
            eidelivery_d[i]        = eidelivery_q[i];
            eithreshold_d[i]       = eithreshold_q[i];
            eip_d[i]               = eip_q[i];
            eie_d[i]               = eie_q[i];

            /** IMSIC channel handler for interrupt file CSRs */
            if (i_imsic_we[i]) begin
                case (i_imsic_addr[i]) inside
                    EIDELIVERY_OFF: begin
                        eidelivery_d[i][select_intp_file_i[i]] = i_imsic_data[i][0];
                    end
                    EITHRESHOLD_OFF:begin
                        eithreshold_d[i][select_intp_file_i[i]] = i_imsic_data[i][NR_SRC_LEN-1:0];
                    end
                    [EIP0_OFF:EIP63_OFF]:begin
                        if((i_imsic_addr[i]-EIP0_OFF) <= NR_REG-1) begin
                            eip_d[i][(i_imsic_addr[i]-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)] = i_imsic_data[i][31:0];
                            if (XLEN == 64) begin
                                eip_d[i][(i_imsic_addr[i]-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)+1] = i_imsic_data[i][63:32];
                            end
                        end
                    end
                    [EIE0_OFF:EIE63_OFF]:begin
                        if((i_imsic_addr[i]-EIE0_OFF) <= NR_REG-1) begin
                            eie_d[i][(i_imsic_addr[i]-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)] = i_imsic_data[i][31:0];
                            if (XLEN == 64) begin
                                eie_d[i][(i_imsic_addr[i]-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)+1] = i_imsic_data[i][63:32];
                            end
                        end
                    end
                    default: o_imsic_exception[i] = 1'b1;
                endcase
            end else begin
                case (i_imsic_addr[i]) inside
                    EIDELIVERY_OFF: begin
                        o_imsic_data[i] = {{XLEN-1{1'b0}}, eidelivery_q[i][select_intp_file_i[i]]};
                    end
                    EITHRESHOLD_OFF:begin
                        o_imsic_data[i] = {{XLEN-NR_SRC_LEN{1'b0}}, eithreshold_q[i][select_intp_file_i[i]]};
                    end
                    [EIP0_OFF:EIP63_OFF]:begin
                        if((i_imsic_addr[i]-EIP0_OFF) <= NR_REG-1) begin
                            o_imsic_data[i][31:0] = eip_q[i][(i_imsic_addr[i]-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)];
                            if (XLEN == 64) begin
                                o_imsic_data[i][63:32] = eip_q[i][(i_imsic_addr[i]-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)+1];
                            end
                        end
                    end
                    [EIE0_OFF:EIE63_OFF]:begin
                        if((i_imsic_addr[i]-EIE0_OFF) <= NR_REG-1) begin
                            o_imsic_data[i][31:0] = eie_q[i][(i_imsic_addr[i]-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)];
                            if (XLEN == 64) begin
                                o_imsic_data[i][63:32] = eie_q[i][(i_imsic_addr[i]-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)+1];
                            end
                        end
                    end
                    default: o_imsic_exception[i] = 1'b1;
                endcase
            end

            /** AXI channel handler */
            for (int k = 0; k < NR_INTP_FILES; k++) begin
                aux[i][k] = {{32-NR_SRC_LEN{1'b0}}, setipnum[i][k]};
                if (setipnum_we[i][k] && (aux[i][k] <= NR_SRC)) begin
                    eip_d[i][(aux[i][k]/32)+(k*NR_REG)][aux[i][k]%32] = 1'b1;
                end 
            end

            /** If a priv lvl is claiming the intp, unpend the intp */
            if (i_imsic_claim[i]) begin
                eip_d[i][({{32-NR_SRC_LEN{1'b0}}, xtopei[i][select_intp_file_i[i]]}/32)+(select_intp_file_i[i]*NR_REG)]
                    [{{32-NR_SRC_LEN{1'b0}}, xtopei[i][select_intp_file_i[i]]}%32] = 1'b0;
            end

            /** Intp 0 is always 0 for pend and enable */
            for (int j = 0; j < NR_INTP_FILES; j++) begin
                eip_d[i][j*NR_REG][0] = 1'b0;
                eie_d[i][j*NR_REG][0] = 1'b0;
            end

        end
    end

// ================================================================

// ========================= NOTIFIER =============================
    /** For each interrupt file look for the highest pending and 
        enable interrupt 
        w - imsic index
        k - interrupt file;
        i - register number;
        j - interrupt number in i; 
        
        k*NR_REG - select the interrupt file */
    logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][31:0] acc; 
    for (genvar w = 0; w < NR_IMSICS; w++) begin
        for (genvar k = 0; k < NR_INTP_FILES; k++) begin
            always_comb begin
                /** reset val */
                xtopei[w][k]           = '0;
                xeip_targets[w][k]     = '0;
                acc[w][k]              = '0;
                for (int i = 0; i < NR_REG; i++) begin
                    for (int j = 0; j <= NR_BITS_SRC; j++) begin
                        if ((eie_q[w][(k*NR_REG)+i][j] && eip_q[w][(k*NR_REG)+i][j]) &&
                            ((eithreshold_q[w][k] == 0) || (j[NR_SRC_LEN-1:0] < eithreshold_q[w][k]))) begin
                            acc[w][k]              = i*NR_BITS_SRC;
                            xtopei[w][k]           = j[NR_SRC_LEN-1:0] + acc[w][k][NR_SRC_LEN-1:0];
                            /** If delivery is enable for this intp file, notify the hart */
                            if (eidelivery_q[w][k]) begin
                                xeip_targets[w][k] = 1'b1;
                            end
                            break;
                        end
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
            eidelivery_q    <= '0;
            eithreshold_q   <= '0;
            eip_q           <= '0;
            eie_q           <= '0;
        end else begin
            eidelivery_q    <= eidelivery_d;
            eithreshold_q   <= eithreshold_d;
            eip_q           <= eip_d;
            eie_q           <= eie_d;
        end
    end
// ================================================================


endmodule