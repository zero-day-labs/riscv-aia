/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_top #(
   parameter int unsigned                       XLEN                    = 64,
   parameter int unsigned                       NR_DOMAINS              = 2,
   parameter int unsigned                       NR_SRC                  = 32,
   parameter int unsigned                       NR_SRC_IMSIC            = 64,
   parameter int unsigned                       MIN_PRIO                = 6,
   parameter int unsigned                       NR_IDCs                 = 1,
   parameter int unsigned                       NR_IMSICS               = 1,
   parameter int unsigned                       NR_VS_FILES_PER_IMSIC   = 0,
   parameter type                               reg_req_t               = logic,
   parameter type                               reg_rsp_t               = logic,
   parameter type                               axi_req_t               = ariane_axi::req_t ,
   parameter type                               axi_resp_t              = ariane_axi::resp_t,
   // DO NOT EDIT BY PARAMETER
   parameter int                                IPRIOLEN                = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
   parameter int                                NR_BITS_SRC             = 32,
   parameter int                                NR_REG                  = (NR_SRC-1)/32,
   parameter int unsigned                       NR_INTP_FILES           = 2 + NR_VS_FILES_PER_IMSIC,
   parameter int                                VS_INTP_FILE_LEN        = $clog2(NR_VS_FILES_PER_IMSIC),
   parameter int                                NR_SRC_LEN              = $clog2(NR_SRC_IMSIC)
) (
   input  logic                                                      i_clk             ,
   input  logic                                                      ni_rst            ,
   input  reg_req_t                                                  i_req_cfg         ,
   output reg_rsp_t                                                  o_resp_cfg        ,
   input  logic [NR_SRC-1:0]                                         i_irq_sources     ,
   /** IMSIC island CSR interface */
   /** NOTE: This should be a struct */
   input  logic [NR_IMSICS-1:0][1:0]                                 i_priv_lvl        ,
   input  logic [NR_IMSICS-1:0][VS_INTP_FILE_LEN:0]                  i_vgein           ,
   input  logic [NR_IMSICS-1:0][32-1:0]                              i_imsic_addr      ,
   input  logic [NR_IMSICS-1:0][XLEN-1:0]                            i_imsic_data      ,
   input  logic [NR_IMSICS-1:0]                                      i_imsic_we        ,
   input  logic [NR_IMSICS-1:0]                                      i_imsic_claim     ,
   output logic [NR_IMSICS-1:0][XLEN-1:0]                            o_imsic_data      ,
   output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]   o_xtopei          ,
   output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                   o_Xeip_targets    ,
   output logic [NR_IMSICS-1:0]                                      o_imsic_exception ,
   /** IMSIC island AXI interface*/
   input   axi_req_t                                                 i_imsic_req       ,
   output  axi_resp_t                                                o_imsic_resp
);
// ================== INTERCONNECTION SIGNALS =====================
   logic [NR_SRC-1:1]                                      intp_domain         ;

   /** Notifier signals */
   logic [NR_DOMAINS-1:0]                                  domaincfgIE         ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setip_to_notifier   ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setie_to_notifier   ;
   logic [NR_SRC-1:1][31:0]                                target              ;
   logic [NR_DOMAINS-1:0][31:0]                            genmsi              ;
   logic [NR_DOMAINS-1:0]                                  genmsi_sent         ;
   logic                                                   forwarded_valid     ;
   logic [10:0]                                            intp_forwd_id       ;
   /** Gateway signals */
   logic [NR_SRC-1:0]                                      rectified_src       ;
   logic [NR_DOMAINS-1:0]                                  domaincfgDM         ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       active              ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setip               ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       claimed             ;
   logic [NR_SRC-1:1][10:0]                                sourcecfg           ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       sugg_setip          ;
   logic [NR_SRC-1:0][2:0]                                 intp_pen_src        ;      
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
      .o_rectified_src        ( rectified_src         ),                                    
      .o_intp_pen_src         ( intp_pen_src          )                  
   ); // End of gateway instance
// ================================================================

// ========================== NOTIFIER ============================
   aplic_domain_notifier #(    
      .XLEN                   ( XLEN                  ),      
      .NR_SRC                 ( NR_SRC                ),      
      .NR_SRC_IMSIC           ( NR_SRC_IMSIC          ),  
      .MIN_PRIO               ( MIN_PRIO              ),  
      .NR_IDCs                ( NR_IDCs               ),
      .NR_IMSICS              ( NR_IMSICS             ),
      .NR_VS_FILES_PER_IMSIC  ( NR_VS_FILES_PER_IMSIC ), 
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
      .i_genmsi               ( genmsi                ),   
      .o_genmsi_sent          ( genmsi_sent           ),      
      .o_forwarded_valid      ( forwarded_valid       ),            
      .o_intp_forwd_id        ( intp_forwd_id         ),         
      .i_priv_lvl             ( i_priv_lvl            ),   
      .i_vgein                ( i_vgein               ),
      .i_imsic_addr           ( i_imsic_addr          ),      
      .i_imsic_data           ( i_imsic_data          ),      
      .i_imsic_we             ( i_imsic_we            ),   
      .i_imsic_claim          ( i_imsic_claim         ),      
      .o_imsic_data           ( o_imsic_data          ),      
      .o_xtopei               ( o_xtopei              ),   
      .o_Xeip_targets         ( o_Xeip_targets        ),         
      .o_imsic_exception      ( o_imsic_exception     ),
      .i_imsic_req            ( i_imsic_req           ),
      .o_imsic_resp           ( o_imsic_resp          )         
   ); // End of notifier instance
// ================================================================

// =========================== REGCTL =============================
   aplic_domain_regctl #(
      .DOMAIN_M_ADDR          ( 32'hc000000                       ),    
      .DOMAIN_S_ADDR          ( 32'hd000000                       ),     
      .NR_SRC                 ( NR_SRC                            ),      
      .MIN_PRIO               ( MIN_PRIO                          ),  
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
      .i_intp_pen_src         ( intp_pen_src          ),
      /** Notifier */
      .o_domaincfgIE          ( domaincfgIE           ),
      .o_setip                ( setip_to_notifier     ),
      .o_setie                ( setie_to_notifier     ),
      .o_target               ( target                ),
      .o_genmsi               ( genmsi                ),
      .i_genmsi_sent          ( genmsi_sent           ),   
      .i_forwarded_valid      ( forwarded_valid       ),         
      .i_intp_forwd_id        ( intp_forwd_id         )      
   );
// ================================================================

endmodule