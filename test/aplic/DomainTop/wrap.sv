
module aplic_domain_top_wrapper #(
   parameter int                           DOMAIN_ADDR   = 32'hc000000,
   parameter int                           NR_SRC        = 32,          // Interrupt 0 is always 0
   parameter int                           MIN_PRIO      = 6,
   parameter int                           NR_IDCs       = 1,
   parameter                               APLIC         = "LEAF",
   parameter                               MODE          = "DIRECT",
   // DO NOT EDIT BY PARAMETER
   parameter int                           IPRIOLEN      = 3, //(MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO)
   parameter int                           NR_BITS_SRC   = 32,//(NR_SRC > 32)? 32 : NR_SRC,
   parameter int                           NR_REG        = (NR_SRC-1)/32
) (
    input  logic                            i_clk,
    input  logic                            ni_rst,
    /** Register config: AXI interface From/To system bus */
    input   logic [31:0]                    reg_intf_req_a32_d32_addr,
    input   logic                           reg_intf_req_a32_d32_write,
    input   logic [31:0]                    reg_intf_req_a32_d32_wdata,
    input   logic [3:0]                     reg_intf_req_a32_d32_wstrb,
    input   logic                           reg_intf_req_a32_d32_valid,
    output  logic [31:0]                    reg_intf_resp_d32_rdata,
    output  logic                           reg_intf_resp_d32_error,
    output  logic                           reg_intf_resp_d32_ready,
    input  logic [NR_SRC-1:0]               i_irq_sources,
    output logic [NR_SRC-1:0]               o_irq_del_sources,
    output logic [NR_IDCs-1:0]              o_Xeip_targets
);

logic                                       clk_i;
logic                                       rst_ni;
reg_intf::reg_intf_req_a32_d32              i_req;
reg_intf::reg_intf_resp_d32                 o_resp;
logic [NR_SRC-1:0]                          irq_sources_i;
logic [NR_SRC-1:0]                          irq_del_sources_o;
logic [NR_IDCs-1:0]                         Xeip_targets_o;

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
assign o_irq_del_sources = irq_del_sources_o;
assign o_Xeip_targets = Xeip_targets_o;

aplic_domain_top #(
    .DOMAIN_ADDR(DOMAIN_ADDR),
    .NR_SRC(NR_SRC),
    .MIN_PRIO(MIN_PRIO),
    .NR_IDCs(NR_IDCs),
    .APLIC(APLIC),
    .MODE(MODE)
) i_aplic_domain_top (
    .i_clk(clk_i),
    .ni_rst(rst_ni),
    .i_req(i_req),
    .o_resp(o_resp),
    .i_irq_sources(irq_sources_i),
    .o_irq_del_sources(irq_del_sources_o),
    .o_Xeip_targets(Xeip_targets_o)
);

endmodule