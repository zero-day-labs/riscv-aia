/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
* 
* Description: Top module for APLIC IP. Connects the three modules 
*              that comprise the IP - Notifier, gateway and register controller.
*/ 
module aplic_top #(
   /** Number of external interrupts */
   parameter int                           NR_SRC     = 32,
   parameter int                           MIN_PRIO   = 6,
   /** There is one IDC per hart index connected to the APLIC */
   parameter int                           NR_DOMAINS = 2,
   parameter int                           NR_IDCs    = 1,
   parameter unsigned                      NR_VS_FILES_PER_IMSIC= 64'h1,
   parameter type                          reg_req_t  = logic,
   parameter type                          reg_rsp_t  = logic,
   parameter type                          axi_req_t  = logic,
   parameter type                          axi_rsp_t  = logic
) (
   input  logic                            i_clk,
   input  logic                            ni_rst,
   input  logic [NR_SRC-1:0]               i_irq_sources,
   /** APLIC domain interface */
   input  reg_req_t                        i_req_cfg,
   output reg_rsp_t                        o_resp_cfg,
   /**  interface for direct mode */
   `ifdef DIRECT_MODE
   /** Interrupt Notification to Targets. One per priv. level. */
   output logic [NR_IDCs-1:0][NR_DOMAINS-1:0]  o_Xeip_targets
   /** interface for MSI mode */
   `elsif MSI_MODE
   output  axi_req_t                       o_req_msi,
   input   axi_rsp_t                       i_resp_msi
   `endif
); /** End of APLIC top interface */

logic [1:0][NR_SRC-1:0]    sync_irq_src;
logic [NR_SRC-1:0]         irq_del_sources_i;
reg_req_t                  i_req_cfg_m;
reg_rsp_t                  o_resp_cfg_m;
reg_req_t                  i_req_cfg_s;
reg_rsp_t                  o_resp_cfg_s;

/** 
 * A 2-level synchronyzer to avoid metastability in the irq line
*/
always_ff @( posedge i_clk or negedge ni_rst) begin
   if(!ni_rst)begin
      sync_irq_src <= '0;
   end else begin
      sync_irq_src[0] <= i_irq_sources;
      sync_irq_src[1] <= sync_irq_src[0];
   end
end

always_comb begin
   if(i_req_cfg.addr >= 32'hd000000) begin
   
      i_req_cfg_s.addr   = i_req_cfg.addr;
      i_req_cfg_s.write  = i_req_cfg.write;
      i_req_cfg_s.wdata  = i_req_cfg.wdata;
      i_req_cfg_s.wstrb  = i_req_cfg.wstrb;
      i_req_cfg_s.valid  = i_req_cfg.valid;

      o_resp_cfg.rdata = o_resp_cfg_s.rdata;
      o_resp_cfg.error = o_resp_cfg_s.error;
      o_resp_cfg.ready = o_resp_cfg_s.ready;

      i_req_cfg_m.valid  = '0;

   end else begin

      i_req_cfg_m.addr   = i_req_cfg.addr;
      i_req_cfg_m.write  = i_req_cfg.write;
      i_req_cfg_m.wdata  = i_req_cfg.wdata;
      i_req_cfg_m.wstrb  = i_req_cfg.wstrb;
      i_req_cfg_m.valid  = i_req_cfg.valid;

      o_resp_cfg.rdata = o_resp_cfg_m.rdata;
      o_resp_cfg.error = o_resp_cfg_m.error;
      o_resp_cfg.ready = o_resp_cfg_m.ready;

      i_req_cfg_s.valid  = '0;
   end
end

`ifdef DIRECT_MODE
logic [NR_DOMAINS-1:0][NR_IDCs-1:0]  Xeip_targets;
`endif

`ifdef MSI_MODE
axi_req_t               axi_req_m_domain;
axi_rsp_t               axi_resp_m_domain;
axi_req_t               axi_req_s_domain;
axi_rsp_t               axi_resp_s_domain;
logic                   axi_1_busy;

always_comb begin : basic_interconnect
   if (~axi_1_busy) begin
      o_req_msi.aw               = axi_req_s_domain.aw ;
      o_req_msi.aw_valid         = axi_req_s_domain.aw_valid;
      o_req_msi.w                = axi_req_s_domain.w  ;
      o_req_msi.w_valid          = axi_req_s_domain.w_valid ;
      o_req_msi.b_ready          = axi_req_s_domain.b_ready ;
      axi_resp_s_domain.w_ready  = i_resp_msi.w_ready;
      axi_resp_m_domain.w_ready  = 'h0;
   end else begin
      axi_resp_s_domain.w_ready  = 'h0;
      o_req_msi.aw               = axi_req_m_domain.aw ;
      o_req_msi.aw_valid         = axi_req_m_domain.aw_valid;
      o_req_msi.w                = axi_req_m_domain.w  ;
      o_req_msi.w_valid          = axi_req_m_domain.w_valid ;
      o_req_msi.b_ready          = axi_req_m_domain.b_ready ;
      axi_resp_m_domain.w_ready  = i_resp_msi.w_ready;
   end
end
`endif

/** Insert Code Here */
aplic_domain_top #(
   .DOMAIN_ADDR(32'hc000000),
   .NR_SRC(NR_SRC),
   .NR_IDCs(NR_IDCs),
   .MIN_PRIO(MIN_PRIO),
   .APLIC("NON-LEAF"),
   .APLIC_LEVEL("M"),
   .NR_VS_FILES_PER_IMSIC(NR_VS_FILES_PER_IMSIC),
   .IMSIC_ADDR_TARGET(64'h24000000),
   .reg_req_t(reg_req_t),
   .reg_rsp_t(reg_rsp_t),
   .axi_req_t(axi_req_t),
   .axi_rsp_t(axi_rsp_t)
) i_aplic_m_domain_top(
   .i_clk(i_clk),
   .ni_rst(ni_rst),
   .i_req(i_req_cfg_m),
   .o_resp(o_resp_cfg_m),
   .i_irq_sources(sync_irq_src[1]),
   .o_irq_del_sources(irq_del_sources_i),
   `ifdef DIRECT_MODE
   .o_Xeip_targets(Xeip_targets[0])
   `elsif MSI_MODE
   .o_busy(axi_1_busy),
   .o_req(axi_req_m_domain),
   .i_resp(axi_resp_m_domain)
   `endif
);

aplic_domain_top #(
   .DOMAIN_ADDR(32'hd000000),
   .NR_SRC(NR_SRC),
   .NR_IDCs(NR_IDCs),
   .MIN_PRIO(MIN_PRIO),
   .APLIC("LEAF"),
   .APLIC_LEVEL("S"),
   .NR_VS_FILES_PER_IMSIC(NR_VS_FILES_PER_IMSIC),
   .IMSIC_ADDR_TARGET(64'h28000000),
   .reg_req_t(reg_req_t),
   .reg_rsp_t(reg_rsp_t),
   .axi_req_t(axi_req_t),
   .axi_rsp_t(axi_rsp_t)
) i_aplic_s_domain_top(
   .i_clk(i_clk),
   .ni_rst(ni_rst),
   .i_req(i_req_cfg_s),
   .o_resp(o_resp_cfg_s),
   .i_irq_sources(irq_del_sources_i),
   .o_irq_del_sources(),
   `ifdef DIRECT_MODE
   .o_Xeip_targets(Xeip_targets[1])
   `elsif MSI_MODE
   .o_busy( ),
   .o_req(axi_req_s_domain),
   .i_resp(axi_resp_s_domain)
   `endif
);

`ifdef DIRECT_MODE
for (genvar i = 0; i < NR_IDCs; i++) begin
   for (genvar j = 0; j < NR_DOMAINS; j++) begin
      assign o_Xeip_targets[i][j] = Xeip_targets[j][i];      
   end
end
`endif

endmodule