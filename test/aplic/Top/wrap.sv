/**
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_top_wrapper #(
   parameter int                            NR_SRC        = 32,          // Interrupt 0 is always 0
   parameter int                            MIN_PRIO      = 6,
   parameter int                            NR_IDCs       = 1
) (
    input  logic                            i_clk,
    input  logic                            ni_rst,
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
    `ifdef DIRECT_MODE
    ,
    output  logic [(NR_IDCs*2)-1:0]         o_Xeip_targets
    `endif
);

logic                                       clk_i;
logic                                       rst_ni;
reg_intf::reg_intf_req_a32_d32              i_req;
reg_intf::reg_intf_resp_d32                 o_resp;
logic [NR_SRC-1:0]                          irq_sources_i;
`ifdef DIRECT_MODE
logic [(NR_IDCs*2)-1:0]                     Xeip_targets_o;
`elsif MSI_MODE
ariane_axi::req_t                           master_req;          
ariane_axi::resp_t                          master_resp;
`endif

assign clk_i            = i_clk;
assign rst_ni           = ni_rst;

assign i_req.addr   = reg_intf_req_a32_d32_addr;
assign i_req.write  = reg_intf_req_a32_d32_write;
assign i_req.wdata  = reg_intf_req_a32_d32_wdata;
assign i_req.wstrb  = reg_intf_req_a32_d32_wstrb;
assign i_req.valid  = reg_intf_req_a32_d32_valid;

assign reg_intf_resp_d32_rdata = o_resp.rdata;
assign reg_intf_resp_d32_error = o_resp.error;
assign reg_intf_resp_d32_ready = o_resp.ready;

assign irq_sources_i = i_irq_sources;
`ifdef DIRECT_MODE
assign o_Xeip_targets = Xeip_targets_o;
`endif


`ifdef DIRECT_MODE

    aplic_top #(
        .NR_SRC             ( NR_SRC                        ),
        .MIN_PRIO           ( MIN_PRIO                      ),
        .NR_IDCs            ( NR_IDCs                       ),
        .reg_req_t          ( reg_intf::reg_intf_req_a32_d32),
        .reg_rsp_t          ( reg_intf::reg_intf_resp_d32   )
    ) i_aplic_top (
        .i_clk              ( clk_i                         ),
        .ni_rst             ( rst_ni                        ),
        .i_req_cfg          ( i_req                         ),
        .o_resp_cfg         ( o_resp                        ),
        .i_irq_sources      ( irq_sources_i                 ),
        .o_Xeip_targets     ( Xeip_targets_o                )
    );

`elsif MSI_MODE

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
        .i_irq_sources      ( irq_sources_i                 ),
        .o_req              ( master_req                    ),
        .i_resp             ( master_resp                   )
    );

    axi_lite_interface #(
        .AXI_ADDR_WIDTH ( 64              ),
        .AXI_DATA_WIDTH ( 64              ),
        .AXI_ID_WIDTH   ( 4               )
    ) axi_lite_interface_i (
        .clk_i          ( clk_i           ),
        .rst_ni         ( rst_ni          ),
        .axi_req_i      ( master_req      ),
        .axi_resp_o     ( master_resp     ),
        .address_o      (                 ),
        .en_o           (                 ),
        .we_o           (                 ),
        .be_o           (                 ),
        .data_i         (                 ),
        .data_o         (                 )
    );

`endif

endmodule