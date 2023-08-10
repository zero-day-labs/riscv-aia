/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*
* Description: This module is a generic APLIC domain register map.
*              For a given domain unused registers should be unconnected.
*
* Disclaimer:  This file was automatically generated. Edit at your own risk.
*/ 
module aplic_regmap #(
   parameter int                       DOMAIN_ADDR = 32'hc000000,
   parameter int                       NR_SRC      = 32,
   parameter int                       NR_REG      = 0,
   parameter int                       MIN_PRIO    = 6,
   parameter int                       IPRIOLEN    = 3, //(MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
   parameter int                       NR_IDCs     = 1,
   parameter type                      reg_req_t   = logic,
   parameter type                      reg_rsp_t   = logic
) (
  // Register: domaincfg
  input  logic [0:0][31:0]      i_domaincfg,
  output logic [0:0][31:0]      o_domaincfg,
  output logic [0:0]            o_domaincfg_we,
  output logic [0:0]            o_domaincfg_re,
  // Register: sourcecfg
  input  logic [NR_SRC-1:1][10:0]    i_sourcecfg,
  output logic [NR_SRC-1:1][10:0]    o_sourcecfg,
  output logic [NR_SRC-1:1]          o_sourcecfg_we,
  output logic [NR_SRC-1:1]          o_sourcecfg_re,
  // Register: mmsiaddrcfg
  input  logic [0:0][31:0]      i_mmsiaddrcfg,
  output logic [0:0][31:0]      o_mmsiaddrcfg,
  output logic [0:0]            o_mmsiaddrcfg_we,
  output logic [0:0]            o_mmsiaddrcfg_re,
  // Register: mmsiaddrcfgh
  input  logic [0:0][31:0]      i_mmsiaddrcfgh,
  output logic [0:0][31:0]      o_mmsiaddrcfgh,
  output logic [0:0]            o_mmsiaddrcfgh_we,
  output logic [0:0]            o_mmsiaddrcfgh_re,
  // Register: smsiaddrcfg
  input  logic [0:0][31:0]      i_smsiaddrcfg,
  output logic [0:0][31:0]      o_smsiaddrcfg,
  output logic [0:0]            o_smsiaddrcfg_we,
  output logic [0:0]            o_smsiaddrcfg_re,
  // Register: smsiaddrcfgh
  input  logic [0:0][31:0]      i_smsiaddrcfgh,
  output logic [0:0][31:0]      o_smsiaddrcfgh,
  output logic [0:0]            o_smsiaddrcfgh_we,
  output logic [0:0]            o_smsiaddrcfgh_re,
  // Register: setip
  input  logic [NR_REG:0][31:0]      i_setip,
  output logic [NR_REG:0][31:0]      o_setip,
  output logic [NR_REG:0]            o_setip_we,
  output logic [NR_REG:0]            o_setip_re,
  // Register: setipnum
  input  logic [0:0][31:0]      i_setipnum,
  output logic [0:0][31:0]      o_setipnum,
  output logic [0:0]            o_setipnum_we,
  output logic [0:0]            o_setipnum_re,
  // Register: in_clrip
  input  logic [NR_REG:0][31:0]      i_in_clrip,
  output logic [NR_REG:0][31:0]      o_in_clrip,
  output logic [NR_REG:0]            o_in_clrip_we,
  output logic [NR_REG:0]            o_in_clrip_re,
  // Register: clripnum
  input  logic [0:0][31:0]      i_clripnum,
  output logic [0:0][31:0]      o_clripnum,
  output logic [0:0]            o_clripnum_we,
  output logic [0:0]            o_clripnum_re,
  // Register: setie
  input  logic [NR_REG:0][31:0]      i_setie,
  output logic [NR_REG:0][31:0]      o_setie,
  output logic [NR_REG:0]            o_setie_we,
  output logic [NR_REG:0]            o_setie_re,
  // Register: setienum
  input  logic [0:0][31:0]      i_setienum,
  output logic [0:0][31:0]      o_setienum,
  output logic [0:0]            o_setienum_we,
  output logic [0:0]            o_setienum_re,
  // Register: clrie
  input  logic [NR_REG:0][31:0]      i_clrie,
  output logic [NR_REG:0][31:0]      o_clrie,
  output logic [NR_REG:0]            o_clrie_we,
  output logic [NR_REG:0]            o_clrie_re,
  // Register: clrienum
  input  logic [0:0][31:0]      i_clrienum,
  output logic [0:0][31:0]      o_clrienum,
  output logic [0:0]            o_clrienum_we,
  output logic [0:0]            o_clrienum_re,
  // Register: setipnum_le
  input  logic [0:0][31:0]      i_setipnum_le,
  output logic [0:0][31:0]      o_setipnum_le,
  output logic [0:0]            o_setipnum_le_we,
  output logic [0:0]            o_setipnum_le_re,
  // Register: setipnum_be
  input  logic [0:0][31:0]      i_setipnum_be,
  output logic [0:0][31:0]      o_setipnum_be,
  output logic [0:0]            o_setipnum_be_we,
  output logic [0:0]            o_setipnum_be_re,
  // Register: genmsi
  input  logic [0:0][31:0]      i_genmsi,
  output logic [0:0][31:0]      o_genmsi,
  output logic [0:0]            o_genmsi_we,
  output logic [0:0]            o_genmsi_re,
  // Register: target
  input  logic [NR_SRC-1:1][31:0]    i_target,
  output logic [NR_SRC-1:1][31:0]    o_target,
  output logic [NR_SRC-1:1]          o_target_we,
  output logic [NR_SRC-1:1]          o_target_re,
  // Register: idelivery
  input  logic [NR_IDCs-1:0][0:0]    i_idelivery,
  output logic [NR_IDCs-1:0][0:0]    o_idelivery,
  output logic [NR_IDCs-1:0]          o_idelivery_we,
  output logic [NR_IDCs-1:0]          o_idelivery_re,
  // Register: iforce
  input  logic [NR_IDCs-1:0][0:0]    i_iforce,
  output logic [NR_IDCs-1:0][0:0]    o_iforce,
  output logic [NR_IDCs-1:0]          o_iforce_we,
  output logic [NR_IDCs-1:0]          o_iforce_re,
  // Register: ithreshold
  input  logic [NR_IDCs-1:0][IPRIOLEN-1:0]  i_ithreshold,
  output logic [NR_IDCs-1:0][IPRIOLEN-1:0]  o_ithreshold,
  output logic [NR_IDCs-1:0]          o_ithreshold_we,
  output logic [NR_IDCs-1:0]          o_ithreshold_re,
  // Register: topi
  input  logic [NR_IDCs-1:0][25:0]    i_topi,
  output logic [NR_IDCs-1:0]          o_topi_re,
  // Register: claimi
  input  logic [NR_IDCs-1:0][25:0]    i_claimi,
  output logic [NR_IDCs-1:0]          o_claimi_re,
  // Bus Interface
  input  reg_req_t                    i_req,
  output reg_rsp_t                    o_resp
);
always_comb begin
  o_resp.ready = 1'b1;
  o_resp.rdata = '0;
  o_resp.error = '0;
  `ifdef MSI_MODE
  o_domaincfg = 32'h80000010;
  `else
  o_domaincfg = 32'h80000000;
  `endif
  o_domaincfg_we = '0;
  o_domaincfg_re = '0;
  o_sourcecfg = '0;
  o_sourcecfg_we = '0;
  o_sourcecfg_re = '0;
  o_mmsiaddrcfg = '0;
  o_mmsiaddrcfg_we = '0;
  o_mmsiaddrcfg_re = '0;
  o_mmsiaddrcfgh = 32'h80000000;
  o_mmsiaddrcfgh_we = '0;
  o_mmsiaddrcfgh_re = '0;
  o_smsiaddrcfg = '0;
  o_smsiaddrcfg_we = '0;
  o_smsiaddrcfg_re = '0;
  o_smsiaddrcfgh = '0;
  o_smsiaddrcfgh_we = '0;
  o_smsiaddrcfgh_re = '0;
  o_setip = '0;
  o_setip_we = '0;
  o_setip_re = '0;
  o_setipnum = '0;
  o_setipnum_we = '0;
  o_setipnum_re = '0;
  o_in_clrip = '0;
  o_in_clrip_we = '0;
  o_in_clrip_re = '0;
  o_clripnum = '0;
  o_clripnum_we = '0;
  o_clripnum_re = '0;
  o_setie = '0;
  o_setie_we = '0;
  o_setie_re = '0;
  o_setienum = '0;
  o_setienum_we = '0;
  o_setienum_re = '0;
  o_clrie = '0;
  o_clrie_we = '0;
  o_clrie_re = '0;
  o_clrienum = '0;
  o_clrienum_we = '0;
  o_clrienum_re = '0;
  o_setipnum_le = '0;
  o_setipnum_le_we = '0;
  o_setipnum_le_re = '0;
  o_setipnum_be = '0;
  o_setipnum_be_we = '0;
  o_setipnum_be_re = '0;
  o_genmsi = '0;
  o_genmsi_we = '0;
  o_genmsi_re = '0;
  o_target = '0;
  o_target_we = '0;
  o_target_re = '0;
  o_idelivery = '0;
  o_idelivery_we = '0;
  o_idelivery_re = '0;
  o_claimi_re = '0;
  o_topi_re = '0;
  o_iforce = '0;
  o_iforce_we = '0;
  o_iforce_re = '0;
  o_ithreshold = '0;
  o_ithreshold_we = '0;
  o_ithreshold_re = '0;
  if (i_req.valid) begin
    if (i_req.write) begin
      unique case(i_req.addr)
        DOMAIN_ADDR + 32'h0: begin
          o_domaincfg[0][31:0]     = i_req.wdata[31:0];
          o_domaincfg_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4: begin
          o_sourcecfg[1][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[1]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h8: begin
          o_sourcecfg[2][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[2]      = 1'b1;
        end
        DOMAIN_ADDR + 32'hc: begin
          o_sourcecfg[3][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[3]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h10: begin
          o_sourcecfg[4][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[4]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h14: begin
          o_sourcecfg[5][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[5]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h18: begin
          o_sourcecfg[6][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[6]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1c: begin
          o_sourcecfg[7][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[7]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h20: begin
          o_sourcecfg[8][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[8]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h24: begin
          o_sourcecfg[9][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[9]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h28: begin
          o_sourcecfg[10][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[10]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h2c: begin
          o_sourcecfg[11][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[11]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h30: begin
          o_sourcecfg[12][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[12]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h34: begin
          o_sourcecfg[13][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[13]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h38: begin
          o_sourcecfg[14][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[14]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3c: begin
          o_sourcecfg[15][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[15]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h40: begin
          o_sourcecfg[16][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[16]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h44: begin
          o_sourcecfg[17][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[17]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h48: begin
          o_sourcecfg[18][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[18]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4c: begin
          o_sourcecfg[19][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[19]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h50: begin
          o_sourcecfg[20][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[20]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h54: begin
          o_sourcecfg[21][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[21]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h58: begin
          o_sourcecfg[22][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[22]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h5c: begin
          o_sourcecfg[23][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[23]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h60: begin
          o_sourcecfg[24][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[24]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h64: begin
          o_sourcecfg[25][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[25]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h68: begin
          o_sourcecfg[26][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[26]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h6c: begin
          o_sourcecfg[27][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[27]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h70: begin
          o_sourcecfg[28][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[28]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h74: begin
          o_sourcecfg[29][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[29]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h78: begin
          o_sourcecfg[30][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[30]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h7c: begin
          o_sourcecfg[31][10:0]     = i_req.wdata[10:0];
          o_sourcecfg_we[31]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bc0: begin
          o_mmsiaddrcfg[0][31:0]     = i_req.wdata[31:0];
          o_mmsiaddrcfg_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bc4: begin
          o_mmsiaddrcfgh[0][31:0]     = i_req.wdata[31:0];
          o_mmsiaddrcfgh_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bc8: begin
          o_smsiaddrcfg[0][31:0]     = i_req.wdata[31:0];
          o_smsiaddrcfg_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bcc: begin
          o_smsiaddrcfgh[0][31:0]     = i_req.wdata[31:0];
          o_smsiaddrcfgh_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1c00: begin
          o_setip[0][31:0]     = i_req.wdata[31:0];
          o_setip_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1cdc: begin
          o_setipnum[0][31:0]     = i_req.wdata[31:0];
          o_setipnum_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1d00: begin
          o_in_clrip[0][31:0]     = i_req.wdata[31:0];
          o_in_clrip_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1ddc: begin
          o_clripnum[0][31:0]     = i_req.wdata[31:0];
          o_clripnum_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1e00: begin
          o_setie[0][31:0]     = i_req.wdata[31:0];
          o_setie_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1edc: begin
          o_setienum[0][31:0]     = i_req.wdata[31:0];
          o_setienum_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1f00: begin
          o_clrie[0][31:0]     = i_req.wdata[31:0];
          o_clrie_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1fdc: begin
          o_clrienum[0][31:0]     = i_req.wdata[31:0];
          o_clrienum_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h2000: begin
          o_setipnum_le[0][31:0]     = i_req.wdata[31:0];
          o_setipnum_le_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h2004: begin
          o_setipnum_be[0][31:0]     = i_req.wdata[31:0];
          o_setipnum_be_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3000: begin
          o_genmsi[0][31:0]     = i_req.wdata[31:0];
          o_genmsi_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3004: begin
          o_target[1][31:0]     = i_req.wdata[31:0];
          o_target_we[1]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3008: begin
          o_target[2][31:0]     = i_req.wdata[31:0];
          o_target_we[2]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h300c: begin
          o_target[3][31:0]     = i_req.wdata[31:0];
          o_target_we[3]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3010: begin
          o_target[4][31:0]     = i_req.wdata[31:0];
          o_target_we[4]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3014: begin
          o_target[5][31:0]     = i_req.wdata[31:0];
          o_target_we[5]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3018: begin
          o_target[6][31:0]     = i_req.wdata[31:0];
          o_target_we[6]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h301c: begin
          o_target[7][31:0]     = i_req.wdata[31:0];
          o_target_we[7]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3020: begin
          o_target[8][31:0]     = i_req.wdata[31:0];
          o_target_we[8]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3024: begin
          o_target[9][31:0]     = i_req.wdata[31:0];
          o_target_we[9]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3028: begin
          o_target[10][31:0]     = i_req.wdata[31:0];
          o_target_we[10]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h302c: begin
          o_target[11][31:0]     = i_req.wdata[31:0];
          o_target_we[11]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3030: begin
          o_target[12][31:0]     = i_req.wdata[31:0];
          o_target_we[12]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3034: begin
          o_target[13][31:0]     = i_req.wdata[31:0];
          o_target_we[13]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3038: begin
          o_target[14][31:0]     = i_req.wdata[31:0];
          o_target_we[14]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h303c: begin
          o_target[15][31:0]     = i_req.wdata[31:0];
          o_target_we[15]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3040: begin
          o_target[16][31:0]     = i_req.wdata[31:0];
          o_target_we[16]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3044: begin
          o_target[17][31:0]     = i_req.wdata[31:0];
          o_target_we[17]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3048: begin
          o_target[18][31:0]     = i_req.wdata[31:0];
          o_target_we[18]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h304c: begin
          o_target[19][31:0]     = i_req.wdata[31:0];
          o_target_we[19]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3050: begin
          o_target[20][31:0]     = i_req.wdata[31:0];
          o_target_we[20]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3054: begin
          o_target[21][31:0]     = i_req.wdata[31:0];
          o_target_we[21]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3058: begin
          o_target[22][31:0]     = i_req.wdata[31:0];
          o_target_we[22]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h305c: begin
          o_target[23][31:0]     = i_req.wdata[31:0];
          o_target_we[23]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3060: begin
          o_target[24][31:0]     = i_req.wdata[31:0];
          o_target_we[24]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3064: begin
          o_target[25][31:0]     = i_req.wdata[31:0];
          o_target_we[25]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3068: begin
          o_target[26][31:0]     = i_req.wdata[31:0];
          o_target_we[26]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h306c: begin
          o_target[27][31:0]     = i_req.wdata[31:0];
          o_target_we[27]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3070: begin
          o_target[28][31:0]     = i_req.wdata[31:0];
          o_target_we[28]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3074: begin
          o_target[29][31:0]     = i_req.wdata[31:0];
          o_target_we[29]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3078: begin
          o_target[30][31:0]     = i_req.wdata[31:0];
          o_target_we[30]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h307c: begin
          o_target[31][31:0]     = i_req.wdata[31:0];
          o_target_we[31]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4000: begin
          o_idelivery[0][0:0]     = i_req.wdata[0:0];
          o_idelivery_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4004: begin
          o_iforce[0][0:0]     = i_req.wdata[0:0];
          o_iforce_we[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4008: begin
          o_ithreshold[0][IPRIOLEN-1:0]     = i_req.wdata[IPRIOLEN-1:0];
          o_ithreshold_we[0]      = 1'b1;
        end
        default: o_resp.error = 1'b1;
      endcase
    end else begin
      unique case(i_req.addr)
        DOMAIN_ADDR + 32'h0: begin
          o_resp.rdata[31:0]     = i_domaincfg[0][31:0];
          o_domaincfg_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4: begin
          o_resp.rdata[10:0]     = i_sourcecfg[1][10:0];
          o_sourcecfg_re[1]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h8: begin
          o_resp.rdata[10:0]     = i_sourcecfg[2][10:0];
          o_sourcecfg_re[2]      = 1'b1;
        end
        DOMAIN_ADDR + 32'hc: begin
          o_resp.rdata[10:0]     = i_sourcecfg[3][10:0];
          o_sourcecfg_re[3]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h10: begin
          o_resp.rdata[10:0]     = i_sourcecfg[4][10:0];
          o_sourcecfg_re[4]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h14: begin
          o_resp.rdata[10:0]     = i_sourcecfg[5][10:0];
          o_sourcecfg_re[5]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h18: begin
          o_resp.rdata[10:0]     = i_sourcecfg[6][10:0];
          o_sourcecfg_re[6]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[7][10:0];
          o_sourcecfg_re[7]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h20: begin
          o_resp.rdata[10:0]     = i_sourcecfg[8][10:0];
          o_sourcecfg_re[8]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h24: begin
          o_resp.rdata[10:0]     = i_sourcecfg[9][10:0];
          o_sourcecfg_re[9]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h28: begin
          o_resp.rdata[10:0]     = i_sourcecfg[10][10:0];
          o_sourcecfg_re[10]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h2c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[11][10:0];
          o_sourcecfg_re[11]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h30: begin
          o_resp.rdata[10:0]     = i_sourcecfg[12][10:0];
          o_sourcecfg_re[12]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h34: begin
          o_resp.rdata[10:0]     = i_sourcecfg[13][10:0];
          o_sourcecfg_re[13]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h38: begin
          o_resp.rdata[10:0]     = i_sourcecfg[14][10:0];
          o_sourcecfg_re[14]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[15][10:0];
          o_sourcecfg_re[15]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h40: begin
          o_resp.rdata[10:0]     = i_sourcecfg[16][10:0];
          o_sourcecfg_re[16]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h44: begin
          o_resp.rdata[10:0]     = i_sourcecfg[17][10:0];
          o_sourcecfg_re[17]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h48: begin
          o_resp.rdata[10:0]     = i_sourcecfg[18][10:0];
          o_sourcecfg_re[18]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[19][10:0];
          o_sourcecfg_re[19]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h50: begin
          o_resp.rdata[10:0]     = i_sourcecfg[20][10:0];
          o_sourcecfg_re[20]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h54: begin
          o_resp.rdata[10:0]     = i_sourcecfg[21][10:0];
          o_sourcecfg_re[21]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h58: begin
          o_resp.rdata[10:0]     = i_sourcecfg[22][10:0];
          o_sourcecfg_re[22]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h5c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[23][10:0];
          o_sourcecfg_re[23]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h60: begin
          o_resp.rdata[10:0]     = i_sourcecfg[24][10:0];
          o_sourcecfg_re[24]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h64: begin
          o_resp.rdata[10:0]     = i_sourcecfg[25][10:0];
          o_sourcecfg_re[25]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h68: begin
          o_resp.rdata[10:0]     = i_sourcecfg[26][10:0];
          o_sourcecfg_re[26]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h6c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[27][10:0];
          o_sourcecfg_re[27]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h70: begin
          o_resp.rdata[10:0]     = i_sourcecfg[28][10:0];
          o_sourcecfg_re[28]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h74: begin
          o_resp.rdata[10:0]     = i_sourcecfg[29][10:0];
          o_sourcecfg_re[29]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h78: begin
          o_resp.rdata[10:0]     = i_sourcecfg[30][10:0];
          o_sourcecfg_re[30]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h7c: begin
          o_resp.rdata[10:0]     = i_sourcecfg[31][10:0];
          o_sourcecfg_re[31]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bc0: begin
          o_resp.rdata[31:0]     = i_mmsiaddrcfg[0][31:0];
          o_mmsiaddrcfg_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bc4: begin
          o_resp.rdata[31:0]     = i_mmsiaddrcfgh[0][31:0];
          o_mmsiaddrcfgh_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bc8: begin
          o_resp.rdata[31:0]     = i_smsiaddrcfg[0][31:0];
          o_smsiaddrcfg_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1bcc: begin
          o_resp.rdata[31:0]     = i_smsiaddrcfgh[0][31:0];
          o_smsiaddrcfgh_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1c00: begin
          o_resp.rdata[31:0]     = i_setip[0][31:0];
          o_setip_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1cdc: begin
          o_resp.rdata[31:0]     = i_setipnum[0][31:0];
          o_setipnum_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1d00: begin
          o_resp.rdata[31:0]     = i_in_clrip[0][31:0];
          o_in_clrip_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1ddc: begin
          o_resp.rdata[31:0]     = i_clripnum[0][31:0];
          o_clripnum_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1e00: begin
          o_resp.rdata[31:0]     = i_setie[0][31:0];
          o_setie_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1edc: begin
          o_resp.rdata[31:0]     = i_setienum[0][31:0];
          o_setienum_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1f00: begin
          o_resp.rdata[31:0]     = i_clrie[0][31:0];
          o_clrie_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h1fdc: begin
          o_resp.rdata[31:0]     = i_clrienum[0][31:0];
          o_clrienum_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h2000: begin
          o_resp.rdata[31:0]     = i_setipnum_le[0][31:0];
          o_setipnum_le_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h2004: begin
          o_resp.rdata[31:0]     = i_setipnum_be[0][31:0];
          o_setipnum_be_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3000: begin
          o_resp.rdata[31:0]     = i_genmsi[0][31:0];
          o_genmsi_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3004: begin
          o_resp.rdata[31:0]     = i_target[1][31:0];
          o_target_re[1]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3008: begin
          o_resp.rdata[31:0]     = i_target[2][31:0];
          o_target_re[2]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h300c: begin
          o_resp.rdata[31:0]     = i_target[3][31:0];
          o_target_re[3]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3010: begin
          o_resp.rdata[31:0]     = i_target[4][31:0];
          o_target_re[4]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3014: begin
          o_resp.rdata[31:0]     = i_target[5][31:0];
          o_target_re[5]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3018: begin
          o_resp.rdata[31:0]     = i_target[6][31:0];
          o_target_re[6]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h301c: begin
          o_resp.rdata[31:0]     = i_target[7][31:0];
          o_target_re[7]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3020: begin
          o_resp.rdata[31:0]     = i_target[8][31:0];
          o_target_re[8]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3024: begin
          o_resp.rdata[31:0]     = i_target[9][31:0];
          o_target_re[9]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3028: begin
          o_resp.rdata[31:0]     = i_target[10][31:0];
          o_target_re[10]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h302c: begin
          o_resp.rdata[31:0]     = i_target[11][31:0];
          o_target_re[11]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3030: begin
          o_resp.rdata[31:0]     = i_target[12][31:0];
          o_target_re[12]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3034: begin
          o_resp.rdata[31:0]     = i_target[13][31:0];
          o_target_re[13]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3038: begin
          o_resp.rdata[31:0]     = i_target[14][31:0];
          o_target_re[14]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h303c: begin
          o_resp.rdata[31:0]     = i_target[15][31:0];
          o_target_re[15]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3040: begin
          o_resp.rdata[31:0]     = i_target[16][31:0];
          o_target_re[16]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3044: begin
          o_resp.rdata[31:0]     = i_target[17][31:0];
          o_target_re[17]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3048: begin
          o_resp.rdata[31:0]     = i_target[18][31:0];
          o_target_re[18]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h304c: begin
          o_resp.rdata[31:0]     = i_target[19][31:0];
          o_target_re[19]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3050: begin
          o_resp.rdata[31:0]     = i_target[20][31:0];
          o_target_re[20]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3054: begin
          o_resp.rdata[31:0]     = i_target[21][31:0];
          o_target_re[21]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3058: begin
          o_resp.rdata[31:0]     = i_target[22][31:0];
          o_target_re[22]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h305c: begin
          o_resp.rdata[31:0]     = i_target[23][31:0];
          o_target_re[23]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3060: begin
          o_resp.rdata[31:0]     = i_target[24][31:0];
          o_target_re[24]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3064: begin
          o_resp.rdata[31:0]     = i_target[25][31:0];
          o_target_re[25]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3068: begin
          o_resp.rdata[31:0]     = i_target[26][31:0];
          o_target_re[26]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h306c: begin
          o_resp.rdata[31:0]     = i_target[27][31:0];
          o_target_re[27]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3070: begin
          o_resp.rdata[31:0]     = i_target[28][31:0];
          o_target_re[28]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3074: begin
          o_resp.rdata[31:0]     = i_target[29][31:0];
          o_target_re[29]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h3078: begin
          o_resp.rdata[31:0]     = i_target[30][31:0];
          o_target_re[30]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h307c: begin
          o_resp.rdata[31:0]     = i_target[31][31:0];
          o_target_re[31]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4000: begin
          o_resp.rdata[0:0]     = i_idelivery[0][0:0];
          o_idelivery_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4004: begin
          o_resp.rdata[0:0]     = i_iforce[0][0:0];
          o_iforce_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4008: begin
          o_resp.rdata[IPRIOLEN-1:0]     = i_ithreshold[0][IPRIOLEN-1:0];
          o_ithreshold_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h4018: begin
          o_resp.rdata[25:0]     = i_topi[0][25:0];
          o_topi_re[0]      = 1'b1;
        end
        DOMAIN_ADDR + 32'h401c: begin
          o_resp.rdata[25:0]     = i_claimi[0][25:0];
          o_claimi_re[0]      = 1'b1;
        end
        default: o_resp.error = 1'b1;
      endcase
    end
  end
end
endmodule

