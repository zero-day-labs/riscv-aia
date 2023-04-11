//
module aplic_domain_regctl_wrapper #(
    parameter int                                       DOMAIN_ADDR = 32'hc000000,
    parameter int                                       NR_SRC      = 32,
    parameter int                                       MIN_PRIO    = 6,
    parameter int                                       IPRIOLEN    = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
    parameter int                                       NR_IDCs     = 2,
    parameter                                           APLIC       = "LEAF", 
    // DO NOT EDIT BY PARAMETER
    parameter int                                       NR_BITS_SRC = (NR_SRC > 31) ? 32 : NR_SRC,
    parameter int                                       NR_SRC_W    = (NR_SRC == 1) ? 1 : $clog2(NR_SRC),
    parameter int                                       NR_REG      = (NR_SRC-1)/32  
) (
    input   logic                                       i_clk,
    input   logic                                       ni_rst,
    /** Register config: AXI interface From/To system bus */
    input   logic [31:0]                                reg_intf_req_a32_d32_addr,
    input   logic                                       reg_intf_req_a32_d32_write,
    input   logic [31:0]                                reg_intf_req_a32_d32_wdata,
    input   logic [3:0]                                 reg_intf_req_a32_d32_wstrb,
    input   logic                                       reg_intf_req_a32_d32_valid,
    output  logic [31:0]                                reg_intf_resp_d32_rdata,
    output  logic                                       reg_intf_resp_d32_error,
    output  logic                                       reg_intf_resp_d32_ready,
    /** Gateway */
    output  logic [(NR_SRC*11)-1:0]                     o_sourcecfg,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_sugg_setip,
    output  logic                                       o_domaincfgDM,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_active,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_claimed_forwarded,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_intp_pen,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_rectified_src,
    /** Notifier */
    output  logic                                       o_domaincfgIE,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_setip_q,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_setie_q,
    output  logic [(NR_SRC*32)-1:0]                     o_target_q,
        /**  interface for direct mode */
    output  logic [NR_IDCs-1:0]                         o_idelivery,
    output  logic [NR_IDCs-1:0]                         o_iforce,
    output  logic [(NR_IDCs*IPRIOLEN)-1:0]              o_ithreshold,
    input   logic [(NR_IDCs*26)-1:0]                    i_topi_sugg,
    input   logic [NR_IDCs-1:0]                         i_topi_update
        /**  interface for msi mode */
);

logic                                       clk_i;
logic                                       rst_ni;
reg_intf::reg_intf_req_a32_d32              i_req;
reg_intf::reg_intf_resp_d32                 o_resp;
logic [NR_SRC-1:1][10:0]                    sourcecfg_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           sugg_setip_o;
logic                                       domaincfgDM_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           active_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           claimed_forwarded_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           intp_pen_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]           rectified_src_i;
logic                                       domaincfgIE_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           setip_q_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]           setie_q_o;
logic [NR_SRC-1:1][31:0]                    target_q_o;
logic [NR_IDCs-1:0][0:0]                    idelivery_o;
logic [NR_IDCs-1:0][0:0]                    iforce_o;
logic [NR_IDCs-1:0][IPRIOLEN-1:0]           ithreshold_o;
logic [NR_IDCs-1:0][25:0]                   topi_sugg_i;
logic [NR_IDCs-1:0]                         topi_update_i;

assign clk_i            = i_clk;
assign rst_ni           = ni_rst;
assign o_domaincfgDM    = domaincfgDM_o;
assign o_domaincfgIE    = domaincfgIE_o;

assign i_req.addr   = reg_intf_req_a32_d32_addr;
assign i_req.write  = reg_intf_req_a32_d32_write;
assign i_req.wdata  = reg_intf_req_a32_d32_wdata;
assign i_req.wstrb  = reg_intf_req_a32_d32_wstrb;
assign i_req.valid  = reg_intf_req_a32_d32_valid;

assign reg_intf_resp_d32_rdata = o_resp.rdata;
assign reg_intf_resp_d32_error = o_resp.error;
assign reg_intf_resp_d32_ready = o_resp.ready;

for (genvar i = 1; i < NR_SRC; i++) begin
    assign o_sourcecfg[i*11 +: 11]  = sourcecfg_o[i];
    assign o_target_q[i*32 +: 32]   = target_q_o[i];
end

for (genvar i = 0; i <= NR_REG; i++) begin
    assign o_sugg_setip[i*NR_BITS_SRC +: NR_BITS_SRC]          = sugg_setip_o[i];
    assign o_active[i*NR_BITS_SRC +: NR_BITS_SRC]              = active_o[i];
    assign o_claimed_forwarded[i*NR_BITS_SRC +: NR_BITS_SRC]   = claimed_forwarded_o[i];
    assign intp_pen_i[i]                                       = i_intp_pen[i*NR_BITS_SRC +: NR_BITS_SRC];
    assign rectified_src_i[i]                                  = i_rectified_src[i*NR_BITS_SRC +: NR_BITS_SRC];
    assign o_setip_q[i*NR_BITS_SRC +: NR_BITS_SRC]             = setip_q_o[i];
    assign o_setie_q[i*NR_BITS_SRC +: NR_BITS_SRC]             = setie_q_o[i];
end

for (genvar i = 0; i < NR_IDCs; i++) begin
    assign o_idelivery[i]                          = idelivery_o[i];
    assign o_iforce[i]                             = iforce_o[i];
    assign o_ithreshold[i*IPRIOLEN +: IPRIOLEN]    = ithreshold_o[i];
    assign topi_sugg_i[i]                          = i_topi_sugg[i*26 +: 26];
    assign topi_update_i[i]                        = i_topi_update[i];
end

aplic_domain_regctl #(
    .DOMAIN_ADDR(DOMAIN_ADDR), 
    .NR_SRC(NR_SRC),      
    .MIN_PRIO(MIN_PRIO),  
    .IPRIOLEN(IPRIOLEN),
    .NR_IDCs(NR_IDCs),
    .APLIC(APLIC) 
) i_aplic_domain_regctl (
    .i_clk(clk_i),
    .ni_rst(rst_ni),
    .i_req(i_req),
    .o_resp(o_resp),
    .o_sourcecfg(sourcecfg_o),
    .o_sugg_setip(sugg_setip_o),
    .o_domaincfgDM(domaincfgDM_o),
    .o_active(active_o),
    .o_claimed_forwarded(claimed_forwarded_o),
    .i_intp_pen(intp_pen_i),
    .i_rectified_src(rectified_src_i),
    .o_domaincfgIE(domaincfgIE_o),
    .o_setip_q(setip_q_o),
    .o_setie_q(setie_q_o),
    .o_target_q(target_q_o),
    .o_idelivery(idelivery_o),
    .o_iforce(iforce_o),
    .o_ithreshold(ithreshold_o),
    .i_topi_sugg(topi_sugg_i),
    .i_topi_update(topi_update_i)
);
endmodule