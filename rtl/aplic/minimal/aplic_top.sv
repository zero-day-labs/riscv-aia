/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
* 
* Description:    Top module for APLIC IP. Instantiates the APLIC domains, and a 
*                 2-level synchronizer to prevent metastability on interrupt source lines.
*
* NOTE:           This module is part of minimal APLIC. Our minimal APLIC implements only
*                 two domains (M and S). From the AIA specification can be read (section 4.5):
*                 "APLIC implementations can exploit the fact that each source is ultimately active 
*                 in only one domain."
*                 As so, this minimal version implements only one domain and relies on logic to mask 
*                 the interrupt to the correct domain.
*/ 
module aplic_top #(
   parameter int                                NR_SRC     = 32      ,
   parameter int                                MIN_PRIO   = 6       ,
   parameter int                                NR_DOMAINS = 2       ,
   parameter int                                NR_IDCs    = 1       ,
   parameter type                               reg_req_t  = logic   ,
   parameter type                               reg_rsp_t  = logic
) (
   input  logic                                 i_clk                ,
   input  logic                                 ni_rst               ,
   input  logic [NR_SRC-1:0]                    i_irq_sources        ,
   /** APLIC domain interface */
   input  reg_req_t                             i_req_cfg            ,
   output reg_rsp_t                             o_resp_cfg           
   /**  interface for direct mode */
   `ifdef DIRECT_MODE
   /** Interrupt Notification to Targets. One per priv. level. */
   ,output logic [(NR_DOMAINS*NR_IDCs)-1:0]      o_Xeip_targets
   `elsif MSI_MODE
   ,output ariane_axi::req_t                    o_req_msi            ,
   input   ariane_axi::resp_t                   i_resp_msi
   `endif
); /** End of APLIC top interface */

`ifdef DIRECT_MODE
logic [NR_DOMAINS-1:0][NR_IDCs-1:0]   Xeip_targets;
`endif

/** 
 * A 2-level synchronyzer to avoid metastability in the irq line
*/
logic [1:0][NR_SRC-1:0]    sync_irq_src;
always_ff @( posedge i_clk or negedge ni_rst) begin
   if(!ni_rst)begin
      sync_irq_src <= '0;
   end else begin
      sync_irq_src[0] <= i_irq_sources;
      sync_irq_src[1] <= sync_irq_src[0];
   end
end

/** Minimal APLIC Domain */
aplic_domain_top #(
   .NR_DOMAINS       ( NR_DOMAINS         ),
   .NR_SRC           ( NR_SRC             ),
   .NR_IDCs          ( NR_IDCs            ),
   .MIN_PRIO         ( MIN_PRIO           ),
   .reg_req_t        ( reg_req_t          ),
   .reg_rsp_t        ( reg_rsp_t          )
) i_aplic_generic_domain_top (
   .i_clk            ( i_clk              ),
   .ni_rst           ( ni_rst             ),
   .i_req_cfg        ( i_req_cfg          ),
   .o_resp_cfg       ( o_resp_cfg         ),
   .i_irq_sources    ( sync_irq_src[1]    ),
   `ifdef DIRECT_MODE
   .o_Xeip_targets   ( Xeip_targets       )
   `elsif MSI_MODE
   .o_req_msi        ( o_req_msi          ),
   .i_resp_msi       ( i_resp_msi         )
   `endif
);

`ifdef DIRECT_MODE
for (genvar i = 0; i < NR_DOMAINS; i++) begin
   for (genvar j = 0; j < NR_IDCs; j++) begin
      assign o_Xeip_targets[j + (i*NR_IDCs)] = Xeip_targets[i][j];      
   end
end
`endif

endmodule