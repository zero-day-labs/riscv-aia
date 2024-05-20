/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_regmap_minimal #(
   parameter int                                DOMAIN_M_ADDR     = 32'hc000000,
   parameter int                                DOMAIN_S_ADDR     = 32'hd000000,
   parameter int                                NR_SRC            = 256,
   parameter int                                NR_REG            = (NR_SRC-1)/32 ,
   parameter int                                MIN_PRIO          = 6,
   parameter int                                IPRIOLEN          = 3,
   parameter int                                NR_IDCs           = 0,
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
  /* verilator lint_off WIDTHCONCAT */
  o_target                  = '0;
  o_target_we               = '0;
  o_target_re               = '0;

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
        DOMAIN_M_ADDR + 32'h80: begin
          o_sourcecfg[M_DOMAIN][32][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h80: begin
          o_sourcecfg[S_DOMAIN][32][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h84: begin
          o_sourcecfg[M_DOMAIN][33][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h84: begin
          o_sourcecfg[S_DOMAIN][33][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h88: begin
          o_sourcecfg[M_DOMAIN][34][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h88: begin
          o_sourcecfg[S_DOMAIN][34][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h8c: begin
          o_sourcecfg[M_DOMAIN][35][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h8c: begin
          o_sourcecfg[S_DOMAIN][35][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h90: begin
          o_sourcecfg[M_DOMAIN][36][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h90: begin
          o_sourcecfg[S_DOMAIN][36][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h94: begin
          o_sourcecfg[M_DOMAIN][37][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h94: begin
          o_sourcecfg[S_DOMAIN][37][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h98: begin
          o_sourcecfg[M_DOMAIN][38][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h98: begin
          o_sourcecfg[S_DOMAIN][38][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h9c: begin
          o_sourcecfg[M_DOMAIN][39][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h9c: begin
          o_sourcecfg[S_DOMAIN][39][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'ha0: begin
          o_sourcecfg[M_DOMAIN][40][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'ha0: begin
          o_sourcecfg[S_DOMAIN][40][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'ha4: begin
          o_sourcecfg[M_DOMAIN][41][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'ha4: begin
          o_sourcecfg[S_DOMAIN][41][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'ha8: begin
          o_sourcecfg[M_DOMAIN][42][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'ha8: begin
          o_sourcecfg[S_DOMAIN][42][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hac: begin
          o_sourcecfg[M_DOMAIN][43][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hac: begin
          o_sourcecfg[S_DOMAIN][43][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hb0: begin
          o_sourcecfg[M_DOMAIN][44][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hb0: begin
          o_sourcecfg[S_DOMAIN][44][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hb4: begin
          o_sourcecfg[M_DOMAIN][45][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hb4: begin
          o_sourcecfg[S_DOMAIN][45][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hb8: begin
          o_sourcecfg[M_DOMAIN][46][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hb8: begin
          o_sourcecfg[S_DOMAIN][46][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hbc: begin
          o_sourcecfg[M_DOMAIN][47][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hbc: begin
          o_sourcecfg[S_DOMAIN][47][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc0: begin
          o_sourcecfg[M_DOMAIN][48][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc0: begin
          o_sourcecfg[S_DOMAIN][48][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc4: begin
          o_sourcecfg[M_DOMAIN][49][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc4: begin
          o_sourcecfg[S_DOMAIN][49][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc8: begin
          o_sourcecfg[M_DOMAIN][50][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc8: begin
          o_sourcecfg[S_DOMAIN][50][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hcc: begin
          o_sourcecfg[M_DOMAIN][51][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hcc: begin
          o_sourcecfg[S_DOMAIN][51][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hd0: begin
          o_sourcecfg[M_DOMAIN][52][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hd0: begin
          o_sourcecfg[S_DOMAIN][52][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hd4: begin
          o_sourcecfg[M_DOMAIN][53][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hd4: begin
          o_sourcecfg[S_DOMAIN][53][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hd8: begin
          o_sourcecfg[M_DOMAIN][54][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hd8: begin
          o_sourcecfg[S_DOMAIN][54][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hdc: begin
          o_sourcecfg[M_DOMAIN][55][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hdc: begin
          o_sourcecfg[S_DOMAIN][55][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'he0: begin
          o_sourcecfg[M_DOMAIN][56][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'he0: begin
          o_sourcecfg[S_DOMAIN][56][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'he4: begin
          o_sourcecfg[M_DOMAIN][57][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'he4: begin
          o_sourcecfg[S_DOMAIN][57][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'he8: begin
          o_sourcecfg[M_DOMAIN][58][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'he8: begin
          o_sourcecfg[S_DOMAIN][58][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hec: begin
          o_sourcecfg[M_DOMAIN][59][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hec: begin
          o_sourcecfg[S_DOMAIN][59][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hf0: begin
          o_sourcecfg[M_DOMAIN][60][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hf0: begin
          o_sourcecfg[S_DOMAIN][60][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hf4: begin
          o_sourcecfg[M_DOMAIN][61][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hf4: begin
          o_sourcecfg[S_DOMAIN][61][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hf8: begin
          o_sourcecfg[M_DOMAIN][62][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hf8: begin
          o_sourcecfg[S_DOMAIN][62][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hfc: begin
          o_sourcecfg[M_DOMAIN][63][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hfc: begin
          o_sourcecfg[S_DOMAIN][63][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h100: begin
          o_sourcecfg[M_DOMAIN][64][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h100: begin
          o_sourcecfg[S_DOMAIN][64][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h104: begin
          o_sourcecfg[M_DOMAIN][65][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h104: begin
          o_sourcecfg[S_DOMAIN][65][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h108: begin
          o_sourcecfg[M_DOMAIN][66][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h108: begin
          o_sourcecfg[S_DOMAIN][66][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h10c: begin
          o_sourcecfg[M_DOMAIN][67][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h10c: begin
          o_sourcecfg[S_DOMAIN][67][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h110: begin
          o_sourcecfg[M_DOMAIN][68][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h110: begin
          o_sourcecfg[S_DOMAIN][68][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h114: begin
          o_sourcecfg[M_DOMAIN][69][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h114: begin
          o_sourcecfg[S_DOMAIN][69][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h118: begin
          o_sourcecfg[M_DOMAIN][70][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h118: begin
          o_sourcecfg[S_DOMAIN][70][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h11c: begin
          o_sourcecfg[M_DOMAIN][71][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h11c: begin
          o_sourcecfg[S_DOMAIN][71][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h120: begin
          o_sourcecfg[M_DOMAIN][72][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h120: begin
          o_sourcecfg[S_DOMAIN][72][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h124: begin
          o_sourcecfg[M_DOMAIN][73][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h124: begin
          o_sourcecfg[S_DOMAIN][73][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h128: begin
          o_sourcecfg[M_DOMAIN][74][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h128: begin
          o_sourcecfg[S_DOMAIN][74][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h12c: begin
          o_sourcecfg[M_DOMAIN][75][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h12c: begin
          o_sourcecfg[S_DOMAIN][75][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h130: begin
          o_sourcecfg[M_DOMAIN][76][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h130: begin
          o_sourcecfg[S_DOMAIN][76][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h134: begin
          o_sourcecfg[M_DOMAIN][77][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h134: begin
          o_sourcecfg[S_DOMAIN][77][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h138: begin
          o_sourcecfg[M_DOMAIN][78][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h138: begin
          o_sourcecfg[S_DOMAIN][78][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h13c: begin
          o_sourcecfg[M_DOMAIN][79][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h13c: begin
          o_sourcecfg[S_DOMAIN][79][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h140: begin
          o_sourcecfg[M_DOMAIN][80][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h140: begin
          o_sourcecfg[S_DOMAIN][80][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h144: begin
          o_sourcecfg[M_DOMAIN][81][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h144: begin
          o_sourcecfg[S_DOMAIN][81][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h148: begin
          o_sourcecfg[M_DOMAIN][82][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h148: begin
          o_sourcecfg[S_DOMAIN][82][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h14c: begin
          o_sourcecfg[M_DOMAIN][83][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h14c: begin
          o_sourcecfg[S_DOMAIN][83][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h150: begin
          o_sourcecfg[M_DOMAIN][84][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h150: begin
          o_sourcecfg[S_DOMAIN][84][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h154: begin
          o_sourcecfg[M_DOMAIN][85][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h154: begin
          o_sourcecfg[S_DOMAIN][85][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h158: begin
          o_sourcecfg[M_DOMAIN][86][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h158: begin
          o_sourcecfg[S_DOMAIN][86][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h15c: begin
          o_sourcecfg[M_DOMAIN][87][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h15c: begin
          o_sourcecfg[S_DOMAIN][87][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h160: begin
          o_sourcecfg[M_DOMAIN][88][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h160: begin
          o_sourcecfg[S_DOMAIN][88][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h164: begin
          o_sourcecfg[M_DOMAIN][89][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h164: begin
          o_sourcecfg[S_DOMAIN][89][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h168: begin
          o_sourcecfg[M_DOMAIN][90][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h168: begin
          o_sourcecfg[S_DOMAIN][90][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h16c: begin
          o_sourcecfg[M_DOMAIN][91][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h16c: begin
          o_sourcecfg[S_DOMAIN][91][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h170: begin
          o_sourcecfg[M_DOMAIN][92][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h170: begin
          o_sourcecfg[S_DOMAIN][92][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h174: begin
          o_sourcecfg[M_DOMAIN][93][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h174: begin
          o_sourcecfg[S_DOMAIN][93][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h178: begin
          o_sourcecfg[M_DOMAIN][94][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h178: begin
          o_sourcecfg[S_DOMAIN][94][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h17c: begin
          o_sourcecfg[M_DOMAIN][95][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h17c: begin
          o_sourcecfg[S_DOMAIN][95][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h180: begin
          o_sourcecfg[M_DOMAIN][96][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h180: begin
          o_sourcecfg[S_DOMAIN][96][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h184: begin
          o_sourcecfg[M_DOMAIN][97][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h184: begin
          o_sourcecfg[S_DOMAIN][97][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h188: begin
          o_sourcecfg[M_DOMAIN][98][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h188: begin
          o_sourcecfg[S_DOMAIN][98][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h18c: begin
          o_sourcecfg[M_DOMAIN][99][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h18c: begin
          o_sourcecfg[S_DOMAIN][99][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h190: begin
          o_sourcecfg[M_DOMAIN][100][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h190: begin
          o_sourcecfg[S_DOMAIN][100][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h194: begin
          o_sourcecfg[M_DOMAIN][101][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h194: begin
          o_sourcecfg[S_DOMAIN][101][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h198: begin
          o_sourcecfg[M_DOMAIN][102][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h198: begin
          o_sourcecfg[S_DOMAIN][102][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h19c: begin
          o_sourcecfg[M_DOMAIN][103][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h19c: begin
          o_sourcecfg[S_DOMAIN][103][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1a0: begin
          o_sourcecfg[M_DOMAIN][104][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1a0: begin
          o_sourcecfg[S_DOMAIN][104][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1a4: begin
          o_sourcecfg[M_DOMAIN][105][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1a4: begin
          o_sourcecfg[S_DOMAIN][105][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1a8: begin
          o_sourcecfg[M_DOMAIN][106][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1a8: begin
          o_sourcecfg[S_DOMAIN][106][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1ac: begin
          o_sourcecfg[M_DOMAIN][107][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1ac: begin
          o_sourcecfg[S_DOMAIN][107][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1b0: begin
          o_sourcecfg[M_DOMAIN][108][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1b0: begin
          o_sourcecfg[S_DOMAIN][108][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1b4: begin
          o_sourcecfg[M_DOMAIN][109][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1b4: begin
          o_sourcecfg[S_DOMAIN][109][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1b8: begin
          o_sourcecfg[M_DOMAIN][110][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1b8: begin
          o_sourcecfg[S_DOMAIN][110][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc: begin
          o_sourcecfg[M_DOMAIN][111][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1bc: begin
          o_sourcecfg[S_DOMAIN][111][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c0: begin
          o_sourcecfg[M_DOMAIN][112][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c0: begin
          o_sourcecfg[S_DOMAIN][112][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c4: begin
          o_sourcecfg[M_DOMAIN][113][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c4: begin
          o_sourcecfg[S_DOMAIN][113][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c8: begin
          o_sourcecfg[M_DOMAIN][114][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c8: begin
          o_sourcecfg[S_DOMAIN][114][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1cc: begin
          o_sourcecfg[M_DOMAIN][115][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1cc: begin
          o_sourcecfg[S_DOMAIN][115][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d0: begin
          o_sourcecfg[M_DOMAIN][116][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d0: begin
          o_sourcecfg[S_DOMAIN][116][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d4: begin
          o_sourcecfg[M_DOMAIN][117][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d4: begin
          o_sourcecfg[S_DOMAIN][117][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d8: begin
          o_sourcecfg[M_DOMAIN][118][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d8: begin
          o_sourcecfg[S_DOMAIN][118][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1dc: begin
          o_sourcecfg[M_DOMAIN][119][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1dc: begin
          o_sourcecfg[S_DOMAIN][119][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e0: begin
          o_sourcecfg[M_DOMAIN][120][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e0: begin
          o_sourcecfg[S_DOMAIN][120][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e4: begin
          o_sourcecfg[M_DOMAIN][121][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e4: begin
          o_sourcecfg[S_DOMAIN][121][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e8: begin
          o_sourcecfg[M_DOMAIN][122][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e8: begin
          o_sourcecfg[S_DOMAIN][122][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1ec: begin
          o_sourcecfg[M_DOMAIN][123][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1ec: begin
          o_sourcecfg[S_DOMAIN][123][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f0: begin
          o_sourcecfg[M_DOMAIN][124][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f0: begin
          o_sourcecfg[S_DOMAIN][124][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f4: begin
          o_sourcecfg[M_DOMAIN][125][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f4: begin
          o_sourcecfg[S_DOMAIN][125][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f8: begin
          o_sourcecfg[M_DOMAIN][126][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f8: begin
          o_sourcecfg[S_DOMAIN][126][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1fc: begin
          o_sourcecfg[M_DOMAIN][127][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1fc: begin
          o_sourcecfg[S_DOMAIN][127][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h200: begin
          o_sourcecfg[M_DOMAIN][128][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h200: begin
          o_sourcecfg[S_DOMAIN][128][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h204: begin
          o_sourcecfg[M_DOMAIN][129][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h204: begin
          o_sourcecfg[S_DOMAIN][129][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h208: begin
          o_sourcecfg[M_DOMAIN][130][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h208: begin
          o_sourcecfg[S_DOMAIN][130][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h20c: begin
          o_sourcecfg[M_DOMAIN][131][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h20c: begin
          o_sourcecfg[S_DOMAIN][131][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h210: begin
          o_sourcecfg[M_DOMAIN][132][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h210: begin
          o_sourcecfg[S_DOMAIN][132][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h214: begin
          o_sourcecfg[M_DOMAIN][133][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h214: begin
          o_sourcecfg[S_DOMAIN][133][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h218: begin
          o_sourcecfg[M_DOMAIN][134][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h218: begin
          o_sourcecfg[S_DOMAIN][134][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h21c: begin
          o_sourcecfg[M_DOMAIN][135][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h21c: begin
          o_sourcecfg[S_DOMAIN][135][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h220: begin
          o_sourcecfg[M_DOMAIN][136][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h220: begin
          o_sourcecfg[S_DOMAIN][136][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h224: begin
          o_sourcecfg[M_DOMAIN][137][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h224: begin
          o_sourcecfg[S_DOMAIN][137][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h228: begin
          o_sourcecfg[M_DOMAIN][138][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h228: begin
          o_sourcecfg[S_DOMAIN][138][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h22c: begin
          o_sourcecfg[M_DOMAIN][139][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h22c: begin
          o_sourcecfg[S_DOMAIN][139][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h230: begin
          o_sourcecfg[M_DOMAIN][140][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h230: begin
          o_sourcecfg[S_DOMAIN][140][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h234: begin
          o_sourcecfg[M_DOMAIN][141][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h234: begin
          o_sourcecfg[S_DOMAIN][141][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h238: begin
          o_sourcecfg[M_DOMAIN][142][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h238: begin
          o_sourcecfg[S_DOMAIN][142][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h23c: begin
          o_sourcecfg[M_DOMAIN][143][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h23c: begin
          o_sourcecfg[S_DOMAIN][143][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h240: begin
          o_sourcecfg[M_DOMAIN][144][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h240: begin
          o_sourcecfg[S_DOMAIN][144][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h244: begin
          o_sourcecfg[M_DOMAIN][145][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h244: begin
          o_sourcecfg[S_DOMAIN][145][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h248: begin
          o_sourcecfg[M_DOMAIN][146][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h248: begin
          o_sourcecfg[S_DOMAIN][146][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h24c: begin
          o_sourcecfg[M_DOMAIN][147][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h24c: begin
          o_sourcecfg[S_DOMAIN][147][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h250: begin
          o_sourcecfg[M_DOMAIN][148][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h250: begin
          o_sourcecfg[S_DOMAIN][148][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h254: begin
          o_sourcecfg[M_DOMAIN][149][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h254: begin
          o_sourcecfg[S_DOMAIN][149][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h258: begin
          o_sourcecfg[M_DOMAIN][150][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h258: begin
          o_sourcecfg[S_DOMAIN][150][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h25c: begin
          o_sourcecfg[M_DOMAIN][151][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h25c: begin
          o_sourcecfg[S_DOMAIN][151][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h260: begin
          o_sourcecfg[M_DOMAIN][152][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h260: begin
          o_sourcecfg[S_DOMAIN][152][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h264: begin
          o_sourcecfg[M_DOMAIN][153][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h264: begin
          o_sourcecfg[S_DOMAIN][153][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h268: begin
          o_sourcecfg[M_DOMAIN][154][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h268: begin
          o_sourcecfg[S_DOMAIN][154][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h26c: begin
          o_sourcecfg[M_DOMAIN][155][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h26c: begin
          o_sourcecfg[S_DOMAIN][155][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h270: begin
          o_sourcecfg[M_DOMAIN][156][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h270: begin
          o_sourcecfg[S_DOMAIN][156][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h274: begin
          o_sourcecfg[M_DOMAIN][157][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h274: begin
          o_sourcecfg[S_DOMAIN][157][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h278: begin
          o_sourcecfg[M_DOMAIN][158][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h278: begin
          o_sourcecfg[S_DOMAIN][158][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h27c: begin
          o_sourcecfg[M_DOMAIN][159][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h27c: begin
          o_sourcecfg[S_DOMAIN][159][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h280: begin
          o_sourcecfg[M_DOMAIN][160][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h280: begin
          o_sourcecfg[S_DOMAIN][160][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h284: begin
          o_sourcecfg[M_DOMAIN][161][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h284: begin
          o_sourcecfg[S_DOMAIN][161][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h288: begin
          o_sourcecfg[M_DOMAIN][162][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h288: begin
          o_sourcecfg[S_DOMAIN][162][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h28c: begin
          o_sourcecfg[M_DOMAIN][163][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h28c: begin
          o_sourcecfg[S_DOMAIN][163][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h290: begin
          o_sourcecfg[M_DOMAIN][164][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h290: begin
          o_sourcecfg[S_DOMAIN][164][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h294: begin
          o_sourcecfg[M_DOMAIN][165][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h294: begin
          o_sourcecfg[S_DOMAIN][165][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h298: begin
          o_sourcecfg[M_DOMAIN][166][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h298: begin
          o_sourcecfg[S_DOMAIN][166][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h29c: begin
          o_sourcecfg[M_DOMAIN][167][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h29c: begin
          o_sourcecfg[S_DOMAIN][167][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2a0: begin
          o_sourcecfg[M_DOMAIN][168][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2a0: begin
          o_sourcecfg[S_DOMAIN][168][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2a4: begin
          o_sourcecfg[M_DOMAIN][169][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2a4: begin
          o_sourcecfg[S_DOMAIN][169][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2a8: begin
          o_sourcecfg[M_DOMAIN][170][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2a8: begin
          o_sourcecfg[S_DOMAIN][170][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2ac: begin
          o_sourcecfg[M_DOMAIN][171][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2ac: begin
          o_sourcecfg[S_DOMAIN][171][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2b0: begin
          o_sourcecfg[M_DOMAIN][172][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2b0: begin
          o_sourcecfg[S_DOMAIN][172][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2b4: begin
          o_sourcecfg[M_DOMAIN][173][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2b4: begin
          o_sourcecfg[S_DOMAIN][173][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2b8: begin
          o_sourcecfg[M_DOMAIN][174][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2b8: begin
          o_sourcecfg[S_DOMAIN][174][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2bc: begin
          o_sourcecfg[M_DOMAIN][175][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2bc: begin
          o_sourcecfg[S_DOMAIN][175][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c0: begin
          o_sourcecfg[M_DOMAIN][176][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c0: begin
          o_sourcecfg[S_DOMAIN][176][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c4: begin
          o_sourcecfg[M_DOMAIN][177][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c4: begin
          o_sourcecfg[S_DOMAIN][177][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c8: begin
          o_sourcecfg[M_DOMAIN][178][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c8: begin
          o_sourcecfg[S_DOMAIN][178][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2cc: begin
          o_sourcecfg[M_DOMAIN][179][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2cc: begin
          o_sourcecfg[S_DOMAIN][179][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2d0: begin
          o_sourcecfg[M_DOMAIN][180][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2d0: begin
          o_sourcecfg[S_DOMAIN][180][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2d4: begin
          o_sourcecfg[M_DOMAIN][181][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2d4: begin
          o_sourcecfg[S_DOMAIN][181][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2d8: begin
          o_sourcecfg[M_DOMAIN][182][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2d8: begin
          o_sourcecfg[S_DOMAIN][182][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2dc: begin
          o_sourcecfg[M_DOMAIN][183][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2dc: begin
          o_sourcecfg[S_DOMAIN][183][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2e0: begin
          o_sourcecfg[M_DOMAIN][184][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2e0: begin
          o_sourcecfg[S_DOMAIN][184][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2e4: begin
          o_sourcecfg[M_DOMAIN][185][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2e4: begin
          o_sourcecfg[S_DOMAIN][185][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2e8: begin
          o_sourcecfg[M_DOMAIN][186][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2e8: begin
          o_sourcecfg[S_DOMAIN][186][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2ec: begin
          o_sourcecfg[M_DOMAIN][187][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2ec: begin
          o_sourcecfg[S_DOMAIN][187][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2f0: begin
          o_sourcecfg[M_DOMAIN][188][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2f0: begin
          o_sourcecfg[S_DOMAIN][188][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2f4: begin
          o_sourcecfg[M_DOMAIN][189][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2f4: begin
          o_sourcecfg[S_DOMAIN][189][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2f8: begin
          o_sourcecfg[M_DOMAIN][190][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2f8: begin
          o_sourcecfg[S_DOMAIN][190][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2fc: begin
          o_sourcecfg[M_DOMAIN][191][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2fc: begin
          o_sourcecfg[S_DOMAIN][191][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h300: begin
          o_sourcecfg[M_DOMAIN][192][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h300: begin
          o_sourcecfg[S_DOMAIN][192][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h304: begin
          o_sourcecfg[M_DOMAIN][193][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h304: begin
          o_sourcecfg[S_DOMAIN][193][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h308: begin
          o_sourcecfg[M_DOMAIN][194][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h308: begin
          o_sourcecfg[S_DOMAIN][194][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c: begin
          o_sourcecfg[M_DOMAIN][195][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c: begin
          o_sourcecfg[S_DOMAIN][195][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h310: begin
          o_sourcecfg[M_DOMAIN][196][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h310: begin
          o_sourcecfg[S_DOMAIN][196][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h314: begin
          o_sourcecfg[M_DOMAIN][197][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h314: begin
          o_sourcecfg[S_DOMAIN][197][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h318: begin
          o_sourcecfg[M_DOMAIN][198][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h318: begin
          o_sourcecfg[S_DOMAIN][198][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c: begin
          o_sourcecfg[M_DOMAIN][199][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c: begin
          o_sourcecfg[S_DOMAIN][199][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h320: begin
          o_sourcecfg[M_DOMAIN][200][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h320: begin
          o_sourcecfg[S_DOMAIN][200][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h324: begin
          o_sourcecfg[M_DOMAIN][201][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h324: begin
          o_sourcecfg[S_DOMAIN][201][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h328: begin
          o_sourcecfg[M_DOMAIN][202][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h328: begin
          o_sourcecfg[S_DOMAIN][202][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c: begin
          o_sourcecfg[M_DOMAIN][203][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c: begin
          o_sourcecfg[S_DOMAIN][203][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h330: begin
          o_sourcecfg[M_DOMAIN][204][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h330: begin
          o_sourcecfg[S_DOMAIN][204][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h334: begin
          o_sourcecfg[M_DOMAIN][205][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h334: begin
          o_sourcecfg[S_DOMAIN][205][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h338: begin
          o_sourcecfg[M_DOMAIN][206][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h338: begin
          o_sourcecfg[S_DOMAIN][206][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c: begin
          o_sourcecfg[M_DOMAIN][207][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c: begin
          o_sourcecfg[S_DOMAIN][207][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h340: begin
          o_sourcecfg[M_DOMAIN][208][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h340: begin
          o_sourcecfg[S_DOMAIN][208][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h344: begin
          o_sourcecfg[M_DOMAIN][209][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h344: begin
          o_sourcecfg[S_DOMAIN][209][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h348: begin
          o_sourcecfg[M_DOMAIN][210][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h348: begin
          o_sourcecfg[S_DOMAIN][210][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h34c: begin
          o_sourcecfg[M_DOMAIN][211][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h34c: begin
          o_sourcecfg[S_DOMAIN][211][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h350: begin
          o_sourcecfg[M_DOMAIN][212][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h350: begin
          o_sourcecfg[S_DOMAIN][212][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h354: begin
          o_sourcecfg[M_DOMAIN][213][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h354: begin
          o_sourcecfg[S_DOMAIN][213][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h358: begin
          o_sourcecfg[M_DOMAIN][214][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h358: begin
          o_sourcecfg[S_DOMAIN][214][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h35c: begin
          o_sourcecfg[M_DOMAIN][215][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h35c: begin
          o_sourcecfg[S_DOMAIN][215][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h360: begin
          o_sourcecfg[M_DOMAIN][216][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h360: begin
          o_sourcecfg[S_DOMAIN][216][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h364: begin
          o_sourcecfg[M_DOMAIN][217][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h364: begin
          o_sourcecfg[S_DOMAIN][217][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h368: begin
          o_sourcecfg[M_DOMAIN][218][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h368: begin
          o_sourcecfg[S_DOMAIN][218][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h36c: begin
          o_sourcecfg[M_DOMAIN][219][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h36c: begin
          o_sourcecfg[S_DOMAIN][219][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h370: begin
          o_sourcecfg[M_DOMAIN][220][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h370: begin
          o_sourcecfg[S_DOMAIN][220][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h374: begin
          o_sourcecfg[M_DOMAIN][221][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h374: begin
          o_sourcecfg[S_DOMAIN][221][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h378: begin
          o_sourcecfg[M_DOMAIN][222][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h378: begin
          o_sourcecfg[S_DOMAIN][222][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h37c: begin
          o_sourcecfg[M_DOMAIN][223][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h37c: begin
          o_sourcecfg[S_DOMAIN][223][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h380: begin
          o_sourcecfg[M_DOMAIN][224][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h380: begin
          o_sourcecfg[S_DOMAIN][224][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h384: begin
          o_sourcecfg[M_DOMAIN][225][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h384: begin
          o_sourcecfg[S_DOMAIN][225][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h388: begin
          o_sourcecfg[M_DOMAIN][226][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h388: begin
          o_sourcecfg[S_DOMAIN][226][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h38c: begin
          o_sourcecfg[M_DOMAIN][227][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h38c: begin
          o_sourcecfg[S_DOMAIN][227][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h390: begin
          o_sourcecfg[M_DOMAIN][228][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h390: begin
          o_sourcecfg[S_DOMAIN][228][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h394: begin
          o_sourcecfg[M_DOMAIN][229][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h394: begin
          o_sourcecfg[S_DOMAIN][229][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h398: begin
          o_sourcecfg[M_DOMAIN][230][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h398: begin
          o_sourcecfg[S_DOMAIN][230][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h39c: begin
          o_sourcecfg[M_DOMAIN][231][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h39c: begin
          o_sourcecfg[S_DOMAIN][231][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3a0: begin
          o_sourcecfg[M_DOMAIN][232][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3a0: begin
          o_sourcecfg[S_DOMAIN][232][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3a4: begin
          o_sourcecfg[M_DOMAIN][233][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3a4: begin
          o_sourcecfg[S_DOMAIN][233][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3a8: begin
          o_sourcecfg[M_DOMAIN][234][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3a8: begin
          o_sourcecfg[S_DOMAIN][234][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3ac: begin
          o_sourcecfg[M_DOMAIN][235][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3ac: begin
          o_sourcecfg[S_DOMAIN][235][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3b0: begin
          o_sourcecfg[M_DOMAIN][236][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3b0: begin
          o_sourcecfg[S_DOMAIN][236][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3b4: begin
          o_sourcecfg[M_DOMAIN][237][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3b4: begin
          o_sourcecfg[S_DOMAIN][237][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3b8: begin
          o_sourcecfg[M_DOMAIN][238][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3b8: begin
          o_sourcecfg[S_DOMAIN][238][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3bc: begin
          o_sourcecfg[M_DOMAIN][239][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3bc: begin
          o_sourcecfg[S_DOMAIN][239][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c0: begin
          o_sourcecfg[M_DOMAIN][240][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c0: begin
          o_sourcecfg[S_DOMAIN][240][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c4: begin
          o_sourcecfg[M_DOMAIN][241][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c4: begin
          o_sourcecfg[S_DOMAIN][241][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c8: begin
          o_sourcecfg[M_DOMAIN][242][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c8: begin
          o_sourcecfg[S_DOMAIN][242][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3cc: begin
          o_sourcecfg[M_DOMAIN][243][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3cc: begin
          o_sourcecfg[S_DOMAIN][243][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3d0: begin
          o_sourcecfg[M_DOMAIN][244][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3d0: begin
          o_sourcecfg[S_DOMAIN][244][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3d4: begin
          o_sourcecfg[M_DOMAIN][245][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3d4: begin
          o_sourcecfg[S_DOMAIN][245][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3d8: begin
          o_sourcecfg[M_DOMAIN][246][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3d8: begin
          o_sourcecfg[S_DOMAIN][246][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3dc: begin
          o_sourcecfg[M_DOMAIN][247][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3dc: begin
          o_sourcecfg[S_DOMAIN][247][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3e0: begin
          o_sourcecfg[M_DOMAIN][248][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3e0: begin
          o_sourcecfg[S_DOMAIN][248][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3e4: begin
          o_sourcecfg[M_DOMAIN][249][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3e4: begin
          o_sourcecfg[S_DOMAIN][249][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3e8: begin
          o_sourcecfg[M_DOMAIN][250][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3e8: begin
          o_sourcecfg[S_DOMAIN][250][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3ec: begin
          o_sourcecfg[M_DOMAIN][251][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3ec: begin
          o_sourcecfg[S_DOMAIN][251][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3f0: begin
          o_sourcecfg[M_DOMAIN][252][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3f0: begin
          o_sourcecfg[S_DOMAIN][252][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3f4: begin
          o_sourcecfg[M_DOMAIN][253][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3f4: begin
          o_sourcecfg[S_DOMAIN][253][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3f8: begin
          o_sourcecfg[M_DOMAIN][254][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3f8: begin
          o_sourcecfg[S_DOMAIN][254][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3fc: begin
          o_sourcecfg[M_DOMAIN][255][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[M_DOMAIN][255]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3fc: begin
          o_sourcecfg[S_DOMAIN][255][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[S_DOMAIN][255]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1c04: begin
          o_setip[M_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c04: begin
          o_setip[S_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c08: begin
          o_setip[M_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c08: begin
          o_setip[S_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c0c: begin
          o_setip[M_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c0c: begin
          o_setip[S_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c10: begin
          o_setip[M_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c10: begin
          o_setip[S_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c14: begin
          o_setip[M_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c14: begin
          o_setip[S_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c18: begin
          o_setip[M_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c18: begin
          o_setip[S_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c1c: begin
          o_setip[M_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_setip_we[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c1c: begin
          o_setip[S_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_setip_we[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1d04: begin
          o_in_clrip[M_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d04: begin
          o_in_clrip[S_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d08: begin
          o_in_clrip[M_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d08: begin
          o_in_clrip[S_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d0c: begin
          o_in_clrip[M_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d0c: begin
          o_in_clrip[S_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d10: begin
          o_in_clrip[M_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d10: begin
          o_in_clrip[S_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d14: begin
          o_in_clrip[M_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d14: begin
          o_in_clrip[S_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d18: begin
          o_in_clrip[M_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d18: begin
          o_in_clrip[S_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d1c: begin
          o_in_clrip[M_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d1c: begin
          o_in_clrip[S_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1e04: begin
          o_setie[M_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e04: begin
          o_setie[S_DOMAIN][1][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e08: begin
          o_setie[M_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e08: begin
          o_setie[S_DOMAIN][2][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e0c: begin
          o_setie[M_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e0c: begin
          o_setie[S_DOMAIN][3][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e10: begin
          o_setie[M_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e10: begin
          o_setie[S_DOMAIN][4][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e14: begin
          o_setie[M_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e14: begin
          o_setie[S_DOMAIN][5][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e18: begin
          o_setie[M_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e18: begin
          o_setie[S_DOMAIN][6][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e1c: begin
          o_setie[M_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_setie_we[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e1c: begin
          o_setie[S_DOMAIN][7][31:0]     = i_req.wdata[31:0];
          o_setie_we[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h3080: begin
          o_target[M_DOMAIN][32][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3080: begin
          o_target[S_DOMAIN][32][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3084: begin
          o_target[M_DOMAIN][33][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3084: begin
          o_target[S_DOMAIN][33][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3088: begin
          o_target[M_DOMAIN][34][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3088: begin
          o_target[S_DOMAIN][34][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h308c: begin
          o_target[M_DOMAIN][35][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h308c: begin
          o_target[S_DOMAIN][35][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3090: begin
          o_target[M_DOMAIN][36][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3090: begin
          o_target[S_DOMAIN][36][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3094: begin
          o_target[M_DOMAIN][37][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3094: begin
          o_target[S_DOMAIN][37][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3098: begin
          o_target[M_DOMAIN][38][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3098: begin
          o_target[S_DOMAIN][38][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h309c: begin
          o_target[M_DOMAIN][39][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h309c: begin
          o_target[S_DOMAIN][39][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30a0: begin
          o_target[M_DOMAIN][40][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30a0: begin
          o_target[S_DOMAIN][40][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30a4: begin
          o_target[M_DOMAIN][41][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30a4: begin
          o_target[S_DOMAIN][41][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30a8: begin
          o_target[M_DOMAIN][42][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30a8: begin
          o_target[S_DOMAIN][42][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30ac: begin
          o_target[M_DOMAIN][43][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30ac: begin
          o_target[S_DOMAIN][43][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30b0: begin
          o_target[M_DOMAIN][44][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30b0: begin
          o_target[S_DOMAIN][44][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30b4: begin
          o_target[M_DOMAIN][45][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30b4: begin
          o_target[S_DOMAIN][45][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30b8: begin
          o_target[M_DOMAIN][46][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30b8: begin
          o_target[S_DOMAIN][46][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30bc: begin
          o_target[M_DOMAIN][47][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30bc: begin
          o_target[S_DOMAIN][47][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c0: begin
          o_target[M_DOMAIN][48][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c0: begin
          o_target[S_DOMAIN][48][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c4: begin
          o_target[M_DOMAIN][49][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c4: begin
          o_target[S_DOMAIN][49][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c8: begin
          o_target[M_DOMAIN][50][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c8: begin
          o_target[S_DOMAIN][50][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30cc: begin
          o_target[M_DOMAIN][51][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30cc: begin
          o_target[S_DOMAIN][51][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30d0: begin
          o_target[M_DOMAIN][52][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30d0: begin
          o_target[S_DOMAIN][52][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30d4: begin
          o_target[M_DOMAIN][53][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30d4: begin
          o_target[S_DOMAIN][53][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30d8: begin
          o_target[M_DOMAIN][54][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30d8: begin
          o_target[S_DOMAIN][54][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30dc: begin
          o_target[M_DOMAIN][55][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30dc: begin
          o_target[S_DOMAIN][55][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30e0: begin
          o_target[M_DOMAIN][56][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30e0: begin
          o_target[S_DOMAIN][56][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30e4: begin
          o_target[M_DOMAIN][57][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30e4: begin
          o_target[S_DOMAIN][57][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30e8: begin
          o_target[M_DOMAIN][58][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30e8: begin
          o_target[S_DOMAIN][58][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30ec: begin
          o_target[M_DOMAIN][59][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30ec: begin
          o_target[S_DOMAIN][59][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30f0: begin
          o_target[M_DOMAIN][60][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30f0: begin
          o_target[S_DOMAIN][60][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30f4: begin
          o_target[M_DOMAIN][61][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30f4: begin
          o_target[S_DOMAIN][61][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30f8: begin
          o_target[M_DOMAIN][62][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30f8: begin
          o_target[S_DOMAIN][62][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30fc: begin
          o_target[M_DOMAIN][63][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30fc: begin
          o_target[S_DOMAIN][63][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3100: begin
          o_target[M_DOMAIN][64][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3100: begin
          o_target[S_DOMAIN][64][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3104: begin
          o_target[M_DOMAIN][65][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3104: begin
          o_target[S_DOMAIN][65][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3108: begin
          o_target[M_DOMAIN][66][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3108: begin
          o_target[S_DOMAIN][66][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h310c: begin
          o_target[M_DOMAIN][67][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h310c: begin
          o_target[S_DOMAIN][67][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3110: begin
          o_target[M_DOMAIN][68][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3110: begin
          o_target[S_DOMAIN][68][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3114: begin
          o_target[M_DOMAIN][69][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3114: begin
          o_target[S_DOMAIN][69][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3118: begin
          o_target[M_DOMAIN][70][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3118: begin
          o_target[S_DOMAIN][70][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h311c: begin
          o_target[M_DOMAIN][71][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h311c: begin
          o_target[S_DOMAIN][71][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3120: begin
          o_target[M_DOMAIN][72][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3120: begin
          o_target[S_DOMAIN][72][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3124: begin
          o_target[M_DOMAIN][73][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3124: begin
          o_target[S_DOMAIN][73][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3128: begin
          o_target[M_DOMAIN][74][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3128: begin
          o_target[S_DOMAIN][74][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h312c: begin
          o_target[M_DOMAIN][75][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h312c: begin
          o_target[S_DOMAIN][75][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3130: begin
          o_target[M_DOMAIN][76][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3130: begin
          o_target[S_DOMAIN][76][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3134: begin
          o_target[M_DOMAIN][77][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3134: begin
          o_target[S_DOMAIN][77][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3138: begin
          o_target[M_DOMAIN][78][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3138: begin
          o_target[S_DOMAIN][78][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h313c: begin
          o_target[M_DOMAIN][79][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h313c: begin
          o_target[S_DOMAIN][79][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3140: begin
          o_target[M_DOMAIN][80][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3140: begin
          o_target[S_DOMAIN][80][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3144: begin
          o_target[M_DOMAIN][81][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3144: begin
          o_target[S_DOMAIN][81][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3148: begin
          o_target[M_DOMAIN][82][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3148: begin
          o_target[S_DOMAIN][82][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h314c: begin
          o_target[M_DOMAIN][83][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h314c: begin
          o_target[S_DOMAIN][83][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3150: begin
          o_target[M_DOMAIN][84][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3150: begin
          o_target[S_DOMAIN][84][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3154: begin
          o_target[M_DOMAIN][85][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3154: begin
          o_target[S_DOMAIN][85][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3158: begin
          o_target[M_DOMAIN][86][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3158: begin
          o_target[S_DOMAIN][86][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h315c: begin
          o_target[M_DOMAIN][87][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h315c: begin
          o_target[S_DOMAIN][87][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3160: begin
          o_target[M_DOMAIN][88][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3160: begin
          o_target[S_DOMAIN][88][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3164: begin
          o_target[M_DOMAIN][89][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3164: begin
          o_target[S_DOMAIN][89][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3168: begin
          o_target[M_DOMAIN][90][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3168: begin
          o_target[S_DOMAIN][90][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h316c: begin
          o_target[M_DOMAIN][91][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h316c: begin
          o_target[S_DOMAIN][91][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3170: begin
          o_target[M_DOMAIN][92][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3170: begin
          o_target[S_DOMAIN][92][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3174: begin
          o_target[M_DOMAIN][93][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3174: begin
          o_target[S_DOMAIN][93][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3178: begin
          o_target[M_DOMAIN][94][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3178: begin
          o_target[S_DOMAIN][94][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h317c: begin
          o_target[M_DOMAIN][95][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h317c: begin
          o_target[S_DOMAIN][95][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3180: begin
          o_target[M_DOMAIN][96][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3180: begin
          o_target[S_DOMAIN][96][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3184: begin
          o_target[M_DOMAIN][97][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3184: begin
          o_target[S_DOMAIN][97][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3188: begin
          o_target[M_DOMAIN][98][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3188: begin
          o_target[S_DOMAIN][98][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h318c: begin
          o_target[M_DOMAIN][99][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h318c: begin
          o_target[S_DOMAIN][99][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3190: begin
          o_target[M_DOMAIN][100][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3190: begin
          o_target[S_DOMAIN][100][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3194: begin
          o_target[M_DOMAIN][101][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3194: begin
          o_target[S_DOMAIN][101][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3198: begin
          o_target[M_DOMAIN][102][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3198: begin
          o_target[S_DOMAIN][102][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h319c: begin
          o_target[M_DOMAIN][103][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h319c: begin
          o_target[S_DOMAIN][103][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31a0: begin
          o_target[M_DOMAIN][104][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31a0: begin
          o_target[S_DOMAIN][104][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31a4: begin
          o_target[M_DOMAIN][105][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31a4: begin
          o_target[S_DOMAIN][105][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31a8: begin
          o_target[M_DOMAIN][106][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31a8: begin
          o_target[S_DOMAIN][106][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31ac: begin
          o_target[M_DOMAIN][107][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31ac: begin
          o_target[S_DOMAIN][107][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31b0: begin
          o_target[M_DOMAIN][108][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31b0: begin
          o_target[S_DOMAIN][108][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31b4: begin
          o_target[M_DOMAIN][109][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31b4: begin
          o_target[S_DOMAIN][109][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31b8: begin
          o_target[M_DOMAIN][110][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31b8: begin
          o_target[S_DOMAIN][110][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31bc: begin
          o_target[M_DOMAIN][111][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31bc: begin
          o_target[S_DOMAIN][111][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c0: begin
          o_target[M_DOMAIN][112][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c0: begin
          o_target[S_DOMAIN][112][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c4: begin
          o_target[M_DOMAIN][113][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c4: begin
          o_target[S_DOMAIN][113][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c8: begin
          o_target[M_DOMAIN][114][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c8: begin
          o_target[S_DOMAIN][114][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31cc: begin
          o_target[M_DOMAIN][115][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31cc: begin
          o_target[S_DOMAIN][115][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31d0: begin
          o_target[M_DOMAIN][116][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31d0: begin
          o_target[S_DOMAIN][116][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31d4: begin
          o_target[M_DOMAIN][117][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31d4: begin
          o_target[S_DOMAIN][117][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31d8: begin
          o_target[M_DOMAIN][118][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31d8: begin
          o_target[S_DOMAIN][118][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31dc: begin
          o_target[M_DOMAIN][119][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31dc: begin
          o_target[S_DOMAIN][119][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31e0: begin
          o_target[M_DOMAIN][120][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31e0: begin
          o_target[S_DOMAIN][120][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31e4: begin
          o_target[M_DOMAIN][121][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31e4: begin
          o_target[S_DOMAIN][121][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31e8: begin
          o_target[M_DOMAIN][122][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31e8: begin
          o_target[S_DOMAIN][122][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31ec: begin
          o_target[M_DOMAIN][123][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31ec: begin
          o_target[S_DOMAIN][123][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31f0: begin
          o_target[M_DOMAIN][124][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31f0: begin
          o_target[S_DOMAIN][124][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31f4: begin
          o_target[M_DOMAIN][125][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31f4: begin
          o_target[S_DOMAIN][125][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31f8: begin
          o_target[M_DOMAIN][126][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31f8: begin
          o_target[S_DOMAIN][126][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31fc: begin
          o_target[M_DOMAIN][127][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31fc: begin
          o_target[S_DOMAIN][127][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3200: begin
          o_target[M_DOMAIN][128][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3200: begin
          o_target[S_DOMAIN][128][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3204: begin
          o_target[M_DOMAIN][129][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3204: begin
          o_target[S_DOMAIN][129][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3208: begin
          o_target[M_DOMAIN][130][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3208: begin
          o_target[S_DOMAIN][130][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h320c: begin
          o_target[M_DOMAIN][131][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h320c: begin
          o_target[S_DOMAIN][131][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3210: begin
          o_target[M_DOMAIN][132][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3210: begin
          o_target[S_DOMAIN][132][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3214: begin
          o_target[M_DOMAIN][133][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3214: begin
          o_target[S_DOMAIN][133][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3218: begin
          o_target[M_DOMAIN][134][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3218: begin
          o_target[S_DOMAIN][134][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h321c: begin
          o_target[M_DOMAIN][135][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h321c: begin
          o_target[S_DOMAIN][135][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3220: begin
          o_target[M_DOMAIN][136][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3220: begin
          o_target[S_DOMAIN][136][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3224: begin
          o_target[M_DOMAIN][137][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3224: begin
          o_target[S_DOMAIN][137][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3228: begin
          o_target[M_DOMAIN][138][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3228: begin
          o_target[S_DOMAIN][138][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h322c: begin
          o_target[M_DOMAIN][139][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h322c: begin
          o_target[S_DOMAIN][139][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3230: begin
          o_target[M_DOMAIN][140][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3230: begin
          o_target[S_DOMAIN][140][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3234: begin
          o_target[M_DOMAIN][141][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3234: begin
          o_target[S_DOMAIN][141][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3238: begin
          o_target[M_DOMAIN][142][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3238: begin
          o_target[S_DOMAIN][142][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h323c: begin
          o_target[M_DOMAIN][143][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h323c: begin
          o_target[S_DOMAIN][143][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3240: begin
          o_target[M_DOMAIN][144][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3240: begin
          o_target[S_DOMAIN][144][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3244: begin
          o_target[M_DOMAIN][145][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3244: begin
          o_target[S_DOMAIN][145][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3248: begin
          o_target[M_DOMAIN][146][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3248: begin
          o_target[S_DOMAIN][146][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h324c: begin
          o_target[M_DOMAIN][147][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h324c: begin
          o_target[S_DOMAIN][147][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3250: begin
          o_target[M_DOMAIN][148][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3250: begin
          o_target[S_DOMAIN][148][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3254: begin
          o_target[M_DOMAIN][149][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3254: begin
          o_target[S_DOMAIN][149][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3258: begin
          o_target[M_DOMAIN][150][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3258: begin
          o_target[S_DOMAIN][150][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h325c: begin
          o_target[M_DOMAIN][151][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h325c: begin
          o_target[S_DOMAIN][151][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3260: begin
          o_target[M_DOMAIN][152][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3260: begin
          o_target[S_DOMAIN][152][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3264: begin
          o_target[M_DOMAIN][153][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3264: begin
          o_target[S_DOMAIN][153][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3268: begin
          o_target[M_DOMAIN][154][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3268: begin
          o_target[S_DOMAIN][154][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h326c: begin
          o_target[M_DOMAIN][155][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h326c: begin
          o_target[S_DOMAIN][155][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3270: begin
          o_target[M_DOMAIN][156][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3270: begin
          o_target[S_DOMAIN][156][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3274: begin
          o_target[M_DOMAIN][157][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3274: begin
          o_target[S_DOMAIN][157][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3278: begin
          o_target[M_DOMAIN][158][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3278: begin
          o_target[S_DOMAIN][158][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h327c: begin
          o_target[M_DOMAIN][159][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h327c: begin
          o_target[S_DOMAIN][159][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3280: begin
          o_target[M_DOMAIN][160][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3280: begin
          o_target[S_DOMAIN][160][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3284: begin
          o_target[M_DOMAIN][161][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3284: begin
          o_target[S_DOMAIN][161][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3288: begin
          o_target[M_DOMAIN][162][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3288: begin
          o_target[S_DOMAIN][162][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h328c: begin
          o_target[M_DOMAIN][163][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h328c: begin
          o_target[S_DOMAIN][163][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3290: begin
          o_target[M_DOMAIN][164][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3290: begin
          o_target[S_DOMAIN][164][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3294: begin
          o_target[M_DOMAIN][165][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3294: begin
          o_target[S_DOMAIN][165][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3298: begin
          o_target[M_DOMAIN][166][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3298: begin
          o_target[S_DOMAIN][166][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h329c: begin
          o_target[M_DOMAIN][167][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h329c: begin
          o_target[S_DOMAIN][167][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32a0: begin
          o_target[M_DOMAIN][168][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32a0: begin
          o_target[S_DOMAIN][168][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32a4: begin
          o_target[M_DOMAIN][169][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32a4: begin
          o_target[S_DOMAIN][169][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32a8: begin
          o_target[M_DOMAIN][170][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32a8: begin
          o_target[S_DOMAIN][170][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32ac: begin
          o_target[M_DOMAIN][171][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32ac: begin
          o_target[S_DOMAIN][171][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32b0: begin
          o_target[M_DOMAIN][172][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32b0: begin
          o_target[S_DOMAIN][172][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32b4: begin
          o_target[M_DOMAIN][173][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32b4: begin
          o_target[S_DOMAIN][173][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32b8: begin
          o_target[M_DOMAIN][174][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32b8: begin
          o_target[S_DOMAIN][174][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32bc: begin
          o_target[M_DOMAIN][175][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32bc: begin
          o_target[S_DOMAIN][175][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c0: begin
          o_target[M_DOMAIN][176][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c0: begin
          o_target[S_DOMAIN][176][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c4: begin
          o_target[M_DOMAIN][177][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c4: begin
          o_target[S_DOMAIN][177][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c8: begin
          o_target[M_DOMAIN][178][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c8: begin
          o_target[S_DOMAIN][178][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32cc: begin
          o_target[M_DOMAIN][179][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32cc: begin
          o_target[S_DOMAIN][179][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32d0: begin
          o_target[M_DOMAIN][180][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32d0: begin
          o_target[S_DOMAIN][180][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32d4: begin
          o_target[M_DOMAIN][181][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32d4: begin
          o_target[S_DOMAIN][181][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32d8: begin
          o_target[M_DOMAIN][182][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32d8: begin
          o_target[S_DOMAIN][182][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32dc: begin
          o_target[M_DOMAIN][183][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32dc: begin
          o_target[S_DOMAIN][183][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32e0: begin
          o_target[M_DOMAIN][184][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32e0: begin
          o_target[S_DOMAIN][184][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32e4: begin
          o_target[M_DOMAIN][185][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32e4: begin
          o_target[S_DOMAIN][185][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32e8: begin
          o_target[M_DOMAIN][186][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32e8: begin
          o_target[S_DOMAIN][186][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32ec: begin
          o_target[M_DOMAIN][187][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32ec: begin
          o_target[S_DOMAIN][187][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32f0: begin
          o_target[M_DOMAIN][188][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32f0: begin
          o_target[S_DOMAIN][188][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32f4: begin
          o_target[M_DOMAIN][189][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32f4: begin
          o_target[S_DOMAIN][189][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32f8: begin
          o_target[M_DOMAIN][190][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32f8: begin
          o_target[S_DOMAIN][190][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32fc: begin
          o_target[M_DOMAIN][191][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32fc: begin
          o_target[S_DOMAIN][191][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3300: begin
          o_target[M_DOMAIN][192][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3300: begin
          o_target[S_DOMAIN][192][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3304: begin
          o_target[M_DOMAIN][193][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3304: begin
          o_target[S_DOMAIN][193][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3308: begin
          o_target[M_DOMAIN][194][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3308: begin
          o_target[S_DOMAIN][194][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h330c: begin
          o_target[M_DOMAIN][195][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h330c: begin
          o_target[S_DOMAIN][195][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3310: begin
          o_target[M_DOMAIN][196][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3310: begin
          o_target[S_DOMAIN][196][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3314: begin
          o_target[M_DOMAIN][197][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3314: begin
          o_target[S_DOMAIN][197][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3318: begin
          o_target[M_DOMAIN][198][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3318: begin
          o_target[S_DOMAIN][198][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h331c: begin
          o_target[M_DOMAIN][199][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h331c: begin
          o_target[S_DOMAIN][199][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3320: begin
          o_target[M_DOMAIN][200][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3320: begin
          o_target[S_DOMAIN][200][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3324: begin
          o_target[M_DOMAIN][201][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3324: begin
          o_target[S_DOMAIN][201][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3328: begin
          o_target[M_DOMAIN][202][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3328: begin
          o_target[S_DOMAIN][202][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h332c: begin
          o_target[M_DOMAIN][203][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h332c: begin
          o_target[S_DOMAIN][203][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3330: begin
          o_target[M_DOMAIN][204][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3330: begin
          o_target[S_DOMAIN][204][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3334: begin
          o_target[M_DOMAIN][205][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3334: begin
          o_target[S_DOMAIN][205][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3338: begin
          o_target[M_DOMAIN][206][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3338: begin
          o_target[S_DOMAIN][206][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h333c: begin
          o_target[M_DOMAIN][207][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h333c: begin
          o_target[S_DOMAIN][207][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3340: begin
          o_target[M_DOMAIN][208][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3340: begin
          o_target[S_DOMAIN][208][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3344: begin
          o_target[M_DOMAIN][209][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3344: begin
          o_target[S_DOMAIN][209][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3348: begin
          o_target[M_DOMAIN][210][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3348: begin
          o_target[S_DOMAIN][210][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h334c: begin
          o_target[M_DOMAIN][211][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h334c: begin
          o_target[S_DOMAIN][211][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3350: begin
          o_target[M_DOMAIN][212][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3350: begin
          o_target[S_DOMAIN][212][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3354: begin
          o_target[M_DOMAIN][213][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3354: begin
          o_target[S_DOMAIN][213][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3358: begin
          o_target[M_DOMAIN][214][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3358: begin
          o_target[S_DOMAIN][214][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h335c: begin
          o_target[M_DOMAIN][215][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h335c: begin
          o_target[S_DOMAIN][215][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3360: begin
          o_target[M_DOMAIN][216][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3360: begin
          o_target[S_DOMAIN][216][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3364: begin
          o_target[M_DOMAIN][217][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3364: begin
          o_target[S_DOMAIN][217][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3368: begin
          o_target[M_DOMAIN][218][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3368: begin
          o_target[S_DOMAIN][218][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h336c: begin
          o_target[M_DOMAIN][219][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h336c: begin
          o_target[S_DOMAIN][219][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3370: begin
          o_target[M_DOMAIN][220][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3370: begin
          o_target[S_DOMAIN][220][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3374: begin
          o_target[M_DOMAIN][221][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3374: begin
          o_target[S_DOMAIN][221][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3378: begin
          o_target[M_DOMAIN][222][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3378: begin
          o_target[S_DOMAIN][222][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h337c: begin
          o_target[M_DOMAIN][223][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h337c: begin
          o_target[S_DOMAIN][223][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3380: begin
          o_target[M_DOMAIN][224][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3380: begin
          o_target[S_DOMAIN][224][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3384: begin
          o_target[M_DOMAIN][225][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3384: begin
          o_target[S_DOMAIN][225][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3388: begin
          o_target[M_DOMAIN][226][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3388: begin
          o_target[S_DOMAIN][226][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h338c: begin
          o_target[M_DOMAIN][227][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h338c: begin
          o_target[S_DOMAIN][227][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3390: begin
          o_target[M_DOMAIN][228][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3390: begin
          o_target[S_DOMAIN][228][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3394: begin
          o_target[M_DOMAIN][229][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3394: begin
          o_target[S_DOMAIN][229][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3398: begin
          o_target[M_DOMAIN][230][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3398: begin
          o_target[S_DOMAIN][230][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h339c: begin
          o_target[M_DOMAIN][231][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h339c: begin
          o_target[S_DOMAIN][231][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33a0: begin
          o_target[M_DOMAIN][232][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33a0: begin
          o_target[S_DOMAIN][232][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33a4: begin
          o_target[M_DOMAIN][233][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33a4: begin
          o_target[S_DOMAIN][233][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33a8: begin
          o_target[M_DOMAIN][234][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33a8: begin
          o_target[S_DOMAIN][234][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33ac: begin
          o_target[M_DOMAIN][235][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33ac: begin
          o_target[S_DOMAIN][235][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33b0: begin
          o_target[M_DOMAIN][236][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33b0: begin
          o_target[S_DOMAIN][236][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33b4: begin
          o_target[M_DOMAIN][237][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33b4: begin
          o_target[S_DOMAIN][237][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33b8: begin
          o_target[M_DOMAIN][238][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33b8: begin
          o_target[S_DOMAIN][238][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33bc: begin
          o_target[M_DOMAIN][239][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33bc: begin
          o_target[S_DOMAIN][239][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c0: begin
          o_target[M_DOMAIN][240][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c0: begin
          o_target[S_DOMAIN][240][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c4: begin
          o_target[M_DOMAIN][241][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c4: begin
          o_target[S_DOMAIN][241][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c8: begin
          o_target[M_DOMAIN][242][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c8: begin
          o_target[S_DOMAIN][242][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33cc: begin
          o_target[M_DOMAIN][243][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33cc: begin
          o_target[S_DOMAIN][243][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33d0: begin
          o_target[M_DOMAIN][244][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33d0: begin
          o_target[S_DOMAIN][244][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33d4: begin
          o_target[M_DOMAIN][245][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33d4: begin
          o_target[S_DOMAIN][245][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33d8: begin
          o_target[M_DOMAIN][246][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33d8: begin
          o_target[S_DOMAIN][246][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33dc: begin
          o_target[M_DOMAIN][247][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33dc: begin
          o_target[S_DOMAIN][247][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33e0: begin
          o_target[M_DOMAIN][248][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33e0: begin
          o_target[S_DOMAIN][248][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33e4: begin
          o_target[M_DOMAIN][249][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33e4: begin
          o_target[S_DOMAIN][249][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33e8: begin
          o_target[M_DOMAIN][250][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33e8: begin
          o_target[S_DOMAIN][250][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33ec: begin
          o_target[M_DOMAIN][251][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33ec: begin
          o_target[S_DOMAIN][251][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33f0: begin
          o_target[M_DOMAIN][252][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33f0: begin
          o_target[S_DOMAIN][252][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33f4: begin
          o_target[M_DOMAIN][253][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33f4: begin
          o_target[S_DOMAIN][253][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33f8: begin
          o_target[M_DOMAIN][254][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33f8: begin
          o_target[S_DOMAIN][254][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33fc: begin
          o_target[M_DOMAIN][255][31:0]     = i_req.wdata[31:0];
          o_target_we[M_DOMAIN][255]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33fc: begin
          o_target[S_DOMAIN][255][31:0]     = i_req.wdata[31:0];
          o_target_we[S_DOMAIN][255]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h80: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][32][10:0];
          o_sourcecfg_re[M_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h80: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][32][10:0];
          o_sourcecfg_re[S_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h84: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][33][10:0];
          o_sourcecfg_re[M_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h84: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][33][10:0];
          o_sourcecfg_re[S_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h88: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][34][10:0];
          o_sourcecfg_re[M_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h88: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][34][10:0];
          o_sourcecfg_re[S_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h8c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][35][10:0];
          o_sourcecfg_re[M_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h8c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][35][10:0];
          o_sourcecfg_re[S_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h90: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][36][10:0];
          o_sourcecfg_re[M_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h90: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][36][10:0];
          o_sourcecfg_re[S_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h94: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][37][10:0];
          o_sourcecfg_re[M_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h94: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][37][10:0];
          o_sourcecfg_re[S_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h98: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][38][10:0];
          o_sourcecfg_re[M_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h98: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][38][10:0];
          o_sourcecfg_re[S_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h9c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][39][10:0];
          o_sourcecfg_re[M_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h9c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][39][10:0];
          o_sourcecfg_re[S_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'ha0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][40][10:0];
          o_sourcecfg_re[M_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'ha0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][40][10:0];
          o_sourcecfg_re[S_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'ha4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][41][10:0];
          o_sourcecfg_re[M_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'ha4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][41][10:0];
          o_sourcecfg_re[S_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'ha8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][42][10:0];
          o_sourcecfg_re[M_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'ha8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][42][10:0];
          o_sourcecfg_re[S_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][43][10:0];
          o_sourcecfg_re[M_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][43][10:0];
          o_sourcecfg_re[S_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hb0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][44][10:0];
          o_sourcecfg_re[M_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hb0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][44][10:0];
          o_sourcecfg_re[S_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hb4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][45][10:0];
          o_sourcecfg_re[M_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hb4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][45][10:0];
          o_sourcecfg_re[S_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hb8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][46][10:0];
          o_sourcecfg_re[M_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hb8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][46][10:0];
          o_sourcecfg_re[S_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hbc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][47][10:0];
          o_sourcecfg_re[M_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hbc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][47][10:0];
          o_sourcecfg_re[S_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][48][10:0];
          o_sourcecfg_re[M_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][48][10:0];
          o_sourcecfg_re[S_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][49][10:0];
          o_sourcecfg_re[M_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][49][10:0];
          o_sourcecfg_re[S_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hc8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][50][10:0];
          o_sourcecfg_re[M_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hc8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][50][10:0];
          o_sourcecfg_re[S_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hcc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][51][10:0];
          o_sourcecfg_re[M_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hcc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][51][10:0];
          o_sourcecfg_re[S_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hd0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][52][10:0];
          o_sourcecfg_re[M_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hd0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][52][10:0];
          o_sourcecfg_re[S_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hd4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][53][10:0];
          o_sourcecfg_re[M_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hd4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][53][10:0];
          o_sourcecfg_re[S_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hd8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][54][10:0];
          o_sourcecfg_re[M_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hd8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][54][10:0];
          o_sourcecfg_re[S_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hdc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][55][10:0];
          o_sourcecfg_re[M_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hdc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][55][10:0];
          o_sourcecfg_re[S_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'he0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][56][10:0];
          o_sourcecfg_re[M_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'he0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][56][10:0];
          o_sourcecfg_re[S_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'he4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][57][10:0];
          o_sourcecfg_re[M_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'he4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][57][10:0];
          o_sourcecfg_re[S_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'he8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][58][10:0];
          o_sourcecfg_re[M_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'he8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][58][10:0];
          o_sourcecfg_re[S_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][59][10:0];
          o_sourcecfg_re[M_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][59][10:0];
          o_sourcecfg_re[S_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hf0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][60][10:0];
          o_sourcecfg_re[M_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hf0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][60][10:0];
          o_sourcecfg_re[S_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hf4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][61][10:0];
          o_sourcecfg_re[M_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hf4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][61][10:0];
          o_sourcecfg_re[S_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hf8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][62][10:0];
          o_sourcecfg_re[M_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hf8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][62][10:0];
          o_sourcecfg_re[S_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'hfc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][63][10:0];
          o_sourcecfg_re[M_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'hfc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][63][10:0];
          o_sourcecfg_re[S_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h100: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][64][10:0];
          o_sourcecfg_re[M_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h100: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][64][10:0];
          o_sourcecfg_re[S_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h104: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][65][10:0];
          o_sourcecfg_re[M_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h104: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][65][10:0];
          o_sourcecfg_re[S_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h108: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][66][10:0];
          o_sourcecfg_re[M_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h108: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][66][10:0];
          o_sourcecfg_re[S_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h10c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][67][10:0];
          o_sourcecfg_re[M_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h10c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][67][10:0];
          o_sourcecfg_re[S_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h110: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][68][10:0];
          o_sourcecfg_re[M_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h110: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][68][10:0];
          o_sourcecfg_re[S_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h114: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][69][10:0];
          o_sourcecfg_re[M_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h114: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][69][10:0];
          o_sourcecfg_re[S_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h118: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][70][10:0];
          o_sourcecfg_re[M_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h118: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][70][10:0];
          o_sourcecfg_re[S_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h11c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][71][10:0];
          o_sourcecfg_re[M_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h11c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][71][10:0];
          o_sourcecfg_re[S_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h120: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][72][10:0];
          o_sourcecfg_re[M_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h120: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][72][10:0];
          o_sourcecfg_re[S_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h124: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][73][10:0];
          o_sourcecfg_re[M_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h124: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][73][10:0];
          o_sourcecfg_re[S_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h128: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][74][10:0];
          o_sourcecfg_re[M_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h128: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][74][10:0];
          o_sourcecfg_re[S_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h12c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][75][10:0];
          o_sourcecfg_re[M_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h12c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][75][10:0];
          o_sourcecfg_re[S_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h130: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][76][10:0];
          o_sourcecfg_re[M_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h130: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][76][10:0];
          o_sourcecfg_re[S_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h134: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][77][10:0];
          o_sourcecfg_re[M_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h134: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][77][10:0];
          o_sourcecfg_re[S_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h138: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][78][10:0];
          o_sourcecfg_re[M_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h138: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][78][10:0];
          o_sourcecfg_re[S_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h13c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][79][10:0];
          o_sourcecfg_re[M_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h13c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][79][10:0];
          o_sourcecfg_re[S_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h140: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][80][10:0];
          o_sourcecfg_re[M_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h140: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][80][10:0];
          o_sourcecfg_re[S_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h144: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][81][10:0];
          o_sourcecfg_re[M_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h144: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][81][10:0];
          o_sourcecfg_re[S_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h148: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][82][10:0];
          o_sourcecfg_re[M_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h148: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][82][10:0];
          o_sourcecfg_re[S_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h14c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][83][10:0];
          o_sourcecfg_re[M_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h14c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][83][10:0];
          o_sourcecfg_re[S_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h150: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][84][10:0];
          o_sourcecfg_re[M_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h150: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][84][10:0];
          o_sourcecfg_re[S_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h154: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][85][10:0];
          o_sourcecfg_re[M_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h154: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][85][10:0];
          o_sourcecfg_re[S_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h158: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][86][10:0];
          o_sourcecfg_re[M_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h158: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][86][10:0];
          o_sourcecfg_re[S_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h15c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][87][10:0];
          o_sourcecfg_re[M_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h15c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][87][10:0];
          o_sourcecfg_re[S_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h160: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][88][10:0];
          o_sourcecfg_re[M_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h160: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][88][10:0];
          o_sourcecfg_re[S_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h164: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][89][10:0];
          o_sourcecfg_re[M_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h164: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][89][10:0];
          o_sourcecfg_re[S_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h168: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][90][10:0];
          o_sourcecfg_re[M_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h168: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][90][10:0];
          o_sourcecfg_re[S_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h16c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][91][10:0];
          o_sourcecfg_re[M_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h16c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][91][10:0];
          o_sourcecfg_re[S_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h170: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][92][10:0];
          o_sourcecfg_re[M_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h170: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][92][10:0];
          o_sourcecfg_re[S_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h174: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][93][10:0];
          o_sourcecfg_re[M_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h174: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][93][10:0];
          o_sourcecfg_re[S_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h178: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][94][10:0];
          o_sourcecfg_re[M_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h178: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][94][10:0];
          o_sourcecfg_re[S_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h17c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][95][10:0];
          o_sourcecfg_re[M_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h17c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][95][10:0];
          o_sourcecfg_re[S_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h180: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][96][10:0];
          o_sourcecfg_re[M_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h180: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][96][10:0];
          o_sourcecfg_re[S_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h184: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][97][10:0];
          o_sourcecfg_re[M_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h184: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][97][10:0];
          o_sourcecfg_re[S_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h188: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][98][10:0];
          o_sourcecfg_re[M_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h188: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][98][10:0];
          o_sourcecfg_re[S_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h18c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][99][10:0];
          o_sourcecfg_re[M_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h18c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][99][10:0];
          o_sourcecfg_re[S_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h190: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][100][10:0];
          o_sourcecfg_re[M_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h190: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][100][10:0];
          o_sourcecfg_re[S_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h194: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][101][10:0];
          o_sourcecfg_re[M_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h194: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][101][10:0];
          o_sourcecfg_re[S_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h198: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][102][10:0];
          o_sourcecfg_re[M_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h198: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][102][10:0];
          o_sourcecfg_re[S_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h19c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][103][10:0];
          o_sourcecfg_re[M_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h19c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][103][10:0];
          o_sourcecfg_re[S_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1a0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][104][10:0];
          o_sourcecfg_re[M_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1a0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][104][10:0];
          o_sourcecfg_re[S_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1a4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][105][10:0];
          o_sourcecfg_re[M_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1a4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][105][10:0];
          o_sourcecfg_re[S_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1a8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][106][10:0];
          o_sourcecfg_re[M_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1a8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][106][10:0];
          o_sourcecfg_re[S_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1ac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][107][10:0];
          o_sourcecfg_re[M_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1ac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][107][10:0];
          o_sourcecfg_re[S_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1b0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][108][10:0];
          o_sourcecfg_re[M_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1b0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][108][10:0];
          o_sourcecfg_re[S_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1b4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][109][10:0];
          o_sourcecfg_re[M_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1b4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][109][10:0];
          o_sourcecfg_re[S_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1b8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][110][10:0];
          o_sourcecfg_re[M_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1b8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][110][10:0];
          o_sourcecfg_re[S_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1bc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][111][10:0];
          o_sourcecfg_re[M_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1bc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][111][10:0];
          o_sourcecfg_re[S_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][112][10:0];
          o_sourcecfg_re[M_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][112][10:0];
          o_sourcecfg_re[S_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][113][10:0];
          o_sourcecfg_re[M_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][113][10:0];
          o_sourcecfg_re[S_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][114][10:0];
          o_sourcecfg_re[M_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][114][10:0];
          o_sourcecfg_re[S_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1cc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][115][10:0];
          o_sourcecfg_re[M_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1cc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][115][10:0];
          o_sourcecfg_re[S_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][116][10:0];
          o_sourcecfg_re[M_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][116][10:0];
          o_sourcecfg_re[S_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][117][10:0];
          o_sourcecfg_re[M_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][117][10:0];
          o_sourcecfg_re[S_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][118][10:0];
          o_sourcecfg_re[M_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][118][10:0];
          o_sourcecfg_re[S_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1dc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][119][10:0];
          o_sourcecfg_re[M_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1dc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][119][10:0];
          o_sourcecfg_re[S_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][120][10:0];
          o_sourcecfg_re[M_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][120][10:0];
          o_sourcecfg_re[S_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][121][10:0];
          o_sourcecfg_re[M_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][121][10:0];
          o_sourcecfg_re[S_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][122][10:0];
          o_sourcecfg_re[M_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][122][10:0];
          o_sourcecfg_re[S_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1ec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][123][10:0];
          o_sourcecfg_re[M_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1ec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][123][10:0];
          o_sourcecfg_re[S_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][124][10:0];
          o_sourcecfg_re[M_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][124][10:0];
          o_sourcecfg_re[S_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][125][10:0];
          o_sourcecfg_re[M_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][125][10:0];
          o_sourcecfg_re[S_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][126][10:0];
          o_sourcecfg_re[M_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][126][10:0];
          o_sourcecfg_re[S_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1fc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][127][10:0];
          o_sourcecfg_re[M_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1fc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][127][10:0];
          o_sourcecfg_re[S_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h200: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][128][10:0];
          o_sourcecfg_re[M_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h200: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][128][10:0];
          o_sourcecfg_re[S_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h204: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][129][10:0];
          o_sourcecfg_re[M_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h204: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][129][10:0];
          o_sourcecfg_re[S_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h208: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][130][10:0];
          o_sourcecfg_re[M_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h208: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][130][10:0];
          o_sourcecfg_re[S_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h20c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][131][10:0];
          o_sourcecfg_re[M_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h20c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][131][10:0];
          o_sourcecfg_re[S_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h210: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][132][10:0];
          o_sourcecfg_re[M_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h210: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][132][10:0];
          o_sourcecfg_re[S_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h214: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][133][10:0];
          o_sourcecfg_re[M_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h214: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][133][10:0];
          o_sourcecfg_re[S_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h218: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][134][10:0];
          o_sourcecfg_re[M_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h218: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][134][10:0];
          o_sourcecfg_re[S_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h21c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][135][10:0];
          o_sourcecfg_re[M_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h21c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][135][10:0];
          o_sourcecfg_re[S_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h220: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][136][10:0];
          o_sourcecfg_re[M_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h220: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][136][10:0];
          o_sourcecfg_re[S_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h224: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][137][10:0];
          o_sourcecfg_re[M_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h224: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][137][10:0];
          o_sourcecfg_re[S_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h228: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][138][10:0];
          o_sourcecfg_re[M_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h228: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][138][10:0];
          o_sourcecfg_re[S_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h22c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][139][10:0];
          o_sourcecfg_re[M_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h22c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][139][10:0];
          o_sourcecfg_re[S_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h230: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][140][10:0];
          o_sourcecfg_re[M_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h230: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][140][10:0];
          o_sourcecfg_re[S_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h234: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][141][10:0];
          o_sourcecfg_re[M_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h234: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][141][10:0];
          o_sourcecfg_re[S_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h238: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][142][10:0];
          o_sourcecfg_re[M_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h238: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][142][10:0];
          o_sourcecfg_re[S_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h23c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][143][10:0];
          o_sourcecfg_re[M_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h23c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][143][10:0];
          o_sourcecfg_re[S_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h240: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][144][10:0];
          o_sourcecfg_re[M_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h240: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][144][10:0];
          o_sourcecfg_re[S_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h244: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][145][10:0];
          o_sourcecfg_re[M_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h244: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][145][10:0];
          o_sourcecfg_re[S_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h248: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][146][10:0];
          o_sourcecfg_re[M_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h248: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][146][10:0];
          o_sourcecfg_re[S_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h24c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][147][10:0];
          o_sourcecfg_re[M_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h24c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][147][10:0];
          o_sourcecfg_re[S_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h250: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][148][10:0];
          o_sourcecfg_re[M_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h250: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][148][10:0];
          o_sourcecfg_re[S_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h254: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][149][10:0];
          o_sourcecfg_re[M_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h254: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][149][10:0];
          o_sourcecfg_re[S_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h258: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][150][10:0];
          o_sourcecfg_re[M_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h258: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][150][10:0];
          o_sourcecfg_re[S_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h25c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][151][10:0];
          o_sourcecfg_re[M_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h25c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][151][10:0];
          o_sourcecfg_re[S_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h260: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][152][10:0];
          o_sourcecfg_re[M_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h260: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][152][10:0];
          o_sourcecfg_re[S_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h264: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][153][10:0];
          o_sourcecfg_re[M_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h264: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][153][10:0];
          o_sourcecfg_re[S_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h268: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][154][10:0];
          o_sourcecfg_re[M_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h268: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][154][10:0];
          o_sourcecfg_re[S_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h26c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][155][10:0];
          o_sourcecfg_re[M_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h26c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][155][10:0];
          o_sourcecfg_re[S_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h270: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][156][10:0];
          o_sourcecfg_re[M_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h270: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][156][10:0];
          o_sourcecfg_re[S_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h274: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][157][10:0];
          o_sourcecfg_re[M_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h274: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][157][10:0];
          o_sourcecfg_re[S_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h278: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][158][10:0];
          o_sourcecfg_re[M_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h278: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][158][10:0];
          o_sourcecfg_re[S_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h27c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][159][10:0];
          o_sourcecfg_re[M_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h27c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][159][10:0];
          o_sourcecfg_re[S_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h280: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][160][10:0];
          o_sourcecfg_re[M_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h280: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][160][10:0];
          o_sourcecfg_re[S_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h284: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][161][10:0];
          o_sourcecfg_re[M_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h284: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][161][10:0];
          o_sourcecfg_re[S_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h288: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][162][10:0];
          o_sourcecfg_re[M_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h288: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][162][10:0];
          o_sourcecfg_re[S_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h28c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][163][10:0];
          o_sourcecfg_re[M_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h28c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][163][10:0];
          o_sourcecfg_re[S_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h290: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][164][10:0];
          o_sourcecfg_re[M_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h290: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][164][10:0];
          o_sourcecfg_re[S_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h294: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][165][10:0];
          o_sourcecfg_re[M_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h294: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][165][10:0];
          o_sourcecfg_re[S_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h298: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][166][10:0];
          o_sourcecfg_re[M_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h298: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][166][10:0];
          o_sourcecfg_re[S_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h29c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][167][10:0];
          o_sourcecfg_re[M_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h29c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][167][10:0];
          o_sourcecfg_re[S_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2a0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][168][10:0];
          o_sourcecfg_re[M_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2a0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][168][10:0];
          o_sourcecfg_re[S_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2a4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][169][10:0];
          o_sourcecfg_re[M_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2a4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][169][10:0];
          o_sourcecfg_re[S_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2a8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][170][10:0];
          o_sourcecfg_re[M_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2a8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][170][10:0];
          o_sourcecfg_re[S_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2ac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][171][10:0];
          o_sourcecfg_re[M_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2ac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][171][10:0];
          o_sourcecfg_re[S_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2b0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][172][10:0];
          o_sourcecfg_re[M_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2b0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][172][10:0];
          o_sourcecfg_re[S_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2b4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][173][10:0];
          o_sourcecfg_re[M_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2b4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][173][10:0];
          o_sourcecfg_re[S_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2b8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][174][10:0];
          o_sourcecfg_re[M_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2b8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][174][10:0];
          o_sourcecfg_re[S_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2bc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][175][10:0];
          o_sourcecfg_re[M_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2bc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][175][10:0];
          o_sourcecfg_re[S_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][176][10:0];
          o_sourcecfg_re[M_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][176][10:0];
          o_sourcecfg_re[S_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][177][10:0];
          o_sourcecfg_re[M_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][177][10:0];
          o_sourcecfg_re[S_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2c8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][178][10:0];
          o_sourcecfg_re[M_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2c8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][178][10:0];
          o_sourcecfg_re[S_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2cc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][179][10:0];
          o_sourcecfg_re[M_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2cc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][179][10:0];
          o_sourcecfg_re[S_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2d0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][180][10:0];
          o_sourcecfg_re[M_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2d0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][180][10:0];
          o_sourcecfg_re[S_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2d4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][181][10:0];
          o_sourcecfg_re[M_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2d4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][181][10:0];
          o_sourcecfg_re[S_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2d8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][182][10:0];
          o_sourcecfg_re[M_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2d8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][182][10:0];
          o_sourcecfg_re[S_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2dc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][183][10:0];
          o_sourcecfg_re[M_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2dc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][183][10:0];
          o_sourcecfg_re[S_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2e0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][184][10:0];
          o_sourcecfg_re[M_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2e0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][184][10:0];
          o_sourcecfg_re[S_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2e4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][185][10:0];
          o_sourcecfg_re[M_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2e4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][185][10:0];
          o_sourcecfg_re[S_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2e8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][186][10:0];
          o_sourcecfg_re[M_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2e8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][186][10:0];
          o_sourcecfg_re[S_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2ec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][187][10:0];
          o_sourcecfg_re[M_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2ec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][187][10:0];
          o_sourcecfg_re[S_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2f0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][188][10:0];
          o_sourcecfg_re[M_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2f0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][188][10:0];
          o_sourcecfg_re[S_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2f4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][189][10:0];
          o_sourcecfg_re[M_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2f4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][189][10:0];
          o_sourcecfg_re[S_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2f8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][190][10:0];
          o_sourcecfg_re[M_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2f8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][190][10:0];
          o_sourcecfg_re[S_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h2fc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][191][10:0];
          o_sourcecfg_re[M_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h2fc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][191][10:0];
          o_sourcecfg_re[S_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h300: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][192][10:0];
          o_sourcecfg_re[M_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h300: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][192][10:0];
          o_sourcecfg_re[S_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h304: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][193][10:0];
          o_sourcecfg_re[M_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h304: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][193][10:0];
          o_sourcecfg_re[S_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h308: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][194][10:0];
          o_sourcecfg_re[M_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h308: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][194][10:0];
          o_sourcecfg_re[S_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][195][10:0];
          o_sourcecfg_re[M_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][195][10:0];
          o_sourcecfg_re[S_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h310: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][196][10:0];
          o_sourcecfg_re[M_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h310: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][196][10:0];
          o_sourcecfg_re[S_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h314: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][197][10:0];
          o_sourcecfg_re[M_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h314: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][197][10:0];
          o_sourcecfg_re[S_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h318: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][198][10:0];
          o_sourcecfg_re[M_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h318: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][198][10:0];
          o_sourcecfg_re[S_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][199][10:0];
          o_sourcecfg_re[M_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][199][10:0];
          o_sourcecfg_re[S_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h320: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][200][10:0];
          o_sourcecfg_re[M_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h320: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][200][10:0];
          o_sourcecfg_re[S_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h324: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][201][10:0];
          o_sourcecfg_re[M_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h324: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][201][10:0];
          o_sourcecfg_re[S_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h328: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][202][10:0];
          o_sourcecfg_re[M_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h328: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][202][10:0];
          o_sourcecfg_re[S_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][203][10:0];
          o_sourcecfg_re[M_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][203][10:0];
          o_sourcecfg_re[S_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h330: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][204][10:0];
          o_sourcecfg_re[M_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h330: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][204][10:0];
          o_sourcecfg_re[S_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h334: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][205][10:0];
          o_sourcecfg_re[M_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h334: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][205][10:0];
          o_sourcecfg_re[S_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h338: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][206][10:0];
          o_sourcecfg_re[M_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h338: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][206][10:0];
          o_sourcecfg_re[S_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][207][10:0];
          o_sourcecfg_re[M_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][207][10:0];
          o_sourcecfg_re[S_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h340: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][208][10:0];
          o_sourcecfg_re[M_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h340: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][208][10:0];
          o_sourcecfg_re[S_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h344: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][209][10:0];
          o_sourcecfg_re[M_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h344: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][209][10:0];
          o_sourcecfg_re[S_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h348: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][210][10:0];
          o_sourcecfg_re[M_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h348: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][210][10:0];
          o_sourcecfg_re[S_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h34c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][211][10:0];
          o_sourcecfg_re[M_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h34c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][211][10:0];
          o_sourcecfg_re[S_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h350: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][212][10:0];
          o_sourcecfg_re[M_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h350: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][212][10:0];
          o_sourcecfg_re[S_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h354: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][213][10:0];
          o_sourcecfg_re[M_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h354: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][213][10:0];
          o_sourcecfg_re[S_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h358: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][214][10:0];
          o_sourcecfg_re[M_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h358: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][214][10:0];
          o_sourcecfg_re[S_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h35c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][215][10:0];
          o_sourcecfg_re[M_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h35c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][215][10:0];
          o_sourcecfg_re[S_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h360: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][216][10:0];
          o_sourcecfg_re[M_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h360: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][216][10:0];
          o_sourcecfg_re[S_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h364: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][217][10:0];
          o_sourcecfg_re[M_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h364: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][217][10:0];
          o_sourcecfg_re[S_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h368: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][218][10:0];
          o_sourcecfg_re[M_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h368: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][218][10:0];
          o_sourcecfg_re[S_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h36c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][219][10:0];
          o_sourcecfg_re[M_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h36c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][219][10:0];
          o_sourcecfg_re[S_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h370: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][220][10:0];
          o_sourcecfg_re[M_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h370: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][220][10:0];
          o_sourcecfg_re[S_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h374: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][221][10:0];
          o_sourcecfg_re[M_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h374: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][221][10:0];
          o_sourcecfg_re[S_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h378: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][222][10:0];
          o_sourcecfg_re[M_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h378: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][222][10:0];
          o_sourcecfg_re[S_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h37c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][223][10:0];
          o_sourcecfg_re[M_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h37c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][223][10:0];
          o_sourcecfg_re[S_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h380: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][224][10:0];
          o_sourcecfg_re[M_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h380: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][224][10:0];
          o_sourcecfg_re[S_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h384: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][225][10:0];
          o_sourcecfg_re[M_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h384: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][225][10:0];
          o_sourcecfg_re[S_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h388: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][226][10:0];
          o_sourcecfg_re[M_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h388: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][226][10:0];
          o_sourcecfg_re[S_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h38c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][227][10:0];
          o_sourcecfg_re[M_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h38c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][227][10:0];
          o_sourcecfg_re[S_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h390: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][228][10:0];
          o_sourcecfg_re[M_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h390: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][228][10:0];
          o_sourcecfg_re[S_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h394: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][229][10:0];
          o_sourcecfg_re[M_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h394: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][229][10:0];
          o_sourcecfg_re[S_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h398: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][230][10:0];
          o_sourcecfg_re[M_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h398: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][230][10:0];
          o_sourcecfg_re[S_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h39c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][231][10:0];
          o_sourcecfg_re[M_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h39c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][231][10:0];
          o_sourcecfg_re[S_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3a0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][232][10:0];
          o_sourcecfg_re[M_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3a0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][232][10:0];
          o_sourcecfg_re[S_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3a4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][233][10:0];
          o_sourcecfg_re[M_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3a4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][233][10:0];
          o_sourcecfg_re[S_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3a8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][234][10:0];
          o_sourcecfg_re[M_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3a8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][234][10:0];
          o_sourcecfg_re[S_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3ac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][235][10:0];
          o_sourcecfg_re[M_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3ac: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][235][10:0];
          o_sourcecfg_re[S_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3b0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][236][10:0];
          o_sourcecfg_re[M_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3b0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][236][10:0];
          o_sourcecfg_re[S_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3b4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][237][10:0];
          o_sourcecfg_re[M_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3b4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][237][10:0];
          o_sourcecfg_re[S_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3b8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][238][10:0];
          o_sourcecfg_re[M_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3b8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][238][10:0];
          o_sourcecfg_re[S_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3bc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][239][10:0];
          o_sourcecfg_re[M_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3bc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][239][10:0];
          o_sourcecfg_re[S_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][240][10:0];
          o_sourcecfg_re[M_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][240][10:0];
          o_sourcecfg_re[S_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][241][10:0];
          o_sourcecfg_re[M_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][241][10:0];
          o_sourcecfg_re[S_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3c8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][242][10:0];
          o_sourcecfg_re[M_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3c8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][242][10:0];
          o_sourcecfg_re[S_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3cc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][243][10:0];
          o_sourcecfg_re[M_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3cc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][243][10:0];
          o_sourcecfg_re[S_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3d0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][244][10:0];
          o_sourcecfg_re[M_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3d0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][244][10:0];
          o_sourcecfg_re[S_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3d4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][245][10:0];
          o_sourcecfg_re[M_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3d4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][245][10:0];
          o_sourcecfg_re[S_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3d8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][246][10:0];
          o_sourcecfg_re[M_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3d8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][246][10:0];
          o_sourcecfg_re[S_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3dc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][247][10:0];
          o_sourcecfg_re[M_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3dc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][247][10:0];
          o_sourcecfg_re[S_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3e0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][248][10:0];
          o_sourcecfg_re[M_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3e0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][248][10:0];
          o_sourcecfg_re[S_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3e4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][249][10:0];
          o_sourcecfg_re[M_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3e4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][249][10:0];
          o_sourcecfg_re[S_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3e8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][250][10:0];
          o_sourcecfg_re[M_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3e8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][250][10:0];
          o_sourcecfg_re[S_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3ec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][251][10:0];
          o_sourcecfg_re[M_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3ec: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][251][10:0];
          o_sourcecfg_re[S_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3f0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][252][10:0];
          o_sourcecfg_re[M_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3f0: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][252][10:0];
          o_sourcecfg_re[S_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3f4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][253][10:0];
          o_sourcecfg_re[M_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3f4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][253][10:0];
          o_sourcecfg_re[S_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3f8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][254][10:0];
          o_sourcecfg_re[M_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3f8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][254][10:0];
          o_sourcecfg_re[S_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3fc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[M_DOMAIN][255][10:0];
          o_sourcecfg_re[M_DOMAIN][255]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3fc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[S_DOMAIN][255][10:0];
          o_sourcecfg_re[S_DOMAIN][255]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1c04: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][1][31:0];
          o_setip_re[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c04: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][1][31:0];
          o_setip_re[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c08: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][2][31:0];
          o_setip_re[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c08: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][2][31:0];
          o_setip_re[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c0c: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][3][31:0];
          o_setip_re[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c0c: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][3][31:0];
          o_setip_re[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c10: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][4][31:0];
          o_setip_re[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c10: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][4][31:0];
          o_setip_re[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c14: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][5][31:0];
          o_setip_re[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c14: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][5][31:0];
          o_setip_re[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c18: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][6][31:0];
          o_setip_re[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c18: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][6][31:0];
          o_setip_re[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1c1c: begin
          o_resp.rdata[31:0]     = i_setip[M_DOMAIN][7][31:0];
          o_setip_re[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1c1c: begin
          o_resp.rdata[31:0]     = i_setip[S_DOMAIN][7][31:0];
          o_setip_re[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1d04: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][1][31:0];
          o_in_clrip_re[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d04: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][1][31:0];
          o_in_clrip_re[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d08: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][2][31:0];
          o_in_clrip_re[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d08: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][2][31:0];
          o_in_clrip_re[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d0c: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][3][31:0];
          o_in_clrip_re[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d0c: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][3][31:0];
          o_in_clrip_re[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d10: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][4][31:0];
          o_in_clrip_re[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d10: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][4][31:0];
          o_in_clrip_re[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d14: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][5][31:0];
          o_in_clrip_re[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d14: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][5][31:0];
          o_in_clrip_re[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d18: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][6][31:0];
          o_in_clrip_re[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d18: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][6][31:0];
          o_in_clrip_re[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1d1c: begin
          o_resp.rdata[31:0]     = i_in_clrip[M_DOMAIN][7][31:0];
          o_in_clrip_re[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1d1c: begin
          o_resp.rdata[31:0]     = i_in_clrip[S_DOMAIN][7][31:0];
          o_in_clrip_re[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1e04: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][1][31:0];
          o_setie_re[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e04: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][1][31:0];
          o_setie_re[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e08: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][2][31:0];
          o_setie_re[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e08: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][2][31:0];
          o_setie_re[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e0c: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][3][31:0];
          o_setie_re[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e0c: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][3][31:0];
          o_setie_re[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e10: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][4][31:0];
          o_setie_re[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e10: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][4][31:0];
          o_setie_re[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e14: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][5][31:0];
          o_setie_re[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e14: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][5][31:0];
          o_setie_re[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e18: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][6][31:0];
          o_setie_re[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e18: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][6][31:0];
          o_setie_re[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1e1c: begin
          o_resp.rdata[31:0]     = i_setie[M_DOMAIN][7][31:0];
          o_setie_re[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1e1c: begin
          o_resp.rdata[31:0]     = i_setie[S_DOMAIN][7][31:0];
          o_setie_re[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h1f04: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][1][31:0];
          o_clrie_re[M_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f04: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][1][31:0];
          o_clrie_re[S_DOMAIN][1]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f08: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][2][31:0];
          o_clrie_re[M_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f08: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][2][31:0];
          o_clrie_re[S_DOMAIN][2]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f0c: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][3][31:0];
          o_clrie_re[M_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f0c: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][3][31:0];
          o_clrie_re[S_DOMAIN][3]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f10: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][4][31:0];
          o_clrie_re[M_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f10: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][4][31:0];
          o_clrie_re[S_DOMAIN][4]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f14: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][5][31:0];
          o_clrie_re[M_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f14: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][5][31:0];
          o_clrie_re[S_DOMAIN][5]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f18: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][6][31:0];
          o_clrie_re[M_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f18: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][6][31:0];
          o_clrie_re[S_DOMAIN][6]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h1f1c: begin
          o_resp.rdata[31:0]     = i_clrie[M_DOMAIN][7][31:0];
          o_clrie_re[M_DOMAIN][7]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h1f1c: begin
          o_resp.rdata[31:0]     = i_clrie[S_DOMAIN][7][31:0];
          o_clrie_re[S_DOMAIN][7]      = 1'b1;
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
        DOMAIN_M_ADDR + 32'h3080: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][32][31:0];
          o_target_re[M_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3080: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][32][31:0];
          o_target_re[S_DOMAIN][32]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3084: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][33][31:0];
          o_target_re[M_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3084: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][33][31:0];
          o_target_re[S_DOMAIN][33]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3088: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][34][31:0];
          o_target_re[M_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3088: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][34][31:0];
          o_target_re[S_DOMAIN][34]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h308c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][35][31:0];
          o_target_re[M_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h308c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][35][31:0];
          o_target_re[S_DOMAIN][35]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3090: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][36][31:0];
          o_target_re[M_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3090: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][36][31:0];
          o_target_re[S_DOMAIN][36]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3094: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][37][31:0];
          o_target_re[M_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3094: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][37][31:0];
          o_target_re[S_DOMAIN][37]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3098: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][38][31:0];
          o_target_re[M_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3098: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][38][31:0];
          o_target_re[S_DOMAIN][38]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h309c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][39][31:0];
          o_target_re[M_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h309c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][39][31:0];
          o_target_re[S_DOMAIN][39]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30a0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][40][31:0];
          o_target_re[M_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30a0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][40][31:0];
          o_target_re[S_DOMAIN][40]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30a4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][41][31:0];
          o_target_re[M_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30a4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][41][31:0];
          o_target_re[S_DOMAIN][41]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30a8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][42][31:0];
          o_target_re[M_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30a8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][42][31:0];
          o_target_re[S_DOMAIN][42]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30ac: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][43][31:0];
          o_target_re[M_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30ac: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][43][31:0];
          o_target_re[S_DOMAIN][43]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30b0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][44][31:0];
          o_target_re[M_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30b0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][44][31:0];
          o_target_re[S_DOMAIN][44]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30b4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][45][31:0];
          o_target_re[M_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30b4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][45][31:0];
          o_target_re[S_DOMAIN][45]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30b8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][46][31:0];
          o_target_re[M_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30b8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][46][31:0];
          o_target_re[S_DOMAIN][46]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30bc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][47][31:0];
          o_target_re[M_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30bc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][47][31:0];
          o_target_re[S_DOMAIN][47]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][48][31:0];
          o_target_re[M_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][48][31:0];
          o_target_re[S_DOMAIN][48]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][49][31:0];
          o_target_re[M_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][49][31:0];
          o_target_re[S_DOMAIN][49]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30c8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][50][31:0];
          o_target_re[M_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30c8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][50][31:0];
          o_target_re[S_DOMAIN][50]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30cc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][51][31:0];
          o_target_re[M_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30cc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][51][31:0];
          o_target_re[S_DOMAIN][51]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30d0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][52][31:0];
          o_target_re[M_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30d0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][52][31:0];
          o_target_re[S_DOMAIN][52]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30d4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][53][31:0];
          o_target_re[M_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30d4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][53][31:0];
          o_target_re[S_DOMAIN][53]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30d8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][54][31:0];
          o_target_re[M_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30d8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][54][31:0];
          o_target_re[S_DOMAIN][54]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30dc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][55][31:0];
          o_target_re[M_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30dc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][55][31:0];
          o_target_re[S_DOMAIN][55]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30e0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][56][31:0];
          o_target_re[M_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30e0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][56][31:0];
          o_target_re[S_DOMAIN][56]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30e4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][57][31:0];
          o_target_re[M_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30e4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][57][31:0];
          o_target_re[S_DOMAIN][57]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30e8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][58][31:0];
          o_target_re[M_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30e8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][58][31:0];
          o_target_re[S_DOMAIN][58]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30ec: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][59][31:0];
          o_target_re[M_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30ec: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][59][31:0];
          o_target_re[S_DOMAIN][59]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30f0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][60][31:0];
          o_target_re[M_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30f0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][60][31:0];
          o_target_re[S_DOMAIN][60]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30f4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][61][31:0];
          o_target_re[M_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30f4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][61][31:0];
          o_target_re[S_DOMAIN][61]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30f8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][62][31:0];
          o_target_re[M_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30f8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][62][31:0];
          o_target_re[S_DOMAIN][62]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h30fc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][63][31:0];
          o_target_re[M_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h30fc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][63][31:0];
          o_target_re[S_DOMAIN][63]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3100: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][64][31:0];
          o_target_re[M_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3100: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][64][31:0];
          o_target_re[S_DOMAIN][64]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3104: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][65][31:0];
          o_target_re[M_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3104: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][65][31:0];
          o_target_re[S_DOMAIN][65]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3108: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][66][31:0];
          o_target_re[M_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3108: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][66][31:0];
          o_target_re[S_DOMAIN][66]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h310c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][67][31:0];
          o_target_re[M_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h310c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][67][31:0];
          o_target_re[S_DOMAIN][67]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3110: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][68][31:0];
          o_target_re[M_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3110: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][68][31:0];
          o_target_re[S_DOMAIN][68]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3114: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][69][31:0];
          o_target_re[M_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3114: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][69][31:0];
          o_target_re[S_DOMAIN][69]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3118: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][70][31:0];
          o_target_re[M_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3118: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][70][31:0];
          o_target_re[S_DOMAIN][70]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h311c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][71][31:0];
          o_target_re[M_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h311c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][71][31:0];
          o_target_re[S_DOMAIN][71]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3120: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][72][31:0];
          o_target_re[M_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3120: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][72][31:0];
          o_target_re[S_DOMAIN][72]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3124: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][73][31:0];
          o_target_re[M_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3124: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][73][31:0];
          o_target_re[S_DOMAIN][73]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3128: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][74][31:0];
          o_target_re[M_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3128: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][74][31:0];
          o_target_re[S_DOMAIN][74]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h312c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][75][31:0];
          o_target_re[M_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h312c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][75][31:0];
          o_target_re[S_DOMAIN][75]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3130: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][76][31:0];
          o_target_re[M_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3130: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][76][31:0];
          o_target_re[S_DOMAIN][76]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3134: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][77][31:0];
          o_target_re[M_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3134: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][77][31:0];
          o_target_re[S_DOMAIN][77]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3138: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][78][31:0];
          o_target_re[M_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3138: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][78][31:0];
          o_target_re[S_DOMAIN][78]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h313c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][79][31:0];
          o_target_re[M_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h313c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][79][31:0];
          o_target_re[S_DOMAIN][79]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3140: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][80][31:0];
          o_target_re[M_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3140: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][80][31:0];
          o_target_re[S_DOMAIN][80]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3144: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][81][31:0];
          o_target_re[M_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3144: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][81][31:0];
          o_target_re[S_DOMAIN][81]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3148: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][82][31:0];
          o_target_re[M_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3148: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][82][31:0];
          o_target_re[S_DOMAIN][82]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h314c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][83][31:0];
          o_target_re[M_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h314c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][83][31:0];
          o_target_re[S_DOMAIN][83]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3150: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][84][31:0];
          o_target_re[M_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3150: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][84][31:0];
          o_target_re[S_DOMAIN][84]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3154: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][85][31:0];
          o_target_re[M_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3154: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][85][31:0];
          o_target_re[S_DOMAIN][85]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3158: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][86][31:0];
          o_target_re[M_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3158: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][86][31:0];
          o_target_re[S_DOMAIN][86]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h315c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][87][31:0];
          o_target_re[M_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h315c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][87][31:0];
          o_target_re[S_DOMAIN][87]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3160: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][88][31:0];
          o_target_re[M_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3160: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][88][31:0];
          o_target_re[S_DOMAIN][88]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3164: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][89][31:0];
          o_target_re[M_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3164: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][89][31:0];
          o_target_re[S_DOMAIN][89]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3168: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][90][31:0];
          o_target_re[M_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3168: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][90][31:0];
          o_target_re[S_DOMAIN][90]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h316c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][91][31:0];
          o_target_re[M_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h316c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][91][31:0];
          o_target_re[S_DOMAIN][91]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3170: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][92][31:0];
          o_target_re[M_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3170: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][92][31:0];
          o_target_re[S_DOMAIN][92]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3174: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][93][31:0];
          o_target_re[M_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3174: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][93][31:0];
          o_target_re[S_DOMAIN][93]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3178: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][94][31:0];
          o_target_re[M_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3178: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][94][31:0];
          o_target_re[S_DOMAIN][94]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h317c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][95][31:0];
          o_target_re[M_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h317c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][95][31:0];
          o_target_re[S_DOMAIN][95]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3180: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][96][31:0];
          o_target_re[M_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3180: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][96][31:0];
          o_target_re[S_DOMAIN][96]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3184: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][97][31:0];
          o_target_re[M_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3184: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][97][31:0];
          o_target_re[S_DOMAIN][97]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3188: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][98][31:0];
          o_target_re[M_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3188: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][98][31:0];
          o_target_re[S_DOMAIN][98]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h318c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][99][31:0];
          o_target_re[M_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h318c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][99][31:0];
          o_target_re[S_DOMAIN][99]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3190: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][100][31:0];
          o_target_re[M_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3190: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][100][31:0];
          o_target_re[S_DOMAIN][100]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3194: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][101][31:0];
          o_target_re[M_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3194: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][101][31:0];
          o_target_re[S_DOMAIN][101]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3198: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][102][31:0];
          o_target_re[M_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3198: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][102][31:0];
          o_target_re[S_DOMAIN][102]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h319c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][103][31:0];
          o_target_re[M_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h319c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][103][31:0];
          o_target_re[S_DOMAIN][103]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31a0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][104][31:0];
          o_target_re[M_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31a0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][104][31:0];
          o_target_re[S_DOMAIN][104]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31a4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][105][31:0];
          o_target_re[M_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31a4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][105][31:0];
          o_target_re[S_DOMAIN][105]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31a8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][106][31:0];
          o_target_re[M_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31a8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][106][31:0];
          o_target_re[S_DOMAIN][106]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31ac: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][107][31:0];
          o_target_re[M_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31ac: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][107][31:0];
          o_target_re[S_DOMAIN][107]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31b0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][108][31:0];
          o_target_re[M_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31b0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][108][31:0];
          o_target_re[S_DOMAIN][108]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31b4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][109][31:0];
          o_target_re[M_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31b4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][109][31:0];
          o_target_re[S_DOMAIN][109]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31b8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][110][31:0];
          o_target_re[M_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31b8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][110][31:0];
          o_target_re[S_DOMAIN][110]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31bc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][111][31:0];
          o_target_re[M_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31bc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][111][31:0];
          o_target_re[S_DOMAIN][111]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][112][31:0];
          o_target_re[M_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][112][31:0];
          o_target_re[S_DOMAIN][112]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][113][31:0];
          o_target_re[M_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][113][31:0];
          o_target_re[S_DOMAIN][113]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31c8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][114][31:0];
          o_target_re[M_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31c8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][114][31:0];
          o_target_re[S_DOMAIN][114]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31cc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][115][31:0];
          o_target_re[M_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31cc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][115][31:0];
          o_target_re[S_DOMAIN][115]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31d0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][116][31:0];
          o_target_re[M_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31d0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][116][31:0];
          o_target_re[S_DOMAIN][116]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31d4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][117][31:0];
          o_target_re[M_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31d4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][117][31:0];
          o_target_re[S_DOMAIN][117]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31d8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][118][31:0];
          o_target_re[M_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31d8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][118][31:0];
          o_target_re[S_DOMAIN][118]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31dc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][119][31:0];
          o_target_re[M_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31dc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][119][31:0];
          o_target_re[S_DOMAIN][119]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31e0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][120][31:0];
          o_target_re[M_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31e0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][120][31:0];
          o_target_re[S_DOMAIN][120]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31e4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][121][31:0];
          o_target_re[M_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31e4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][121][31:0];
          o_target_re[S_DOMAIN][121]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31e8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][122][31:0];
          o_target_re[M_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31e8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][122][31:0];
          o_target_re[S_DOMAIN][122]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31ec: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][123][31:0];
          o_target_re[M_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31ec: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][123][31:0];
          o_target_re[S_DOMAIN][123]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31f0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][124][31:0];
          o_target_re[M_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31f0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][124][31:0];
          o_target_re[S_DOMAIN][124]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31f4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][125][31:0];
          o_target_re[M_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31f4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][125][31:0];
          o_target_re[S_DOMAIN][125]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31f8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][126][31:0];
          o_target_re[M_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31f8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][126][31:0];
          o_target_re[S_DOMAIN][126]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h31fc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][127][31:0];
          o_target_re[M_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h31fc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][127][31:0];
          o_target_re[S_DOMAIN][127]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3200: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][128][31:0];
          o_target_re[M_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3200: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][128][31:0];
          o_target_re[S_DOMAIN][128]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3204: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][129][31:0];
          o_target_re[M_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3204: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][129][31:0];
          o_target_re[S_DOMAIN][129]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3208: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][130][31:0];
          o_target_re[M_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3208: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][130][31:0];
          o_target_re[S_DOMAIN][130]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h320c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][131][31:0];
          o_target_re[M_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h320c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][131][31:0];
          o_target_re[S_DOMAIN][131]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3210: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][132][31:0];
          o_target_re[M_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3210: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][132][31:0];
          o_target_re[S_DOMAIN][132]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3214: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][133][31:0];
          o_target_re[M_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3214: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][133][31:0];
          o_target_re[S_DOMAIN][133]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3218: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][134][31:0];
          o_target_re[M_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3218: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][134][31:0];
          o_target_re[S_DOMAIN][134]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h321c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][135][31:0];
          o_target_re[M_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h321c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][135][31:0];
          o_target_re[S_DOMAIN][135]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3220: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][136][31:0];
          o_target_re[M_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3220: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][136][31:0];
          o_target_re[S_DOMAIN][136]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3224: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][137][31:0];
          o_target_re[M_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3224: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][137][31:0];
          o_target_re[S_DOMAIN][137]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3228: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][138][31:0];
          o_target_re[M_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3228: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][138][31:0];
          o_target_re[S_DOMAIN][138]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h322c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][139][31:0];
          o_target_re[M_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h322c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][139][31:0];
          o_target_re[S_DOMAIN][139]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3230: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][140][31:0];
          o_target_re[M_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3230: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][140][31:0];
          o_target_re[S_DOMAIN][140]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3234: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][141][31:0];
          o_target_re[M_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3234: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][141][31:0];
          o_target_re[S_DOMAIN][141]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3238: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][142][31:0];
          o_target_re[M_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3238: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][142][31:0];
          o_target_re[S_DOMAIN][142]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h323c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][143][31:0];
          o_target_re[M_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h323c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][143][31:0];
          o_target_re[S_DOMAIN][143]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3240: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][144][31:0];
          o_target_re[M_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3240: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][144][31:0];
          o_target_re[S_DOMAIN][144]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3244: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][145][31:0];
          o_target_re[M_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3244: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][145][31:0];
          o_target_re[S_DOMAIN][145]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3248: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][146][31:0];
          o_target_re[M_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3248: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][146][31:0];
          o_target_re[S_DOMAIN][146]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h324c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][147][31:0];
          o_target_re[M_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h324c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][147][31:0];
          o_target_re[S_DOMAIN][147]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3250: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][148][31:0];
          o_target_re[M_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3250: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][148][31:0];
          o_target_re[S_DOMAIN][148]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3254: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][149][31:0];
          o_target_re[M_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3254: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][149][31:0];
          o_target_re[S_DOMAIN][149]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3258: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][150][31:0];
          o_target_re[M_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3258: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][150][31:0];
          o_target_re[S_DOMAIN][150]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h325c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][151][31:0];
          o_target_re[M_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h325c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][151][31:0];
          o_target_re[S_DOMAIN][151]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3260: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][152][31:0];
          o_target_re[M_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3260: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][152][31:0];
          o_target_re[S_DOMAIN][152]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3264: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][153][31:0];
          o_target_re[M_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3264: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][153][31:0];
          o_target_re[S_DOMAIN][153]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3268: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][154][31:0];
          o_target_re[M_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3268: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][154][31:0];
          o_target_re[S_DOMAIN][154]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h326c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][155][31:0];
          o_target_re[M_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h326c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][155][31:0];
          o_target_re[S_DOMAIN][155]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3270: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][156][31:0];
          o_target_re[M_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3270: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][156][31:0];
          o_target_re[S_DOMAIN][156]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3274: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][157][31:0];
          o_target_re[M_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3274: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][157][31:0];
          o_target_re[S_DOMAIN][157]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3278: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][158][31:0];
          o_target_re[M_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3278: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][158][31:0];
          o_target_re[S_DOMAIN][158]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h327c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][159][31:0];
          o_target_re[M_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h327c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][159][31:0];
          o_target_re[S_DOMAIN][159]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3280: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][160][31:0];
          o_target_re[M_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3280: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][160][31:0];
          o_target_re[S_DOMAIN][160]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3284: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][161][31:0];
          o_target_re[M_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3284: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][161][31:0];
          o_target_re[S_DOMAIN][161]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3288: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][162][31:0];
          o_target_re[M_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3288: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][162][31:0];
          o_target_re[S_DOMAIN][162]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h328c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][163][31:0];
          o_target_re[M_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h328c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][163][31:0];
          o_target_re[S_DOMAIN][163]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3290: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][164][31:0];
          o_target_re[M_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3290: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][164][31:0];
          o_target_re[S_DOMAIN][164]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3294: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][165][31:0];
          o_target_re[M_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3294: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][165][31:0];
          o_target_re[S_DOMAIN][165]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3298: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][166][31:0];
          o_target_re[M_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3298: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][166][31:0];
          o_target_re[S_DOMAIN][166]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h329c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][167][31:0];
          o_target_re[M_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h329c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][167][31:0];
          o_target_re[S_DOMAIN][167]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32a0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][168][31:0];
          o_target_re[M_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32a0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][168][31:0];
          o_target_re[S_DOMAIN][168]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32a4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][169][31:0];
          o_target_re[M_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32a4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][169][31:0];
          o_target_re[S_DOMAIN][169]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32a8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][170][31:0];
          o_target_re[M_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32a8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][170][31:0];
          o_target_re[S_DOMAIN][170]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32ac: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][171][31:0];
          o_target_re[M_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32ac: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][171][31:0];
          o_target_re[S_DOMAIN][171]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32b0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][172][31:0];
          o_target_re[M_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32b0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][172][31:0];
          o_target_re[S_DOMAIN][172]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32b4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][173][31:0];
          o_target_re[M_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32b4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][173][31:0];
          o_target_re[S_DOMAIN][173]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32b8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][174][31:0];
          o_target_re[M_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32b8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][174][31:0];
          o_target_re[S_DOMAIN][174]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32bc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][175][31:0];
          o_target_re[M_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32bc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][175][31:0];
          o_target_re[S_DOMAIN][175]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][176][31:0];
          o_target_re[M_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][176][31:0];
          o_target_re[S_DOMAIN][176]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][177][31:0];
          o_target_re[M_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][177][31:0];
          o_target_re[S_DOMAIN][177]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32c8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][178][31:0];
          o_target_re[M_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32c8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][178][31:0];
          o_target_re[S_DOMAIN][178]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32cc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][179][31:0];
          o_target_re[M_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32cc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][179][31:0];
          o_target_re[S_DOMAIN][179]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32d0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][180][31:0];
          o_target_re[M_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32d0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][180][31:0];
          o_target_re[S_DOMAIN][180]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32d4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][181][31:0];
          o_target_re[M_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32d4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][181][31:0];
          o_target_re[S_DOMAIN][181]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32d8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][182][31:0];
          o_target_re[M_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32d8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][182][31:0];
          o_target_re[S_DOMAIN][182]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32dc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][183][31:0];
          o_target_re[M_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32dc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][183][31:0];
          o_target_re[S_DOMAIN][183]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32e0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][184][31:0];
          o_target_re[M_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32e0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][184][31:0];
          o_target_re[S_DOMAIN][184]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32e4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][185][31:0];
          o_target_re[M_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32e4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][185][31:0];
          o_target_re[S_DOMAIN][185]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32e8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][186][31:0];
          o_target_re[M_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32e8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][186][31:0];
          o_target_re[S_DOMAIN][186]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32ec: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][187][31:0];
          o_target_re[M_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32ec: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][187][31:0];
          o_target_re[S_DOMAIN][187]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32f0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][188][31:0];
          o_target_re[M_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32f0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][188][31:0];
          o_target_re[S_DOMAIN][188]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32f4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][189][31:0];
          o_target_re[M_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32f4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][189][31:0];
          o_target_re[S_DOMAIN][189]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32f8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][190][31:0];
          o_target_re[M_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32f8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][190][31:0];
          o_target_re[S_DOMAIN][190]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h32fc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][191][31:0];
          o_target_re[M_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h32fc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][191][31:0];
          o_target_re[S_DOMAIN][191]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3300: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][192][31:0];
          o_target_re[M_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3300: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][192][31:0];
          o_target_re[S_DOMAIN][192]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3304: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][193][31:0];
          o_target_re[M_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3304: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][193][31:0];
          o_target_re[S_DOMAIN][193]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3308: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][194][31:0];
          o_target_re[M_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3308: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][194][31:0];
          o_target_re[S_DOMAIN][194]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h330c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][195][31:0];
          o_target_re[M_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h330c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][195][31:0];
          o_target_re[S_DOMAIN][195]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3310: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][196][31:0];
          o_target_re[M_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3310: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][196][31:0];
          o_target_re[S_DOMAIN][196]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3314: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][197][31:0];
          o_target_re[M_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3314: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][197][31:0];
          o_target_re[S_DOMAIN][197]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3318: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][198][31:0];
          o_target_re[M_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3318: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][198][31:0];
          o_target_re[S_DOMAIN][198]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h331c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][199][31:0];
          o_target_re[M_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h331c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][199][31:0];
          o_target_re[S_DOMAIN][199]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3320: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][200][31:0];
          o_target_re[M_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3320: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][200][31:0];
          o_target_re[S_DOMAIN][200]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3324: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][201][31:0];
          o_target_re[M_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3324: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][201][31:0];
          o_target_re[S_DOMAIN][201]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3328: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][202][31:0];
          o_target_re[M_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3328: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][202][31:0];
          o_target_re[S_DOMAIN][202]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h332c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][203][31:0];
          o_target_re[M_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h332c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][203][31:0];
          o_target_re[S_DOMAIN][203]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3330: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][204][31:0];
          o_target_re[M_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3330: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][204][31:0];
          o_target_re[S_DOMAIN][204]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3334: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][205][31:0];
          o_target_re[M_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3334: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][205][31:0];
          o_target_re[S_DOMAIN][205]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3338: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][206][31:0];
          o_target_re[M_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3338: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][206][31:0];
          o_target_re[S_DOMAIN][206]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h333c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][207][31:0];
          o_target_re[M_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h333c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][207][31:0];
          o_target_re[S_DOMAIN][207]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3340: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][208][31:0];
          o_target_re[M_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3340: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][208][31:0];
          o_target_re[S_DOMAIN][208]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3344: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][209][31:0];
          o_target_re[M_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3344: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][209][31:0];
          o_target_re[S_DOMAIN][209]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3348: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][210][31:0];
          o_target_re[M_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3348: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][210][31:0];
          o_target_re[S_DOMAIN][210]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h334c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][211][31:0];
          o_target_re[M_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h334c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][211][31:0];
          o_target_re[S_DOMAIN][211]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3350: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][212][31:0];
          o_target_re[M_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3350: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][212][31:0];
          o_target_re[S_DOMAIN][212]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3354: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][213][31:0];
          o_target_re[M_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3354: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][213][31:0];
          o_target_re[S_DOMAIN][213]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3358: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][214][31:0];
          o_target_re[M_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3358: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][214][31:0];
          o_target_re[S_DOMAIN][214]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h335c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][215][31:0];
          o_target_re[M_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h335c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][215][31:0];
          o_target_re[S_DOMAIN][215]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3360: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][216][31:0];
          o_target_re[M_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3360: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][216][31:0];
          o_target_re[S_DOMAIN][216]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3364: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][217][31:0];
          o_target_re[M_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3364: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][217][31:0];
          o_target_re[S_DOMAIN][217]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3368: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][218][31:0];
          o_target_re[M_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3368: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][218][31:0];
          o_target_re[S_DOMAIN][218]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h336c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][219][31:0];
          o_target_re[M_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h336c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][219][31:0];
          o_target_re[S_DOMAIN][219]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3370: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][220][31:0];
          o_target_re[M_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3370: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][220][31:0];
          o_target_re[S_DOMAIN][220]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3374: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][221][31:0];
          o_target_re[M_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3374: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][221][31:0];
          o_target_re[S_DOMAIN][221]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3378: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][222][31:0];
          o_target_re[M_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3378: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][222][31:0];
          o_target_re[S_DOMAIN][222]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h337c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][223][31:0];
          o_target_re[M_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h337c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][223][31:0];
          o_target_re[S_DOMAIN][223]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3380: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][224][31:0];
          o_target_re[M_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3380: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][224][31:0];
          o_target_re[S_DOMAIN][224]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3384: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][225][31:0];
          o_target_re[M_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3384: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][225][31:0];
          o_target_re[S_DOMAIN][225]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3388: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][226][31:0];
          o_target_re[M_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3388: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][226][31:0];
          o_target_re[S_DOMAIN][226]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h338c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][227][31:0];
          o_target_re[M_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h338c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][227][31:0];
          o_target_re[S_DOMAIN][227]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3390: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][228][31:0];
          o_target_re[M_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3390: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][228][31:0];
          o_target_re[S_DOMAIN][228]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3394: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][229][31:0];
          o_target_re[M_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3394: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][229][31:0];
          o_target_re[S_DOMAIN][229]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h3398: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][230][31:0];
          o_target_re[M_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h3398: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][230][31:0];
          o_target_re[S_DOMAIN][230]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h339c: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][231][31:0];
          o_target_re[M_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h339c: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][231][31:0];
          o_target_re[S_DOMAIN][231]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33a0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][232][31:0];
          o_target_re[M_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33a0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][232][31:0];
          o_target_re[S_DOMAIN][232]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33a4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][233][31:0];
          o_target_re[M_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33a4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][233][31:0];
          o_target_re[S_DOMAIN][233]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33a8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][234][31:0];
          o_target_re[M_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33a8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][234][31:0];
          o_target_re[S_DOMAIN][234]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33ac: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][235][31:0];
          o_target_re[M_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33ac: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][235][31:0];
          o_target_re[S_DOMAIN][235]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33b0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][236][31:0];
          o_target_re[M_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33b0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][236][31:0];
          o_target_re[S_DOMAIN][236]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33b4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][237][31:0];
          o_target_re[M_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33b4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][237][31:0];
          o_target_re[S_DOMAIN][237]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33b8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][238][31:0];
          o_target_re[M_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33b8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][238][31:0];
          o_target_re[S_DOMAIN][238]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33bc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][239][31:0];
          o_target_re[M_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33bc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][239][31:0];
          o_target_re[S_DOMAIN][239]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][240][31:0];
          o_target_re[M_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][240][31:0];
          o_target_re[S_DOMAIN][240]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][241][31:0];
          o_target_re[M_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][241][31:0];
          o_target_re[S_DOMAIN][241]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33c8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][242][31:0];
          o_target_re[M_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33c8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][242][31:0];
          o_target_re[S_DOMAIN][242]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33cc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][243][31:0];
          o_target_re[M_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33cc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][243][31:0];
          o_target_re[S_DOMAIN][243]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33d0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][244][31:0];
          o_target_re[M_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33d0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][244][31:0];
          o_target_re[S_DOMAIN][244]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33d4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][245][31:0];
          o_target_re[M_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33d4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][245][31:0];
          o_target_re[S_DOMAIN][245]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33d8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][246][31:0];
          o_target_re[M_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33d8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][246][31:0];
          o_target_re[S_DOMAIN][246]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33dc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][247][31:0];
          o_target_re[M_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33dc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][247][31:0];
          o_target_re[S_DOMAIN][247]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33e0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][248][31:0];
          o_target_re[M_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33e0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][248][31:0];
          o_target_re[S_DOMAIN][248]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33e4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][249][31:0];
          o_target_re[M_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33e4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][249][31:0];
          o_target_re[S_DOMAIN][249]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33e8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][250][31:0];
          o_target_re[M_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33e8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][250][31:0];
          o_target_re[S_DOMAIN][250]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33ec: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][251][31:0];
          o_target_re[M_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33ec: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][251][31:0];
          o_target_re[S_DOMAIN][251]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33f0: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][252][31:0];
          o_target_re[M_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33f0: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][252][31:0];
          o_target_re[S_DOMAIN][252]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33f4: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][253][31:0];
          o_target_re[M_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33f4: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][253][31:0];
          o_target_re[S_DOMAIN][253]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33f8: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][254][31:0];
          o_target_re[M_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33f8: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][254][31:0];
          o_target_re[S_DOMAIN][254]      = 1'b1;
        end
        DOMAIN_M_ADDR + 32'h33fc: begin
          o_resp.rdata[31:0]     = i_target[M_DOMAIN][255][31:0];
          o_target_re[M_DOMAIN][255]      = 1'b1;
        end
        DOMAIN_S_ADDR + 32'h33fc: begin
          o_resp.rdata[31:0]     = i_target[S_DOMAIN][255][31:0];
          o_target_re[S_DOMAIN][255]      = 1'b1;
        end
        default: o_resp.error = 1'b1;
      endcase
    end
  end
end
endmodule

