/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_notifier #(
    parameter int unsigned         XLEN                    = 64     ,
    parameter int unsigned         NR_DOMAINS              = 2      ,
    parameter int unsigned         MIN_PRIO                = 6      ,
    parameter int unsigned         NR_IDCs                 = 1      ,
    parameter int unsigned         NR_SRC                  = 32     ,
    parameter int unsigned         NR_SRC_IMSIC            = 64     ,
    parameter int unsigned         NR_IMSICS               = 1      ,
    parameter int unsigned         NR_VS_FILES_PER_IMSIC   = 0      ,
    parameter int unsigned         AXI_ADDR_WIDTH          = 64     ,
    parameter int unsigned         AXI_DATA_WIDTH          = 64     ,
    parameter int unsigned         AXI_ID_WIDTH            = 4      ,
    parameter type                 axi_req_t               = ariane_axi::req_t ,
    parameter type                 axi_resp_t              = ariane_axi::resp_t,
    // DO NOT EDIT BY PARAMETER
    parameter int                  NR_BITS_SRC      = 32,
    parameter int                  NR_REG           = (NR_SRC-1)/32,
    parameter int unsigned         NR_INTP_FILES    = 2 + NR_VS_FILES_PER_IMSIC,
    parameter int                  IMSICS_LEN       = (NR_IMSICS == 1) ? 1: $clog2(NR_IMSICS),
    parameter int                  INTP_FILE_LEN    = $clog2(NR_INTP_FILES),
    parameter int                  VS_INTP_FILE_LEN = $clog2(NR_VS_FILES_PER_IMSIC),
    parameter int                  NR_SRC_LEN       = $clog2(NR_SRC_IMSIC)
) (
    input   logic                                i_clk              ,
    input   logic                                ni_rst             ,
    input   logic [NR_DOMAINS-1:0]               i_domaincfgIE      ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]    i_setip_q          ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]    i_setie_q          ,
    input   logic [NR_SRC-1:1][31:0]             i_target_q         ,
    input   logic [NR_SRC-1:1]                   i_intp_domain      ,
    /** interface for MSI mode */
    input   logic [NR_DOMAINS-1:0][31:0]         i_genmsi           ,
    output  logic [NR_DOMAINS-1:0]               o_genmsi_sent      ,
    output  logic                                o_forwarded_valid  ,
    output  logic [10:0]                         o_intp_forwd_id    ,
    /** IMSIC island CSR interface */
    /** NOTE: This should be a struct */
    input  logic [NR_IMSICS-1:0][1:0]                               i_priv_lvl      ,
    input  logic [NR_IMSICS-1:0][VS_INTP_FILE_LEN:0]                i_vgein         ,
    input  logic [NR_IMSICS-1:0][32-1:0]                            i_imsic_addr    ,
    input  logic [NR_IMSICS-1:0][XLEN-1:0]                          i_imsic_data    ,
    input  logic [NR_IMSICS-1:0]                                    i_imsic_we      ,
    input  logic [NR_IMSICS-1:0]                                    i_imsic_claim   ,
    output logic [NR_IMSICS-1:0][XLEN-1:0]                          o_imsic_data    ,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0] o_xtopei        ,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                 o_Xeip_targets  ,
    output logic [NR_IMSICS-1:0]                                    o_imsic_exception,
    /** IMSIC island AXI interface*/
    input   axi_req_t                            i_imsic_req        ,
    output  axi_resp_t                           o_imsic_resp
);

/** Signals for IMSIC island */
logic [NR_SRC_LEN-1:0]      imsic_setipnum;
logic [NR_IMSICS-1:0]       imsic_en;
logic [INTP_FILE_LEN-1:0]   imsic_select_file;
/** Signals for APLIC register controller */
logic [10:0]                forwarded_intp_id;
logic                       forwarded_valid;
logic [NR_DOMAINS-1:0]      genmsi_sent;

always_comb begin : find_pen_en_intp
    forwarded_intp_id   = '0;
    forwarded_valid     = '0;
    genmsi_sent         = '0;
    imsic_setipnum      = '0;    
    imsic_select_file   = '0;           
    imsic_en            = '0;

    for (int i = 1 ; i < NR_SRC ; i++) begin
        if (i_setip_q[i/32][i%32] && i_setie_q[i/32][i%32] && 
            i_domaincfgIE[i_intp_domain[i]]) begin
            imsic_setipnum      = i_target_q[i][0+:NR_SRC_LEN];
            /** if intp belongs to M domain i_intp_domain = 0, else = 1. + guest index*/
            imsic_select_file   = (i_intp_domain[i] == 0) ? 0 : 1 + i_target_q[i][12+:INTP_FILE_LEN];
            imsic_en            = (1'b1 << i_target_q[i][18+:IMSICS_LEN]);
            forwarded_intp_id   = i[10:0];
            forwarded_valid     = 1'b1;
        end
    end
end

assign o_genmsi_sent        = genmsi_sent;
assign o_forwarded_valid    = forwarded_valid;
assign o_intp_forwd_id      = forwarded_intp_id;

imsic_island_top #(
    .XLEN                   ( XLEN                  ),
    .NR_SRC                 ( NR_SRC_IMSIC          ),
    .NR_IMSICS              ( NR_IMSICS             ),
    .NR_VS_FILES_PER_IMSIC  ( NR_VS_FILES_PER_IMSIC ),
    .AXI_ADDR_WIDTH         ( AXI_ADDR_WIDTH        ),
    .AXI_DATA_WIDTH         ( AXI_DATA_WIDTH        ),
    .AXI_ID_WIDTH           ( AXI_ID_WIDTH          ),
    .axi_req_t              ( axi_req_t             ),
    .axi_resp_t             ( axi_resp_t            )
) i_imsic_top (
    .i_clk                  ( i_clk                 ),
    .ni_rst                 ( ni_rst                ),
    .i_req                  ( i_imsic_req           ),
    .o_resp                 ( o_imsic_resp          ),
    .i_priv_lvl             ( i_priv_lvl            ),
    .i_vgein                ( i_vgein               ),
    .i_imsic_addr           ( i_imsic_addr          ),
    .i_imsic_data           ( i_imsic_data          ),
    .i_imsic_we             ( i_imsic_we            ),
    .i_imsic_claim          ( i_imsic_claim         ),
    .o_imsic_data           ( o_imsic_data          ),
    .o_xtopei               ( o_xtopei              ),
    .o_Xeip_targets         ( o_Xeip_targets        ),
    .o_imsic_exception      ( o_imsic_exception     ),
    .i_aplic_setipnum       ( imsic_setipnum        ),
    .i_aplic_imsic_en       ( imsic_en              ),
    .i_aplic_select_file    ( imsic_select_file     )
);

endmodule