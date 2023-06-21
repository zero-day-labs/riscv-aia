/** 
*   Copyright 2023 Francisco Marques, Universidade do Minho
*
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
* 
*   Description: This module is the APLIC domain.
*                It is comprised by 3 submodules: gatway, notifier and register map.
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
   input  logic [NR_SRC-1:0]                    i_irq_sources    ,
   /**  interface for direct mode */
   `ifdef DIRECT_MODE
   /** Interrupt Notification to Harts. One per priv. level per hart. */
   output logic [NR_DOMAINS-1:0][NR_IDCs-1:0]   o_Xeip_targets
   `endif
);
// ================== INTERCONNECTION SIGNALS =====================
   /** Notifier signals */
   logic [NR_DOMAINS-1:0]                                  domaincfgIE         ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setip_to_notifier   ;
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       setie_to_notifier   ;
   logic [NR_SRC-1:1][31:0]                                target              ;
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                idelivery           ;
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0]       ithreshold          ; 
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                iforce              ;    
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][25:0]               topi                ;
   logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     topi_update         ;

   /** Gateway signals */
   logic [NR_REG:0][NR_BITS_SRC-1:0]                       rectified_src       ;
   logic [NR_DOMAINS-1:0]                                  domaincfgDM         ;
   logic [NR_DOMAINS-1:0][NR_REG:0][NR_BITS_SRC-1:0]       active              ;
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
      .i_active               ( active                ),
   `ifdef DIRECT_MODE
      .i_idelivery            ( idelivery             ),    
      .i_iforce               ( iforce                ),
      .i_ithreshold           ( ithreshold            ),    
      .o_topi_sugg            ( topi                  ),    
      .o_topi_update          ( topi_update           ),    
      .o_Xeip_targets         ( o_Xeip_targets        )
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
      .reg_req_t              ( reg_intf::reg_intf_req_a32_d32    ),
      .reg_rsp_t              ( reg_intf::reg_intf_resp_d32       )
   ) i_aplic_domain_regctl_minimal (
      .i_clk                  ( i_clk                 ),
      .ni_rst                 ( ni_rst                ),
      .i_req_cfg              ( i_req_cfg             ),
      .o_resp_cfg             ( o_resp_cfg            ),
      /** Gateway */
      .o_sourcecfg            ( sourcecfg             ),
      .o_sugg_setip           ( sugg_setip            ),
      .o_domaincfgDM          ( domaincfgDM           ),
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
   `endif
   );
// ================================================================

endmodule