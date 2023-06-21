//
module aplic_domain_regctl_wrapper #(
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
    /** Gateway */
    output  logic [(NR_SRC*11)-1:0]                     o_sourcecfg                 ,
    output  logic [1:0]                                 o_domaincfgDM               ,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_active                    ,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_rectified_src             ,
    /** Notifier */
    output  logic [1:0]                                 o_domaincfgIE               ,
    output  logic [(NR_SRC*NR_BITS_SRC)-1:0]            o_target                    ,
    input   logic [(NR_DOMAINS*NR_IDCs)-1:0][25:0]      i_topi                      ,   
    input   logic [(NR_DOMAINS*NR_IDCs)-1:0]            i_topi_update
);

reg_intf::reg_intf_req_a32_d32              i_req;
reg_intf::reg_intf_resp_d32                 o_resp;

logic [NR_SRC-1:1][10:0]                    sourcecfg_o;
logic [NR_SRC-1:1][31:0]                    target_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           rectified_src_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]           bypass_gateway;

assign i_req.addr   = reg_intf_req_a32_d32_addr;
assign i_req.write  = reg_intf_req_a32_d32_write;
assign i_req.wdata  = reg_intf_req_a32_d32_wdata;
assign i_req.wstrb  = reg_intf_req_a32_d32_wstrb;
assign i_req.valid  = reg_intf_req_a32_d32_valid;

assign reg_intf_resp_d32_rdata = o_resp.rdata;
assign reg_intf_resp_d32_error = o_resp.error;
assign reg_intf_resp_d32_ready = o_resp.ready;

for (genvar i = 1; i < NR_SRC; i++) begin
    assign o_sourcecfg[i*11 +: 11]                              = sourcecfg_o[i];
    assign o_target[i*NR_BITS_SRC +: NR_BITS_SRC]               = target_o[i];
end

for (genvar i = 0; i <= NR_REG; i++) begin
    assign rectified_src_i[i]                                  = i_rectified_src[i*NR_BITS_SRC +: NR_BITS_SRC];
end

aplic_domain_regctl #(
    .DOMAIN_M_ADDR          ( 32'hc000000                       ),    
    .DOMAIN_S_ADDR          ( 32'hd000000                       ),     
    .NR_SRC                 ( NR_SRC                            ),      
    .MIN_PRIO               ( MIN_PRIO                          ),  
    .IPRIOLEN               ( IPRIOLEN                          ),
    .NR_IDCs                ( NR_IDCs                           ),
    .reg_req_t              ( reg_intf::reg_intf_req_a32_d32    ),
    .reg_rsp_t              ( reg_intf::reg_intf_resp_d32       )
) i_aplic_domain_regctl_minimal (
    .i_clk                  ( i_clk                 ),
    .ni_rst                 ( ni_rst                ),
    .i_req_cfg              ( i_req                 ),
    .o_resp_cfg             ( o_resp                ),
    .o_sourcecfg            ( sourcecfg_o           ),
    .o_sugg_setip           ( bypass_gateway        ),
    .o_domaincfgDM          ( o_domaincfgDM         ),
    .o_active               (               ),
    .o_claimed_or_forwarded (),
    .i_intp_pen             (bypass_gateway         ),
    .i_rectified_src        ( rectified_src_i       ),
    .o_domaincfgIE          ( o_domaincfgIE         ),
    .o_setip                (),
    .o_setie                (),
    .o_target               ( target_o              )
`ifdef DIRECT_MODE
    ,
    .o_idelivery            ( ),
    .o_ithreshold           ( ),
    .o_iforce               ( ),
    .i_topi                 ( i_topi                ),
    .i_topi_update          ( i_topi_update         )
`endif
);
endmodule