/**
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_imsic_top_wrapper #(
    parameter int                           NR_SRC              = 32                        ,
    parameter int                           MIN_PRIO            = 6                         ,
    parameter int                           NR_IDCs             = 1                         ,
    parameter int                           NR_INTP_FILES       = 3                         ,
    parameter int unsigned                  AXI_ADDR_WIDTH      = 64                        ,
    parameter int unsigned                  AXI_DATA_WIDTH      = 64                        ,
    parameter int unsigned                  AXI_ID_WIDTH        = 4                         ,
    parameter int                           VS_INTP_FILE_LEN    = $clog2(NR_INTP_FILES-2)   ,
    parameter int                           NR_SRC_LEN          = $clog2(NR_SRC)
   
) (
    input  logic                            i_clk,
    input  logic                            ni_rst,
    /**========================== IMSIC ==============================*/     
    /** Register config: CRSs interface From/To interrupt files */
    input  logic [1:0]                      i_priv_lvl,
    input  logic [VS_INTP_FILE_LEN:0]       i_vgein,
    input  logic [32-1:0]                   i_imsic_addr,
    input  logic [32-1:0]                   i_imsic_data,
    input  logic                            i_imsic_we,
    input  logic                            i_imsic_claim,
    output logic [32-1:0]                   o_imsic_data,
    output logic [NR_SRC_LEN-1:0]           o_mtopei,
    output logic [NR_SRC_LEN-1:0]           o_stopei,
    output logic                            o_imsic_exception,
    /**===============================================================*/
    /** Register config: AXI interface From/To system bus for domain*/
    input   logic [31:0]                    reg_intf_req_a32_d32_addr,
    input   logic                           reg_intf_req_a32_d32_write,
    input   logic [31:0]                    reg_intf_req_a32_d32_wdata,
    input   logic [3:0]                     reg_intf_req_a32_d32_wstrb,
    input   logic                           reg_intf_req_a32_d32_valid,
    output  logic [31:0]                    reg_intf_resp_d32_rdata,
    output  logic                           reg_intf_resp_d32_error,
    output  logic                           reg_intf_resp_d32_ready,
    input   logic [NR_SRC-1:0]              i_irq_sources
`ifdef MSI_MODE
    ,output  logic [NR_INTP_FILES-1:0]       o_Xeip_targets
`endif
);

logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]   xtopei;

assign o_mtopei = xtopei[0];
assign o_stopei = xtopei[1];

reg_intf::reg_intf_req_a32_d32              i_req;
reg_intf::reg_intf_resp_d32                 o_resp;
logic [(NR_IDCs*2)-1:0]                     Xeip_targets_o;
ariane_axi::req_t                           master_req;          
ariane_axi::resp_t                          master_resp;

assign i_req.addr                           = reg_intf_req_a32_d32_addr;
assign i_req.write                          = reg_intf_req_a32_d32_write;
assign i_req.wdata                          = reg_intf_req_a32_d32_wdata;
assign i_req.wstrb                          = reg_intf_req_a32_d32_wstrb;
assign i_req.valid                          = reg_intf_req_a32_d32_valid;

assign reg_intf_resp_d32_rdata              = o_resp.rdata;
assign reg_intf_resp_d32_error              = o_resp.error;
assign reg_intf_resp_d32_ready              = o_resp.ready;


`ifdef MSI_MODE

    aplic_top #(
        .NR_SRC             ( NR_SRC                        ),
        .MIN_PRIO           ( MIN_PRIO                      ),
        .NR_IDCs            ( NR_IDCs                       ),
        .reg_req_t          ( reg_intf::reg_intf_req_a32_d32),
        .reg_rsp_t          ( reg_intf::reg_intf_resp_d32   )
    ) i_aplic_top (
        .i_clk              ( i_clk                         ),
        .ni_rst             ( ni_rst                        ),
        .i_req_cfg          ( i_req                         ),
        .o_resp_cfg         ( o_resp                        ),
        .i_irq_sources      ( i_irq_sources                 ),
        .o_req_msi          ( master_req                    ),
        .i_resp_msi         ( master_resp                   )
    );

    imsic_top #(
        .NR_SRC             ( NR_SRC            ),
        .MIN_PRIO           ( MIN_PRIO          ),
        .NR_INTP_FILES      ( NR_INTP_FILES     ),
        .AXI_ID_WIDTH       ( 4                 ),
        .axi_req_t          ( ariane_axi::req_t ),
        .axi_resp_t         ( ariane_axi::resp_t)
    ) i_imsic_top (
        .i_clk              ( i_clk             ),
        .ni_rst             ( ni_rst            ),
        .i_req              ( master_req        ),
        .o_resp             ( master_resp       ),
        .i_priv_lvl         ( i_priv_lvl        ),
        .i_vgein            ( i_vgein           ),
        .i_imsic_addr       ( i_imsic_addr      ),
        .i_imsic_data       ( i_imsic_data      ),
        .i_imsic_we         ( i_imsic_we        ),
        .i_imsic_claim      ( i_imsic_claim     ),
        .o_imsic_data       ( o_imsic_data      ),
        .o_xtopei           ( xtopei            ),
        .o_Xeip_targets     ( o_Xeip_targets    ),
        .o_imsic_exception  ( o_imsic_exception )
    );

`endif

endmodule