//
module aplic_domain_top_wrapper #(
    parameter int                                       NR_DOMAINS  = 2             ,
    parameter int                                       NR_SRC      = 32            ,
    parameter int                                       MIN_PRIO    = 6             ,
    parameter int                                       NR_IDCs     = 1             
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

reg_intf::reg_intf_req_a32_d32                          i_req;
reg_intf::reg_intf_resp_d32                             o_resp;

assign i_req.addr   = reg_intf_req_a32_d32_addr;
assign i_req.write  = reg_intf_req_a32_d32_write;
assign i_req.wdata  = reg_intf_req_a32_d32_wdata;
assign i_req.wstrb  = reg_intf_req_a32_d32_wstrb;
assign i_req.valid  = reg_intf_req_a32_d32_valid;

assign reg_intf_resp_d32_rdata = o_resp.rdata;
assign reg_intf_resp_d32_error = o_resp.error;
assign reg_intf_resp_d32_ready = o_resp.ready;

aplic_top #(
   .NR_SRC              ( NR_SRC                            ),
   .MIN_PRIO            ( MIN_PRIO                          ),
   .NR_DOMAINS          ( NR_DOMAINS                        ),
   .NR_IDCs             ( NR_IDCs                           ),
   .reg_req_t           ( reg_intf::reg_intf_req_a32_d32    ),
   .reg_rsp_t           ( reg_intf::reg_intf_resp_d32       )
) aplic_top_minimal_i (
   .i_clk               ( i_clk                             ),
   .ni_rst              ( ni_rst                            ),
   .i_irq_sources       ( i_sources                         ),
   .i_req_cfg           ( i_req                             ),
   .o_resp_cfg          ( o_resp                            ),
   `ifdef DIRECT_MODE
   .o_Xeip_targets      ()
   `endif
);

endmodule