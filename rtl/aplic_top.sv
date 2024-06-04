/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_top 
import aplic_pkg::*;
import imsic_pkg::*;
import imsic_protocol_pkg::*;
#(
   parameter aplic_cfg_t                        AplicCfg                = DefaultAplicCfg,
   parameter imsic_cfg_t                        ImsicCfg                = DefaultImsicCfg,
   parameter protocol_cfg_t                     ProtocolCfg             = DefaultImsicProtocolCfg,
   parameter type                               reg_req_t               = logic ,
   parameter type                               reg_rsp_t               = logic ,
   parameter type                               axi_req_t               = logic ,
   parameter type                               axi_resp_t              = logic
) (
   input  logic                                                      i_clk             ,
   input  logic                                                      ni_rst            ,
   input  logic [AplicCfg.NrSources-1:0]                             i_irq_sources     ,
   /** APLIC domain interface */
   input  reg_req_t                                                  i_req_cfg         ,
   output reg_rsp_t                                                  o_resp_cfg        ,
   `ifdef MSI_MODE
   `ifdef AIA_EMBEDDED
   /** IMSIC island CSR interface */
   input  csr_channel_to_imsic_t     [ImsicCfg.NrHarts-1:0]          i_imsic_csr, 
   output csr_channel_from_imsic_t   [ImsicCfg.NrHarts-1:0]          o_imsic_csr,
   /** IMSIC island AXI interface*/
   input   axi_req_t                                                 i_imsic_req       ,
   output  axi_resp_t                                                o_imsic_resp
   `elsif AIA_DISTRIBUTED
   output  axi_req_t                                                 o_msi_req,
   input   axi_resp_t                                                i_msi_rsp
   `endif
   `elsif DIRECT_MODE
   output logic        [AplicCfg.NrHarts-1:0]   o_eintp_cpu   [AplicCfg.NrDomains-1:0]
   `endif
); /** End of APLIC top interface */

   /** 
   * A 2-level synchronyzer to avoid metastability in the irq line
   */
   logic [AplicCfg.NrSources-1:0]    sync_irq_src;
   synchronizer_multi_level #(
      .DataW     ( AplicCfg.NrSources ),
      .NrLevels  ( 2                  )
   ) synchronizer_multi_level_i (
      .i_clk     ( i_clk              ),
      .ni_rst    ( ni_rst             ),
      .data_i    ( i_irq_sources      ),
      .data_o    ( sync_irq_src       )
   );

   /** APLIC Domain with IMSIC island */
   aplic_domain_top #(
      .AplicCfg         ( AplicCfg           ),
      .ImsicCfg         ( ImsicCfg           ),
      .ProtocolCfg      ( ProtocolCfg        ),
      .reg_req_t        ( reg_req_t          ),
      .reg_rsp_t        ( reg_rsp_t          ),
      .axi_req_t        ( axi_req_t          ),
      .axi_resp_t       ( axi_resp_t         )
   ) i_aplic_generic_domain_top (
      .i_clk            ( i_clk              ),
      .ni_rst           ( ni_rst             ),
      .i_req_cfg        ( i_req_cfg          ),
      .o_resp_cfg       ( o_resp_cfg         ),
      .i_irq_sources    ( sync_irq_src       ),
      `ifdef MSI_MODE
      `ifdef AIA_EMBEDDED
      .i_imsic_csr      ( i_imsic_csr        ),
      .o_imsic_csr      ( o_imsic_csr        ),   
      .i_imsic_req      ( i_imsic_req        ),
      .o_imsic_resp     ( o_imsic_resp       )    
      `elsif AIA_DISTRIBUTED
      .o_msi_req        ( o_msi_req          ),
      .i_msi_rsp        ( i_msi_rsp          )
      `endif
      `elsif DIRECT_MODE
      .o_eintp_cpu      ( o_eintp_cpu        )
      `endif
   );

endmodule