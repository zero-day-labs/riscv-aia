/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_top 
import aplic_pkg::*;
import imsic_pkg::*;
import imsic_protocol_pkg::*;
#(
   parameter aplic_cfg_t      AplicCfg                = DefaultAplicCfg,
   parameter imsic_cfg_t      ImsicCfg                = DefaultImsicCfg,
   parameter protocol_cfg_t   ProtocolCfg             = DefaultImsicProtocolCfg,
   parameter type             reg_req_t               = logic,
   parameter type             reg_rsp_t               = logic,
   parameter type             axi_req_t               = logic,
   parameter type             axi_resp_t              = logic,
   // DO NOT EDIT BY PARAMETER
   parameter int              NR_SRC_PER_REG          = 32,
   parameter int              NR_REG                  = (AplicCfg.NrSources-1)/NR_SRC_PER_REG
) (
   input  logic                                                      i_clk             ,
   input  logic                                                      ni_rst            ,
   input  reg_req_t                                                  i_req_cfg         ,
   output reg_rsp_t                                                  o_resp_cfg        ,
   input  logic [AplicCfg.NrSources-1:0]                             i_irq_sources     ,
   `ifdef MSI_MODE
   `ifdef AIA_EMBEDDED
   /** IMSIC island CSR interface */
   input  csr_channel_to_imsic_t   [ImsicCfg.NrHarts-1:0]            i_imsic_csr, 
   output csr_channel_from_imsic_t [ImsicCfg.NrHarts-1:0]            o_imsic_csr,
   input   axi_req_t                                                 i_imsic_req,
   output  axi_resp_t                                                o_imsic_resp
   `elsif AIA_DISTRIBUTED
   output  axi_req_t                                                 o_msi_req,
   input   axi_resp_t                                                i_msi_rsp
   `endif
   /** IMSIC island AXI interface*/
   `elsif DIRECT_MODE
   output logic        [AplicCfg.NrHarts-1:0]   o_eintp_cpu   [AplicCfg.NrDomains-1:0]
   `endif
);
// ================== INTERCONNECTION SIGNALS =====================
   intp_domain_t [AplicCfg.NrSources-1:1]   intp_domain;

   /** Notifier signals */
   target_t     [AplicCfg.NrSources-1:1] target;
   setip_t      [NR_REG:0]               setip_to_notifier;
   setie_t      [NR_REG:0]               setie_to_notifier;

   logic                                 domaincfgIE        [AplicCfg.NrDomains-1:0];
   `ifdef DIRECT_MODE
   idelivery_t  [AplicCfg.NrHarts-1:0]   idelivery          [AplicCfg.NrDomains-1:0];
   iforce_t     [AplicCfg.NrHarts-1:0]   iforce             [AplicCfg.NrDomains-1:0];
   ithreshold_t [AplicCfg.NrHarts-1:0]   ithreshold         [AplicCfg.NrDomains-1:0];
   claimi_t     [AplicCfg.NrHarts-1:0]   topi               [AplicCfg.NrDomains-1:0];
   logic        [AplicCfg.NrHarts-1:0]   topi_update        [AplicCfg.NrDomains-1:0];
   `elsif MSI_MODE
   genmsi_t                              genmsi             [AplicCfg.NrDomains-1:0];
   logic                                 genmsi_sent        [AplicCfg.NrDomains-1:0];
   eiid_t                                intp_forwd_id;
   logic                                 forwarded_valid;
   `endif

   /** Gateway signals */
   logic    domaincfgDM                     [AplicCfg.NrDomains-1:0];

   aia_bitmap_t [NR_REG:0]                       active;
   aia_bitmap_t [NR_REG:0]                       claimed;
   setip_t      [NR_REG:0]                       setip;
   setip_t      [NR_REG:0]                       sugg_setip;
   logic        [AplicCfg.NrSources-1:0]         rectified_src;
   sourcecfg_t  [AplicCfg.NrSources-1:1]         sourcecfg;
   logic        [AplicCfg.NrSources-1:0][2:0]    intp_pen_src;      
// ================================================================

// ========================== GATEWAY =============================
   aplic_domain_gateway #(
      .AplicCfg               ( AplicCfg              )
   ) aplic_domain_gateway (
      .i_clk                  ( i_clk                 ),                
      .ni_rst                 ( ni_rst                ),                
      .i_sources              ( i_irq_sources         ),                        
      .i_sourcecfg            ( sourcecfg             ),                            
      .i_domaincfgDM          ( domaincfgDM           ),                                
      .i_intp_domain          ( intp_domain           ),                        
      .i_active               ( active                ),                        
      .i_sugg_setip           ( sugg_setip            ),                                
      .i_claimed              ( claimed               ),                        
      .o_setip                ( setip                 ),  
      .o_rectified_src        ( rectified_src         ),                                    
      .o_intp_pen_src         ( intp_pen_src          )                  
   ); // End of gateway instance
// ================================================================

// ========================== NOTIFIER ============================
   aplic_domain_notifier #(    
      .AplicCfg               ( AplicCfg              ),
      .ImsicCfg               ( ImsicCfg              ),
      .ProtocolCfg            ( ProtocolCfg           ),
      .axi_req_t              ( axi_req_t             ),
      .axi_resp_t             ( axi_resp_t            )
   ) i_aplic_domain_notifier_minimal (
      .i_clk                  ( i_clk                 ),
      .ni_rst                 ( ni_rst                ),
      .i_domaincfgIE          ( domaincfgIE           ),
      .i_setip_q              ( setip_to_notifier     ),
      .i_setie_q              ( setie_to_notifier     ),
      .i_target_q             ( target                ),
      .i_intp_domain          ( intp_domain           ),
      `ifdef MSI_MODE
      .o_forwarded_valid      ( forwarded_valid       ),            
      .o_intp_forwd_id        ( intp_forwd_id         ),
      .i_genmsi               ( genmsi                ),   
      .o_genmsi_sent          ( genmsi_sent           ),      
      `ifdef AIA_EMBEDDED
      .i_imsic_csr            ( i_imsic_csr           ), 
      .o_imsic_csr            ( o_imsic_csr           ),    
      .i_imsic_req            ( i_imsic_req           ),
      .o_imsic_resp           ( o_imsic_resp          )         
      `elsif AIA_DISTRIBUTED
      .o_msi_req              ( o_msi_req             ),
      .i_msi_rsp              ( i_msi_rsp             )
      `endif
      `elsif DIRECT_MODE
      .i_idelivery            ( idelivery             ),   
      .i_iforce               ( iforce                ),
      .i_ithreshold           ( ithreshold            ),   
      .o_topi_sugg            ( topi                  ),   
      .o_topi_update          ( topi_update           ),
      .o_eintp_cpu            ( o_eintp_cpu           )
      `endif
   ); // End of notifier instance
// ================================================================

// =========================== REGCTL =============================
   aplic_domain_regctl #(
      .AplicCfg               ( AplicCfg              ),
      .reg_req_t              ( reg_req_t             ),
      .reg_rsp_t              ( reg_rsp_t             )
   ) i_aplic_domain_regctl_minimal (
      .i_clk                  ( i_clk                 ),
      .ni_rst                 ( ni_rst                ),
      .i_req_cfg              ( i_req_cfg             ),
      .o_resp_cfg             ( o_resp_cfg            ),
      /** Gateway */
      .o_sourcecfg            ( sourcecfg             ),
      .o_sugg_setip           ( sugg_setip            ),
      .o_domaincfgDM          ( domaincfgDM           ),
      .o_intp_domain          ( intp_domain           ),
      .o_active               ( active                ),
      .o_claimed_or_forwarded ( claimed               ),
      .i_setip_gateway        ( setip                 ),
      .i_rectified_src        ( rectified_src         ),
      .i_intp_pen_src         ( intp_pen_src          ),
      /** Notifier */
      .o_domaincfgIE          ( domaincfgIE           ),
      .o_setip                ( setip_to_notifier     ),
      .o_setie                ( setie_to_notifier     ),
      .o_target               ( target                ),
      `ifdef MSI_MODE      
      .i_forwarded_valid      ( forwarded_valid       ),         
      .i_intp_forwd_id        ( intp_forwd_id         ),
      .o_genmsi               ( genmsi                ),
      .i_genmsi_sent          ( genmsi_sent           )
      `elsif DIRECT_MODE
      .o_idelivery            ( idelivery             ),   
      .o_iforce               ( iforce                ),
      .o_ithreshold           ( ithreshold            ),   
      .i_topi                 ( topi                  ),   
      .i_topi_update          ( topi_update           )   
      `endif
   );
// ================================================================

endmodule