/**
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_gateway_wrapper #(
    parameter int                                       NR_DOMAINS  = 2,
    parameter int                                       NR_SRC      = 32,
    parameter int                                       MIN_PRIO    = 6,
    parameter int                                       NR_IDCs     = 1,
    // DO NOT EDIT BY PARAMETER
    parameter int                                       IPRIOLEN    = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
    parameter int                                       NR_BITS_SRC = (NR_SRC > 31) ? 32 : NR_SRC,
    parameter int                                       NR_SRC_W    = (NR_SRC == 1) ? 1 : $clog2(NR_SRC),
    parameter int                                       NR_REG      = (NR_SRC-1)/32  
) (
    input   logic                                       i_clk                       ,
    input   logic                                       ni_rst                      ,
    /** Register config: AXI interface From/To system bus */
    input   logic [31:0]                                reg_intf_req_a32_d32_addr   ,
    input   logic                                       reg_intf_req_a32_d32_write  ,
    input   logic [31:0]                                reg_intf_req_a32_d32_wdata  ,
    input   logic [3:0]                                 reg_intf_req_a32_d32_wstrb  ,
    input   logic                                       reg_intf_req_a32_d32_valid  ,
    output  logic [31:0]                                reg_intf_resp_d32_rdata     ,
    output  logic                                       reg_intf_resp_d32_error     ,
    output  logic                                       reg_intf_resp_d32_ready     ,
    input   logic [NR_SRC-1:0]                          i_sources
);

reg_intf::reg_intf_req_a32_d32                          i_req           ;
reg_intf::reg_intf_resp_d32                             o_resp          ;
logic [NR_REG:0][NR_BITS_SRC-1:0]                       rectified_src   ;
logic [NR_DOMAINS-1:0]                                  domaincfgDM     ;
logic [NR_SRC-1:1]                                      intp_domain     ;
logic [NR_REG:0][NR_BITS_SRC-1:0]                       active          ;
logic [NR_REG:0][NR_BITS_SRC-1:0]                       setip           ;
logic [NR_REG:0][NR_BITS_SRC-1:0]                       claimed         ;
logic [NR_SRC-1:1][10:0]                                sourcecfg       ;
logic [NR_REG:0][NR_BITS_SRC-1:0]                       sugg_setip      ;

assign i_req.addr   = reg_intf_req_a32_d32_addr;
assign i_req.write  = reg_intf_req_a32_d32_write;
assign i_req.wdata  = reg_intf_req_a32_d32_wdata;
assign i_req.wstrb  = reg_intf_req_a32_d32_wstrb;
assign i_req.valid  = reg_intf_req_a32_d32_valid;

assign reg_intf_resp_d32_rdata = o_resp.rdata;
assign reg_intf_resp_d32_error = o_resp.error;
assign reg_intf_resp_d32_ready = o_resp.ready;

aplic_domain_regctl #(
    .DOMAIN_M_ADDR          ( 32'hc000000                       ),    
    .DOMAIN_S_ADDR          ( 32'hd000000                       ),     
    .NR_SRC                 ( NR_SRC                            ),      
    .MIN_PRIO               ( MIN_PRIO                          ),  
    .NR_IDCs                ( NR_IDCs                           ),
    .reg_req_t              ( reg_intf::reg_intf_req_a32_d32    ),
    .reg_rsp_t              ( reg_intf::reg_intf_resp_d32       )
) i_aplic_domain_regctl_minimal (
    .i_clk                  ( i_clk                 ),
    .ni_rst                 ( ni_rst                ),
    .i_req_cfg              ( i_req                 ),
    .o_resp_cfg             ( o_resp                ),
    /** Gateway */
    .o_sourcecfg            ( sourcecfg             ),
    .o_sugg_setip           ( sugg_setip            ),
    .o_domaincfgDM          ( domaincfgDM           ),
    .o_intp_domain          ( intp_domain           ),
    .o_active               ( active                ),
    .o_claimed_or_forwarded ( claimed               ),
    .i_intp_pen             ( setip                 ),
    .i_rectified_src        ( rectified_src         ),
    /** Notifier */
    .o_domaincfgIE          (),
    .o_setip                (),
    .o_setie                (),
    .o_target               (),
`ifdef DIRECT_MODE
    .o_idelivery            (),
    .o_ithreshold           (),
    .o_iforce               (),
    .i_topi                 (),
    .i_topi_update          ()
`endif
);

aplic_domain_gateway #(
    .NR_SRC                 ( NR_SRC                ),
    .NR_DOMAINS             ( NR_DOMAINS            )             
) aplic_domain_gateway (
    .i_clk                  ( i_clk                 ),                
    .ni_rst                 ( ni_rst                ),                
    .i_sources              ( i_sources             ),                        
    .i_sourcecfg            ( sourcecfg             ),                            
    .i_domaincfgDM          ( domaincfgDM           ),                                
    .i_intp_domain          ( intp_domain           ),                        
    .i_active               ( active                ),                        
    .i_sugg_setip           ( sugg_setip            ),                                
    .i_claimed              ( claimed               ),                        
    .o_setip                ( setip                 ),                    
    .o_rectified_src        ( rectified_src         )                                    
);
endmodule