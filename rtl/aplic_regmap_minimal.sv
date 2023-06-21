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
*   Name: APLIC domain register map for 2 domains
*   Date: 2022-10-18 18:08:30.001661
*   Author: F.Marques <fmarques_00@protonmail.com>
* 
*   Description: This module is a APLIC domain register map with 2 domains (M-level and S-level).
*                For a given domain unused registers should be unconnected.
*/ 
module aplic_regmap_minimal #(
   parameter int                                DOMAIN_M_ADDR     = 32'hc000000,
   parameter int                                DOMAIN_S_ADDR     = 32'hd000000,
   parameter int                                NR_SRC            = 32,
   parameter int                                NR_REG            = 0,
   parameter int                                MIN_PRIO          = 6,
   parameter int                                IPRIOLEN          = 3, //(MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
   parameter int                                NR_IDCs           = 1,
   parameter type                               reg_req_t         = logic,
   parameter type                               reg_rsp_t         = logic
) (
  // Register: domaincfg
  input  logic [1:0][31:0]                      i_domaincfg       ,
  output logic [1:0][31:0]                      o_domaincfg       ,
  output logic [1:0]                            o_domaincfg_we    ,
  output logic [1:0]                            o_domaincfg_re    ,
  // Register: sourcecfg
  input  logic [1:0][NR_SRC-1:1][10:0]          i_sourcecfg       ,
  output logic [1:0][NR_SRC-1:1][10:0]          o_sourcecfg       ,
  output logic [1:0][NR_SRC-1:1]                o_sourcecfg_we    ,
  output logic [1:0][NR_SRC-1:1]                o_sourcecfg_re    ,
  // Register: mmsiaddrcfg
  input  logic [0:0][31:0]                      i_mmsiaddrcfg     ,
  output logic [0:0][31:0]                      o_mmsiaddrcfg     ,
  output logic [0:0]                            o_mmsiaddrcfg_we  ,
  output logic [0:0]                            o_mmsiaddrcfg_re  ,
  // Register: mmsiaddrcfgh
  input  logic [0:0][31:0]                      i_mmsiaddrcfgh    ,
  output logic [0:0][31:0]                      o_mmsiaddrcfgh    ,
  output logic [0:0]                            o_mmsiaddrcfgh_we ,
  output logic [0:0]                            o_mmsiaddrcfgh_re ,
  // Register: smsiaddrcfg
  input  logic [0:0][31:0]                      i_smsiaddrcfg     ,
  output logic [0:0][31:0]                      o_smsiaddrcfg     ,
  output logic [0:0]                            o_smsiaddrcfg_we  ,
  output logic [0:0]                            o_smsiaddrcfg_re  ,
  // Register: smsiaddrcfgh
  input  logic [0:0][31:0]                      i_smsiaddrcfgh    ,
  output logic [0:0][31:0]                      o_smsiaddrcfgh    ,
  output logic [0:0]                            o_smsiaddrcfgh_we ,
  output logic [0:0]                            o_smsiaddrcfgh_re ,
  // Register: setip
  input  logic [1:0][NR_REG:0][31:0]            i_setip           ,
  output logic [1:0][NR_REG:0][31:0]            o_setip           ,
  output logic [1:0][NR_REG:0]                  o_setip_we        ,
  output logic [1:0][NR_REG:0]                  o_setip_re        ,
  // Register: setipnum
  input  logic [1:0][31:0]                      i_setipnum        ,
  output logic [1:0][31:0]                      o_setipnum        ,
  output logic [1:0]                            o_setipnum_we     ,
  output logic [1:0]                            o_setipnum_re     ,
  // Register: in_clrip
  input  logic [1:0][NR_REG:0][31:0]            i_in_clrip        ,
  output logic [1:0][NR_REG:0][31:0]            o_in_clrip        ,
  output logic [1:0][NR_REG:0]                  o_in_clrip_we     ,
  output logic [1:0][NR_REG:0]                  o_in_clrip_re     ,
  // Register: clripnum
  input  logic [1:0][31:0]                      i_clripnum        ,
  output logic [1:0][31:0]                      o_clripnum        ,
  output logic [1:0]                            o_clripnum_we     ,
  output logic [1:0]                            o_clripnum_re     ,
  // Register: setie
  input  logic [1:0][NR_REG:0][31:0]            i_setie           ,
  output logic [1:0][NR_REG:0][31:0]            o_setie           ,
  output logic [1:0][NR_REG:0]                  o_setie_we        ,
  output logic [1:0][NR_REG:0]                  o_setie_re        ,
  // Register: setienum
  input  logic [1:0][31:0]                      i_setienum        ,
  output logic [1:0][31:0]                      o_setienum        ,
  output logic [1:0]                            o_setienum_we     ,
  output logic [1:0]                            o_setienum_re     ,
  // Register: clrie
  input  logic [1:0][NR_REG:0][31:0]            i_clrie           ,
  output logic [1:0][NR_REG:0][31:0]            o_clrie           ,
  output logic [1:0][NR_REG:0]                  o_clrie_we        ,
  output logic [1:0][NR_REG:0]                  o_clrie_re        ,
  // Register: clrienum
  input  logic [1:0][31:0]                      i_clrienum        ,
  output logic [1:0][31:0]                      o_clrienum        ,
  output logic [1:0]                            o_clrienum_we     ,
  output logic [1:0]                            o_clrienum_re     ,
  // Register: setipnum_le
  input  logic [1:0][31:0]                      i_setipnum_le     ,
  output logic [1:0][31:0]                      o_setipnum_le     ,
  output logic [1:0]                            o_setipnum_le_we  ,
  output logic [1:0]                            o_setipnum_le_re  ,
  // Register: setipnum_be
  input  logic [1:0][31:0]                      i_setipnum_be     ,
  output logic [1:0][31:0]                      o_setipnum_be     ,
  output logic [1:0]                            o_setipnum_be_we  ,
  output logic [1:0]                            o_setipnum_be_re  ,
  // Register: genmsi
  input  logic [1:0][31:0]                      i_genmsi          ,
  output logic [1:0][31:0]                      o_genmsi          ,
  output logic [1:0]                            o_genmsi_we       ,
  output logic [1:0]                            o_genmsi_re       ,
  // Register: target
  input  logic [1:0][NR_SRC-1:1][31:0]          i_target          ,
  output logic [1:0][NR_SRC-1:1][31:0]          o_target          ,
  output logic [1:0][NR_SRC-1:1]                o_target_we       ,
  output logic [1:0][NR_SRC-1:1]                o_target_re       ,
  // Register: idelivery
  input  logic [1:0][NR_IDCs-1:0][0:0]          i_idelivery       ,
  output logic [1:0][NR_IDCs-1:0][0:0]          o_idelivery       ,
  output logic [1:0][NR_IDCs-1:0]               o_idelivery_we    ,
  output logic [1:0][NR_IDCs-1:0]               o_idelivery_re    ,
  // Register: iforce
  input  logic [1:0][NR_IDCs-1:0][0:0]          i_iforce          ,
  output logic [1:0][NR_IDCs-1:0][0:0]          o_iforce          ,
  output logic [1:0][NR_IDCs-1:0]               o_iforce_we       ,
  output logic [1:0][NR_IDCs-1:0]               o_iforce_re       ,
  // Register: ithreshold
  input  logic [1:0][NR_IDCs-1:0][IPRIOLEN-1:0] i_ithreshold      ,
  output logic [1:0][NR_IDCs-1:0][IPRIOLEN-1:0] o_ithreshold      ,
  output logic [1:0][NR_IDCs-1:0]               o_ithreshold_we   ,
  output logic [1:0][NR_IDCs-1:0]               o_ithreshold_re   ,
  // Register: topi
  input  logic [1:0][NR_IDCs-1:0][25:0]         i_topi            ,
  output logic [1:0][NR_IDCs-1:0]               o_topi_re         ,
  // Register: claimi
  input  logic [1:0][NR_IDCs-1:0][25:0]         i_claimi          ,
  output logic [1:0][NR_IDCs-1:0]               o_claimi_re       ,
  // Bus Interface
  input  reg_req_t                              i_req             ,
  output reg_rsp_t                              o_resp
);

localparam  M_DOMAIN = 0;
localparam  S_DOMAIN = 1;

always_comb begin
  o_resp.ready              = 1'b1;
  o_resp.rdata              = '0;
  o_resp.error              = '0;
  `ifdef MSI_MODE
  o_domaincfg[M_DOMAIN]     = 32'h80000010;
  o_domaincfg[S_DOMAIN]     = 32'h80000010;
  `else
  o_domaincfg[M_DOMAIN]     = 32'h80000000;
  o_domaincfg[S_DOMAIN]     = 32'h80000000;
  `endif
  o_domaincfg_we            = '0;
  o_domaincfg_re            = '0;
  o_sourcecfg               = '0;
  o_sourcecfg_we            = '0;
  o_sourcecfg_re            = '0;
  o_mmsiaddrcfg             = '0;
  o_mmsiaddrcfg_we          = '0;
  o_mmsiaddrcfg_re          = '0;
  o_mmsiaddrcfgh            = '0;
  o_mmsiaddrcfgh_we         = '0;
  o_mmsiaddrcfgh_re         = '0;
  o_smsiaddrcfg             = '0;
  o_smsiaddrcfg_we          = '0;
  o_smsiaddrcfg_re          = '0;
  o_smsiaddrcfgh            = '0;
  o_smsiaddrcfgh_we         = '0;
  o_smsiaddrcfgh_re         = '0;
  o_setip                   = '0;
  o_setip_we                = '0;
  o_setip_re                = '0;
  o_setipnum                = '0;
  o_setipnum_we             = '0;
  o_setipnum_re             = '0;
  o_in_clrip                = '0;
  o_in_clrip_we             = '0;
  o_in_clrip_re             = '0;
  o_clripnum                = '0;
  o_clripnum_we             = '0;
  o_clripnum_re             = '0;
  o_setie                   = '0;
  o_setie_we                = '0;
  o_setie_re                = '0;
  o_setienum                = '0;
  o_setienum_we             = '0;
  o_setienum_re             = '0;
  o_clrie                   = '0;
  o_clrie_we                = '0;
  o_clrie_re                = '0;
  o_clrienum                = '0;
  o_clrienum_we             = '0;
  o_clrienum_re             = '0;
  o_setipnum_le             = '0;
  o_setipnum_le_we          = '0;
  o_setipnum_le_re          = '0;
  o_setipnum_be             = '0;
  o_setipnum_be_we          = '0;
  o_setipnum_be_re          = '0;
  o_genmsi                  = '0;
  o_genmsi_we               = '0;
  o_genmsi_re               = '0;
  o_target                  = '0;
  o_target_we               = '0;
  o_target_re               = '0;
  o_idelivery               = '0;
  o_idelivery_we            = '0;
  o_idelivery_re            = '0;
  o_claimi_re               = '0;
  o_topi_re                 = '0;
  o_iforce                  = '0;
  o_iforce_we               = '0;
  o_iforce_re               = '0;
  o_ithreshold              = '0;
  o_ithreshold_we           = '0;
  o_ithreshold_re           = '0;

  if (i_req.valid) begin
    if (i_req.write) begin
      unique case(i_req.addr)
        DOMAIN_M_ADDR + 32'h0: begin
          o_domaincfg[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_domaincfg_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h0: begin
          o_domaincfg[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_domaincfg_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4: begin
          o_sourcecfg[M_DOMAIN][1][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4: begin
          o_sourcecfg[S_DOMAIN][1][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h8: begin
          o_sourcecfg[M_DOMAIN][2][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h8: begin
          o_sourcecfg[S_DOMAIN][2][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc: begin
          o_sourcecfg[M_DOMAIN][3][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc: begin
          o_sourcecfg[S_DOMAIN][3][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h10: begin
          o_sourcecfg[M_DOMAIN][4][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h10: begin
          o_sourcecfg[S_DOMAIN][4][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h14: begin
          o_sourcecfg[M_DOMAIN][5][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h14: begin
          o_sourcecfg[S_DOMAIN][5][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h18: begin
          o_sourcecfg[M_DOMAIN][6][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h18: begin
          o_sourcecfg[S_DOMAIN][6][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c: begin
          o_sourcecfg[M_DOMAIN][7][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c: begin
          o_sourcecfg[S_DOMAIN][7][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h20: begin
          o_sourcecfg[M_DOMAIN][8][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h20: begin
          o_sourcecfg[S_DOMAIN][8][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h24: begin
          o_sourcecfg[M_DOMAIN][9][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h24: begin
          o_sourcecfg[S_DOMAIN][9][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h28: begin
          o_sourcecfg[M_DOMAIN][10][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h28: begin
          o_sourcecfg[S_DOMAIN][10][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c: begin
          o_sourcecfg[M_DOMAIN][11][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c: begin
          o_sourcecfg[S_DOMAIN][11][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30: begin
          o_sourcecfg[M_DOMAIN][12][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30: begin
          o_sourcecfg[S_DOMAIN][12][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h34: begin
          o_sourcecfg[M_DOMAIN][13][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h34: begin
          o_sourcecfg[S_DOMAIN][13][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h38: begin
          o_sourcecfg[M_DOMAIN][14][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h38: begin
          o_sourcecfg[S_DOMAIN][14][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c: begin
          o_sourcecfg[M_DOMAIN][15][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c: begin
          o_sourcecfg[S_DOMAIN][15][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h40: begin
          o_sourcecfg[M_DOMAIN][16][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h40: begin
          o_sourcecfg[S_DOMAIN][16][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h44: begin
          o_sourcecfg[M_DOMAIN][17][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h44: begin
          o_sourcecfg[S_DOMAIN][17][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h48: begin
          o_sourcecfg[M_DOMAIN][18][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h48: begin
          o_sourcecfg[S_DOMAIN][18][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4c: begin
          o_sourcecfg[M_DOMAIN][19][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4c: begin
          o_sourcecfg[S_DOMAIN][19][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h50: begin
          o_sourcecfg[M_DOMAIN][20][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h50: begin
          o_sourcecfg[S_DOMAIN][20][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h54: begin
          o_sourcecfg[M_DOMAIN][21][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h54: begin
          o_sourcecfg[S_DOMAIN][21][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h58: begin
          o_sourcecfg[M_DOMAIN][22][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h58: begin
          o_sourcecfg[S_DOMAIN][22][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h5c: begin
          o_sourcecfg[M_DOMAIN][23][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h5c: begin
          o_sourcecfg[S_DOMAIN][23][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h60: begin
          o_sourcecfg[M_DOMAIN][24][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h60: begin
          o_sourcecfg[S_DOMAIN][24][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h64: begin
          o_sourcecfg[M_DOMAIN][25][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h64: begin
          o_sourcecfg[S_DOMAIN][25][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h68: begin
          o_sourcecfg[M_DOMAIN][26][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h68: begin
          o_sourcecfg[S_DOMAIN][26][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h6c: begin
          o_sourcecfg[M_DOMAIN][27][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h6c: begin
          o_sourcecfg[S_DOMAIN][27][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h70: begin
          o_sourcecfg[M_DOMAIN][28][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h70: begin
          o_sourcecfg[S_DOMAIN][28][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h74: begin
          o_sourcecfg[M_DOMAIN][29][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h74: begin
          o_sourcecfg[S_DOMAIN][29][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h78: begin
          o_sourcecfg[M_DOMAIN][30][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h78: begin
          o_sourcecfg[S_DOMAIN][30][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h7c: begin
          o_sourcecfg[M_DOMAIN][31][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h7c: begin
          o_sourcecfg[S_DOMAIN][31][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc0: begin
          o_mmsiaddrcfg[0][31:0]     = i_req.wdata[31:0];
          o_mmsiaddrcfg_we[0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc4: begin
          o_mmsiaddrcfgh[0][31:0]     = i_req.wdata[31:0];
          o_mmsiaddrcfgh_we[0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc8: begin
          o_smsiaddrcfg[0][31:0]     = i_req.wdata[31:0];
          o_smsiaddrcfg_we[0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bcc: begin
          o_smsiaddrcfgh[0][31:0]     = i_req.wdata[31:0];
          o_smsiaddrcfgh_we[0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c00: begin
          o_setip[M_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c00: begin
          o_setip[S_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1cdc: begin
          o_setipnum[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setipnum_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1cdc: begin
          o_setipnum[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setipnum_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d00: begin
          o_in_clrip[M_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d00: begin
          o_in_clrip[S_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1ddc: begin
          o_clripnum[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_clripnum_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1ddc: begin
          o_clripnum[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_clripnum_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e00: begin
          o_setie[M_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e00: begin
          o_setie[S_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1edc: begin
          o_setienum[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setienum_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1edc: begin
          o_setienum[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setienum_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f00: begin
          o_clrie[M_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_clrie_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f00: begin
          o_clrie[S_DOMAIN][0][31:0]     = i_req.wdata[31:0];
          o_clrie_we[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1fdc: begin
          o_clrienum[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_clrienum_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1fdc: begin
          o_clrienum[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_clrienum_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2000: begin
          o_setipnum_le[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setipnum_le_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2000: begin
          o_setipnum_le[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setipnum_le_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2004: begin
          o_setipnum_be[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setipnum_be_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2004: begin
          o_setipnum_be[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_setipnum_be_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3000: begin
          o_genmsi[M_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_genmsi_we[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3000: begin
          o_genmsi[S_DOMAIN][31:0]     = i_req.wdata[31:0];
          o_genmsi_we[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3004: begin
          o_target[M_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3004: begin
          o_target[S_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3008: begin
          o_target[M_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3008: begin
          o_target[S_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h300c: begin
          o_target[M_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h300c: begin
          o_target[S_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3010: begin
          o_target[M_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3010: begin
          o_target[S_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3014: begin
          o_target[M_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3014: begin
          o_target[S_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3018: begin
          o_target[M_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3018: begin
          o_target[S_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h301c: begin
          o_target[M_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h301c: begin
          o_target[S_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3020: begin
          o_target[M_DOMAIN][8][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3020: begin
          o_target[S_DOMAIN][8][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3024: begin
          o_target[M_DOMAIN][9][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3024: begin
          o_target[S_DOMAIN][9][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3028: begin
          o_target[M_DOMAIN][10][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3028: begin
          o_target[S_DOMAIN][10][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h302c: begin
          o_target[M_DOMAIN][11][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h302c: begin
          o_target[S_DOMAIN][11][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3030: begin
          o_target[M_DOMAIN][12][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3030: begin
          o_target[S_DOMAIN][12][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3034: begin
          o_target[M_DOMAIN][13][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3034: begin
          o_target[S_DOMAIN][13][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3038: begin
          o_target[M_DOMAIN][14][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3038: begin
          o_target[S_DOMAIN][14][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h303c: begin
          o_target[M_DOMAIN][15][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h303c: begin
          o_target[S_DOMAIN][15][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3040: begin
          o_target[M_DOMAIN][16][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3040: begin
          o_target[S_DOMAIN][16][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3044: begin
          o_target[M_DOMAIN][17][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3044: begin
          o_target[S_DOMAIN][17][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3048: begin
          o_target[M_DOMAIN][18][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3048: begin
          o_target[S_DOMAIN][18][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h304c: begin
          o_target[M_DOMAIN][19][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h304c: begin
          o_target[S_DOMAIN][19][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3050: begin
          o_target[M_DOMAIN][20][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3050: begin
          o_target[S_DOMAIN][20][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3054: begin
          o_target[M_DOMAIN][21][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3054: begin
          o_target[S_DOMAIN][21][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3058: begin
          o_target[M_DOMAIN][22][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3058: begin
          o_target[S_DOMAIN][22][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h305c: begin
          o_target[M_DOMAIN][23][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h305c: begin
          o_target[S_DOMAIN][23][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3060: begin
          o_target[M_DOMAIN][24][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3060: begin
          o_target[S_DOMAIN][24][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3064: begin
          o_target[M_DOMAIN][25][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3064: begin
          o_target[S_DOMAIN][25][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3068: begin
          o_target[M_DOMAIN][26][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3068: begin
          o_target[S_DOMAIN][26][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h306c: begin
          o_target[M_DOMAIN][27][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h306c: begin
          o_target[S_DOMAIN][27][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3070: begin
          o_target[M_DOMAIN][28][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3070: begin
          o_target[S_DOMAIN][28][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3074: begin
          o_target[M_DOMAIN][29][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3074: begin
          o_target[S_DOMAIN][29][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3078: begin
          o_target[M_DOMAIN][30][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3078: begin
          o_target[S_DOMAIN][30][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h307c: begin
          o_target[M_DOMAIN][31][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h307c: begin
          o_target[S_DOMAIN][31][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4000: begin
          o_idelivery[M_DOMAIN][0][0:0]     = i_req.wdata[0:0];
          o_idelivery_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4000: begin
          o_idelivery[S_DOMAIN][0][0:0]     = i_req.wdata[0:0];
          o_idelivery_we[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4004: begin
          o_iforce[M_DOMAIN][0][0:0]     = i_req.wdata[0:0];
          o_iforce_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4004: begin
          o_iforce[S_DOMAIN][0][0:0]     = i_req.wdata[0:0];
          o_iforce_we[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4008: begin
          o_ithreshold[M_DOMAIN][0][IPRIOLEN-1:0]     = i_req.wdata[IPRIOLEN-1:0];
          o_ithreshold_we[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4008: begin
          o_ithreshold[S_DOMAIN][0][IPRIOLEN-1:0]     = i_req.wdata[IPRIOLEN-1:0];
          o_ithreshold_we[S_DOMAIN][0]      = 1'b1;
        end
        default: o_resp.error = 1'b1;
      endcase
    end else begin
      unique case(i_req.addr)
        DOMAIN_M_ADDR + 32'h0: begin
          o_resp.rdata[31:0]     = i_domaincfg[M_DOMAIN][31:0];
          o_domaincfg_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h0: begin
          o_resp.rdata[31:0]     = i_domaincfg[S_DOMAIN][31:0];
          o_domaincfg_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][1][10:0];
          o_sourcecfg_re[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][1][10:0];
          o_sourcecfg_re[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][2][10:0];
          o_sourcecfg_re[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][2][10:0];
          o_sourcecfg_re[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][3][10:0];
          o_sourcecfg_re[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][3][10:0];
          o_sourcecfg_re[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h10: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][4][10:0];
          o_sourcecfg_re[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h10: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][4][10:0];
          o_sourcecfg_re[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h14: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][5][10:0];
          o_sourcecfg_re[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h14: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][5][10:0];
          o_sourcecfg_re[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h18: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][6][10:0];
          o_sourcecfg_re[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h18: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][6][10:0];
          o_sourcecfg_re[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][7][10:0];
          o_sourcecfg_re[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][7][10:0];
          o_sourcecfg_re[S_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h20: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][8][10:0];
          o_sourcecfg_re[M_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h20: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][8][10:0];
          o_sourcecfg_re[S_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h24: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][9][10:0];
          o_sourcecfg_re[M_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h24: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][9][10:0];
          o_sourcecfg_re[S_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h28: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][10][10:0];
          o_sourcecfg_re[M_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h28: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][10][10:0];
          o_sourcecfg_re[S_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][11][10:0];
          o_sourcecfg_re[M_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][11][10:0];
          o_sourcecfg_re[S_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][12][10:0];
          o_sourcecfg_re[M_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][12][10:0];
          o_sourcecfg_re[S_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h34: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][13][10:0];
          o_sourcecfg_re[M_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h34: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][13][10:0];
          o_sourcecfg_re[S_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h38: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][14][10:0];
          o_sourcecfg_re[M_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h38: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][14][10:0];
          o_sourcecfg_re[S_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][15][10:0];
          o_sourcecfg_re[M_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][15][10:0];
          o_sourcecfg_re[S_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h40: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][16][10:0];
          o_sourcecfg_re[M_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h40: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][16][10:0];
          o_sourcecfg_re[S_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h44: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][17][10:0];
          o_sourcecfg_re[M_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h44: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][17][10:0];
          o_sourcecfg_re[S_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h48: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][18][10:0];
          o_sourcecfg_re[M_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h48: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][18][10:0];
          o_sourcecfg_re[S_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][19][10:0];
          o_sourcecfg_re[M_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][19][10:0];
          o_sourcecfg_re[S_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h50: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][20][10:0];
          o_sourcecfg_re[M_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h50: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][20][10:0];
          o_sourcecfg_re[S_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h54: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][21][10:0];
          o_sourcecfg_re[M_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h54: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][21][10:0];
          o_sourcecfg_re[S_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h58: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][22][10:0];
          o_sourcecfg_re[M_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h58: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][22][10:0];
          o_sourcecfg_re[S_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h5c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][23][10:0];
          o_sourcecfg_re[M_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h5c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][23][10:0];
          o_sourcecfg_re[S_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h60: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][24][10:0];
          o_sourcecfg_re[M_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h60: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][24][10:0];
          o_sourcecfg_re[S_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h64: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][25][10:0];
          o_sourcecfg_re[M_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h64: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][25][10:0];
          o_sourcecfg_re[S_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h68: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][26][10:0];
          o_sourcecfg_re[M_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h68: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][26][10:0];
          o_sourcecfg_re[S_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h6c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][27][10:0];
          o_sourcecfg_re[M_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h6c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][27][10:0];
          o_sourcecfg_re[S_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h70: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][28][10:0];
          o_sourcecfg_re[M_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h70: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][28][10:0];
          o_sourcecfg_re[S_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h74: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][29][10:0];
          o_sourcecfg_re[M_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h74: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][29][10:0];
          o_sourcecfg_re[S_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h78: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][30][10:0];
          o_sourcecfg_re[M_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h78: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][30][10:0];
          o_sourcecfg_re[S_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h7c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][31][10:0];
          o_sourcecfg_re[M_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h7c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][31][10:0];
          o_sourcecfg_re[S_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc0: begin
          o_resp.rdata[31:0]     = i_mmsiaddrcfg[0][31:0];
          o_mmsiaddrcfg_re      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc4: begin
          o_resp.rdata[31:0]     = i_mmsiaddrcfgh[0][31:0];
          o_mmsiaddrcfgh_re      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc8: begin
          o_resp.rdata[31:0]     = i_smsiaddrcfg[0][31:0];
          o_smsiaddrcfg_re      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bcc: begin
          o_resp.rdata[31:0]     = i_smsiaddrcfgh[0][31:0];
          o_smsiaddrcfgh_re      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c00: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][0][31:0];
          o_setip_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c00: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][0][31:0];
          o_setip_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1cdc: begin
          o_resp.rdata[31:0]     = i_setipnum[M_DOMAIN][31:0];
          o_setipnum_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1cdc: begin
          o_resp.rdata[31:0]     = i_setipnum[S_DOMAIN][31:0];
          o_setipnum_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d00: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][0][31:0];
          o_in_clrip_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d00: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][0][31:0];
          o_in_clrip_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1ddc: begin
          o_resp.rdata[31:0]     = i_clripnum[M_DOMAIN][31:0];
          o_clripnum_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1ddc: begin
          o_resp.rdata[31:0]     = i_clripnum[S_DOMAIN][31:0];
          o_clripnum_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e00: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][0][31:0];
          o_setie_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e00: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][0][31:0];
          o_setie_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1edc: begin
          o_resp.rdata[31:0]     = i_setienum[M_DOMAIN][31:0];
          o_setienum_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1edc: begin
          o_resp.rdata[31:0]     = i_setienum[S_DOMAIN][31:0];
          o_setienum_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f00: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][0][31:0];
          o_clrie_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f00: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][0][31:0];
          o_clrie_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1fdc: begin
          o_resp.rdata[31:0]     = i_clrienum[M_DOMAIN][31:0];
          o_clrienum_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1fdc: begin
          o_resp.rdata[31:0]     = i_clrienum[S_DOMAIN][31:0];
          o_clrienum_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2000: begin
          o_resp.rdata[31:0]     = i_setipnum_le[M_DOMAIN][31:0];
          o_setipnum_le_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2000: begin
          o_resp.rdata[31:0]     = i_setipnum_le[S_DOMAIN][31:0];
          o_setipnum_le_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2004: begin
          o_resp.rdata[31:0]     = i_setipnum_be[M_DOMAIN][31:0];
          o_setipnum_be_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2004: begin
          o_resp.rdata[31:0]     = i_setipnum_be[S_DOMAIN][31:0];
          o_setipnum_be_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3000: begin
          o_resp.rdata[31:0]     = i_genmsi[M_DOMAIN][31:0];
          o_genmsi_re[M_DOMAIN]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3000: begin
          o_resp.rdata[31:0]     = i_genmsi[S_DOMAIN][31:0];
          o_genmsi_re[S_DOMAIN]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3004: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][1][31:0];
          o_target_re[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3004: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][1][31:0];
          o_target_re[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3008: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][2][31:0];
          o_target_re[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3008: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][2][31:0];
          o_target_re[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h300c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][3][31:0];
          o_target_re[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h300c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][3][31:0];
          o_target_re[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3010: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][4][31:0];
          o_target_re[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3010: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][4][31:0];
          o_target_re[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3014: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][5][31:0];
          o_target_re[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3014: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][5][31:0];
          o_target_re[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3018: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][6][31:0];
          o_target_re[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3018: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][6][31:0];
          o_target_re[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h301c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][7][31:0];
          o_target_re[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h301c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][7][31:0];
          o_target_re[S_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3020: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][8][31:0];
          o_target_re[M_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3020: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][8][31:0];
          o_target_re[S_DOMAIN][8]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3024: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][9][31:0];
          o_target_re[M_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3024: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][9][31:0];
          o_target_re[S_DOMAIN][9]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3028: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][10][31:0];
          o_target_re[M_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3028: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][10][31:0];
          o_target_re[S_DOMAIN][10]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h302c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][11][31:0];
          o_target_re[M_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h302c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][11][31:0];
          o_target_re[S_DOMAIN][11]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3030: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][12][31:0];
          o_target_re[M_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3030: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][12][31:0];
          o_target_re[S_DOMAIN][12]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3034: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][13][31:0];
          o_target_re[M_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3034: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][13][31:0];
          o_target_re[S_DOMAIN][13]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3038: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][14][31:0];
          o_target_re[M_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3038: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][14][31:0];
          o_target_re[S_DOMAIN][14]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h303c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][15][31:0];
          o_target_re[M_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h303c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][15][31:0];
          o_target_re[S_DOMAIN][15]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3040: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][16][31:0];
          o_target_re[M_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3040: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][16][31:0];
          o_target_re[S_DOMAIN][16]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3044: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][17][31:0];
          o_target_re[M_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3044: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][17][31:0];
          o_target_re[S_DOMAIN][17]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3048: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][18][31:0];
          o_target_re[M_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3048: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][18][31:0];
          o_target_re[S_DOMAIN][18]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h304c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][19][31:0];
          o_target_re[M_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h304c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][19][31:0];
          o_target_re[S_DOMAIN][19]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3050: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][20][31:0];
          o_target_re[M_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3050: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][20][31:0];
          o_target_re[S_DOMAIN][20]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3054: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][21][31:0];
          o_target_re[M_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3054: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][21][31:0];
          o_target_re[S_DOMAIN][21]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3058: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][22][31:0];
          o_target_re[M_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3058: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][22][31:0];
          o_target_re[S_DOMAIN][22]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h305c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][23][31:0];
          o_target_re[M_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h305c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][23][31:0];
          o_target_re[S_DOMAIN][23]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3060: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][24][31:0];
          o_target_re[M_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3060: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][24][31:0];
          o_target_re[S_DOMAIN][24]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3064: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][25][31:0];
          o_target_re[M_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3064: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][25][31:0];
          o_target_re[S_DOMAIN][25]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3068: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][26][31:0];
          o_target_re[M_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3068: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][26][31:0];
          o_target_re[S_DOMAIN][26]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h306c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][27][31:0];
          o_target_re[M_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h306c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][27][31:0];
          o_target_re[S_DOMAIN][27]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3070: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][28][31:0];
          o_target_re[M_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3070: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][28][31:0];
          o_target_re[S_DOMAIN][28]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3074: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][29][31:0];
          o_target_re[M_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3074: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][29][31:0];
          o_target_re[S_DOMAIN][29]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3078: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][30][31:0];
          o_target_re[M_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3078: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][30][31:0];
          o_target_re[S_DOMAIN][30]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h307c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][31][31:0];
          o_target_re[M_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h307c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][31][31:0];
          o_target_re[S_DOMAIN][31]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4000: begin
          o_resp.rdata[0:0]     = i_idelivery[M_DOMAIN][0][0:0];
          o_idelivery_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4000: begin
          o_resp.rdata[0:0]     = i_idelivery[S_DOMAIN][0][0:0];
          o_idelivery_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4004: begin
          o_resp.rdata[0:0]     = i_iforce[M_DOMAIN][0][0:0];
          o_iforce_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4004: begin
          o_resp.rdata[0:0]     = i_iforce[S_DOMAIN][0][0:0];
          o_iforce_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4008: begin
          o_resp.rdata[IPRIOLEN-1:0]     = i_ithreshold[M_DOMAIN][0][IPRIOLEN-1:0];
          o_ithreshold_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4008: begin
          o_resp.rdata[IPRIOLEN-1:0]     = i_ithreshold[S_DOMAIN][0][IPRIOLEN-1:0];
          o_ithreshold_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h4018: begin
          o_resp.rdata[25:0]     = i_topi[M_DOMAIN][0][25:0];
          o_topi_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h4018: begin
          o_resp.rdata[25:0]     = i_topi[S_DOMAIN][0][25:0];
          o_topi_re[S_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h401c: begin
          o_resp.rdata[25:0]     = i_claimi[M_DOMAIN][0][25:0];
          o_claimi_re[M_DOMAIN][0]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h401c: begin
          o_resp.rdata[25:0]     = i_claimi[S_DOMAIN][0][25:0];
          o_claimi_re[S_DOMAIN][0]      = 1'b1;
        end
        default: o_resp.error = 1'b1;
      endcase
    end
  end
end
endmodule

