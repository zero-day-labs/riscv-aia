/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
* 
* Description:    This module interconnects APLIC 3 submodules: gatway, notifier and register controller.
*
* NOTE:           This module is part of minimal APLIC. Our minimal APLIC implements only
*                 two domains (M and S). From the AIA specification can be read (section 4.5):
*                 "APLIC implementations can exploit the fact that each source is ultimately active 
*                 in only one domain."
*                 As so, this minimal version implements only one domain and relies on logic to mask 
*                 the interrupt to the correct domain.
*/ 
module aplic_domain_top #(
   parameter int                                NR_DOMAINS    = 2,
   parameter int                                NR_SRC        = 32,         // Interrupt 0 is always 0
   parameter int                                MIN_PRIO      = 6,
   parameter int                                NR_IDCs       = 1,
   parameter type                               reg_req_t     = logic,
   parameter type                               reg_rsp_t     = logic,
   // DO NOT EDIT BY PARAMETER
   parameter int                                IPRIOLEN      = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
   parameter int                                NR_BITS_SRC   = 32,
   parameter int                                NR_REG        = (NR_SRC-1)/32
) (
   input  logic                                 i_clk            ,
   input  logic                                 ni_rst           ,
   input  reg_req_t                             i_req_cfg        ,
   output reg_rsp_t                             o_resp_cfg       ,
   input  logic [NR_SRC-1:0]                    i_irq_sources    
   /**  interface for direct mode */
   `ifdef DIRECT_MODE
   /** Interrupt Notification to Harts. One per priv. level per hart. */
   ,output logic [NR_DOMAINS-1:0][NR_IDCs-1:0]   o_Xeip_targets
   `elsif MSI_MODE
   ,output ariane_axi::req_t                    o_req_msi         ,
   input   ariane_axi::resp_t                   i_resp_msi
   `endif
);
// ================== INTERCONNECTION SIGNALS =====================
   logic [NR_SRC-1:1]                                      intp_domain         ;

   /** Notifier signals */
   logic [NR_DOMAINS-1:0]                                  domaincfgIE         ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setip_to_notifier   ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setie_to_notifier   ;
   logic [NR_SRC-1:1][31:0]                                target              ;
   `ifdef DIRECT_MODE
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                idelivery           ;
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0]       ithreshold          ; 
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                iforce              ;    
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][25:0]               topi                ;
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     topi_update         ;
   `elsif MSI_MODE
   logic [NR_DOMAINS-1:0][31:0]                            genmsi              ;
   logic [NR_DOMAINS-1:0]                                  genmsi_sent         ;
   logic                                                   forwarded_valid     ;
   logic [10:0]                                            intp_forwd_id       ;
   `endif
   /** Gateway signals */
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       rectified_src       ;
   logic [NR_DOMAINS-1:0]                                  domaincfgDM         ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       active              ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setip               ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       claimed             ;
   logic [NR_SRC-1:1][10:0]                                sourcecfg           ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       sugg_setip          ;
// ================================================================

// ========================== GATEWAY =============================
   aplic_domain_gateway #(
      .NR_SRC                 ( NR_SRC                ),
      .NR_DOMAINS             ( NR_DOMAINS            )             
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
      .o_rectified_src        ( rectified_src         )                                    
   ); // End of gateway instance
// ================================================================

// ========================== NOTIFIER ============================
   aplic_domain_notifier #(    
      .NR_SRC                 ( NR_SRC                ),      
      .MIN_PRIO               ( MIN_PRIO              ),  
      .NR_IDCs                ( NR_IDCs               )
   ) i_aplic_domain_notifier_minimal (
      .i_clk                  ( i_clk                 ),
      .ni_rst                 ( ni_rst                ),
      .i_domaincfgIE          ( domaincfgIE           ),
      .i_setip_q              ( setip_to_notifier     ),
      .i_setie_q              ( setie_to_notifier     ),
      .i_target_q             ( target                ),
      .i_intp_domain          ( intp_domain           ),
   `ifdef DIRECT_MODE
      .i_idelivery            ( idelivery             ),    
      .i_iforce               ( iforce                ),
      .i_ithreshold           ( ithreshold            ),    
      .o_topi_sugg            ( topi                  ),    
      .o_topi_update          ( topi_update           ),    
      .o_Xeip_targets         ( o_Xeip_targets        )
   `elsif MSI_MODE
      .i_genmsi               ( genmsi                ),   
      .o_genmsi_sent          ( genmsi_sent           ),      
      .o_forwarded_valid      ( forwarded_valid       ),            
      .o_intp_forwd_id        ( intp_forwd_id         ),         
      .o_req                  ( o_req_msi             ),
      .i_resp                 ( i_resp_msi            )
   `endif
   ); // End of notifier instance
// ================================================================

// =========================== REGCTL =============================
   aplic_domain_regctl #(
      .DOMAIN_M_ADDR          ( 32'hc000000                       ),    
      .DOMAIN_S_ADDR          ( 32'hd000000                       ),     
      .NR_SRC                 ( NR_SRC                            ),      
      .MIN_PRIO               ( MIN_PRIO                          ),  
      .NR_IDCs                ( NR_IDCs                           ),
      .reg_req_t              ( reg_req_t                         ),
      .reg_rsp_t              ( reg_rsp_t                         )
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
      .i_intp_pen             ( setip                 ),
      .i_rectified_src        ( rectified_src         ),
      /** Notifier */
      .o_domaincfgIE          ( domaincfgIE           ),
      .o_setip                ( setip_to_notifier     ),
      .o_setie                ( setie_to_notifier     ),
      .o_target               ( target                ),
   `ifdef DIRECT_MODE
      .o_idelivery            ( idelivery             ),
      .o_ithreshold           ( ithreshold            ),
      .o_iforce               ( iforce                ),
      .i_topi                 ( topi                  ),
      .i_topi_update          ( topi_update           )
   `elsif MSI_MODE
      .o_genmsi               ( genmsi                ),
      .i_genmsi_sent          ( genmsi_sent           ),   
      .i_forwarded_valid      ( forwarded_valid       ),         
      .i_intp_forwd_id        ( intp_forwd_id         )      
   `endif
   );
// ================================================================

endmodule