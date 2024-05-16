/**
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module imsic_top_wrapper #(
    parameter int                           NR_SRC          = 64,
    parameter int                           NR_IMSICS       = 4,
    parameter int                           NR_VS_FILES_PER_IMSIC   = 1 ,
    parameter int unsigned                  XLEN            = 64,
    parameter int unsigned                  AXI_ADDR_WIDTH  = 64,
    parameter int unsigned                  AXI_DATA_WIDTH  = 64,
    parameter int unsigned                  AXI_ID_WIDTH    = 4 ,
    //
    parameter int                           NR_INTP_FILES   = 2 + NR_VS_FILES_PER_IMSIC,
    parameter int                           VS_INTP_FILE_LEN = $clog2(NR_VS_FILES_PER_IMSIC),
    parameter int                           NR_SRC_LEN       = $clog2(NR_SRC)
) (
    input  logic                            i_clk,
    input  logic                            ni_rst,
    /** Register config: AXI interface From/To system bus */
    input logic                             ready_i,
    input logic [AXI_ADDR_WIDTH-1:0]        addr_i,
    input logic [AXI_DATA_WIDTH-1:0]        data_i,     
    /** Register config: CRSs interface From/To interrupt files */
    input  logic [NR_IMSICS-1:0]            i_select_imsic,
    input  logic [1:0]                      i_priv_lvl,
    input  logic [VS_INTP_FILE_LEN:0]       i_vgein,
    input  logic [31:0]                     i_imsic_addr,
    input  logic [XLEN-1:0]                 i_imsic_data,
    input  logic                            i_imsic_we,
    input  logic                            i_imsic_claim,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0] o_xtopei,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0] o_Xeip_targets,
    output logic                            o_imsic_exception
);

ariane_axi::req_t                           req;
ariane_axi::resp_t                          resp;

logic [NR_IMSICS-1:0][1:0]                  priv_lvl      ;
logic [NR_IMSICS-1:0][VS_INTP_FILE_LEN:0]   vgein         ;
logic [NR_IMSICS-1:0][31:0]                 imsic_addr    ;
logic [NR_IMSICS-1:0][XLEN-1:0]             imsic_data    ;
logic [NR_IMSICS-1:0]                       imsic_we      ;
logic [NR_IMSICS-1:0]                       imsic_claim   ;

always_comb begin
    priv_lvl = '0;
    vgein = '0;
    imsic_addr = '0;
    imsic_data = '0;
    imsic_we = '0;
    imsic_claim = '0;

    for (int i = 0; i < NR_IMSICS; i++) begin
        if (i_select_imsic[i] == 1'b1) begin
            priv_lvl[i] = i_priv_lvl;
            vgein[i] = i_vgein;
            imsic_addr[i] = i_imsic_addr;
            imsic_data[i] = i_imsic_data;
            imsic_we[i] = i_imsic_we;
            imsic_claim[i] = i_imsic_claim;
        end
    end

end

axi_lite_write_master#(
    .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH    ),
    .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH    )
) axi_lite_write_master_i (
    .clk_i              ( i_clk             ),
    .rst_ni             ( ni_rst            ),
    .ready_i            ( ready_i           ),
    .busy_o             (                   ),
    .addr_i             ( addr_i            ),
    .data_i             ( data_i            ),
    .req_o              ( req               ),
    .resp_i             ( resp              )
);

imsic_top #(
    .NR_SRC             ( NR_SRC            ),
    .NR_IMSICS          ( NR_IMSICS         ),
    .NR_VS_FILES_PER_IMSIC( NR_VS_FILES_PER_IMSIC     ),
    .XLEN               ( XLEN              ),
    .AXI_ID_WIDTH       ( 4                 ),
    .axi_req_t          ( ariane_axi::req_t ),
    .axi_resp_t         ( ariane_axi::resp_t)
) i_imsic_top (
    .i_clk              ( i_clk             ),
    .ni_rst             ( ni_rst            ),
    .i_req              ( req               ),
    .o_resp             ( resp              ),
    .i_priv_lvl         ( priv_lvl          ),
    .i_vgein            ( vgein             ),
    .i_imsic_addr       ( imsic_addr        ),
    .i_imsic_data       ( imsic_data        ),
    .i_imsic_we         ( imsic_we          ),
    .i_imsic_claim      ( imsic_claim       ),
    .o_imsic_data       ( ),
    .o_xtopei           ( o_xtopei          ),
    .o_Xeip_targets     ( o_Xeip_targets    ),
    .o_imsic_exception  ()
);

endmodule