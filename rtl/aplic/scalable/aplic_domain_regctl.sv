/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*
* Description: This module is responsible for all the
*              logic used to determine the registers value.
*/

module aplic_domain_regctl #(
    parameter int                                       DOMAIN_ADDR = 32'hc000000,
    parameter int                                       NR_SRC      = 32,
    parameter int                                       MIN_PRIO    = 6,
    parameter int                                       NR_IDCs     = 1,
    parameter                                           APLIC       = "LEAF",
    parameter type                                      reg_req_t   = logic,
    parameter type                                      reg_rsp_t   = logic,
    // DO NOT EDIT BY PARAMETER
    parameter int                                       IPRIOLEN    = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
    parameter int                                       NR_BITS_SRC = (NR_SRC > 31) ? 32 : NR_SRC,
    parameter int                                       NR_SRC_W    = 10,//(NR_SRC == 1) ? 1 : $clog2(NR_SRC),
    parameter int                                       NR_REG      = (NR_SRC-1)/32  
) (
    input   logic                                       i_clk,
    input   logic                                       ni_rst,
    /** Register config: AXI interface From/To system bus */
    input   reg_req_t                                   i_req,
    output  reg_rsp_t                                   o_resp,
    /** Gateway */
    output  logic [NR_SRC-1:1][10:0]                    o_sourcecfg,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]           o_sugg_setip,
    output  logic                                       o_domaincfgDM,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]           o_active,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]           o_claimed_forwarded,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]           i_intp_pen,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]           i_rectified_src,
    input   logic [NR_SRC-1:0][2:0]                     i_intp_pen_src,
    /** Notifier */
    output  logic                                       o_domaincfgIE,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]           o_setip_q,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]           o_setie_q,
    output  logic [NR_SRC-1:1][31:0]                    o_target_q,
    `ifdef MSI_MODE
      /**  interface for msi mode */
    input   logic                                       i_forwarded_valid     ,
    input   logic [10:0]                                i_intp_forwd_id   ,
    output  logic [31:0]                                o_genmsi,
    input   logic                                       i_genmsi_sent,
    `endif
      /**  interface for direct mode */
    output  logic [NR_IDCs-1:0][0:0]                    o_idelivery,
    output  logic [NR_IDCs-1:0][0:0]                    o_iforce,
    output  logic [NR_IDCs-1:0][IPRIOLEN-1:0]           o_ithreshold,
    input   logic [NR_IDCs-1:0][25:0]                   i_topi_sugg,
    input   logic [NR_IDCs-1:0]                         i_topi_update
);

// ==================== LOCAL PARAMETERS ===================
  localparam APLIC_DIRECT_MODE        = 0;
  localparam APLIC_MSI_MODE           = 1;
  localparam NON_DELEGATED            = 0;
  localparam DELEGATED                = 1;
  localparam INACTIVE                 = 3'b000;

  localparam DEFAULT                  = 0;

  localparam CLRIE                    = 3'h1;
  localparam SETIENUM                 = 3'h2;
  localparam CLRIENUM                 = 3'h3;
  localparam W_SETIE                  = 3'h4;

  localparam CLRIP                    = 3'h1;
  localparam SETIPNUM                 = 3'h2;
  localparam CLRIPNUM                 = 3'h3;
  localparam W_SETIP                  = 3'h4;

  localparam ZERO_FORCE               = 2'h1;
  localparam W_FORCE                  = 2'h2;

  localparam INTP_ACTIVE              = 1'b1;
  localparam INTP_NOT_ACTIVE          = 1'b0;

  localparam LEVELXDM1_C              = 3'h4;
// =========================================================

// ============== INTERNAL SIGNALS DEFINITION ==============
  logic [NR_REG:0][NR_BITS_SRC-1:0]   active_i;
  logic [NR_REG:0][NR_BITS_SRC-1:0]   claimed_forwarded_i;
  logic [NR_REG:0][NR_BITS_SRC-1:0]   in_rectified_qi, in_rectified_di;
  logic [NR_IDCs-1:0][25:0]           topi_sugg_i;
  logic [NR_IDCs-1:0]                 topi_update_i;
  /** control */
  logic [2:0]                         setie_select_i, setip_select_i;
  logic [NR_IDCs-1:0][1:0]            iforce_select_i;
// =========================================================

// =============== Register Map instantiation ==============
  // Register domaincfg
  logic [31:0]                        domaincfg_qi, domaincfg_di;
  logic [31:0]                        domaincfg_o;
  logic                               domaincfg_we;
  logic                               domaincfg_re;
  // Register sourcecfg
  logic [NR_SRC-1:1][10:0]            sourcecfg_qi, sourcecfg_di, sourcecfg_aux_di;
  logic [NR_SRC-1:1][10:0]            sourcecfg_o;
  logic [NR_SRC-1:1]                  sourcecfg_we;
  logic [NR_SRC-1:1]                  sourcecfg_re;
  // Register setip
  logic [NR_REG:0][31:0]              setip_qi, setip_di, sugg_setip_i;
  logic [NR_REG:0][31:0]              setip_o;
  logic [NR_REG:0]                    setip_we;
  logic [NR_REG:0]                    setip_re;
  // Register setipnum
  logic [31:0]                        setipnum_qi, setipnum_di;
  logic [31:0]                        setipnum_o;
  logic                               setipnum_we;
  logic                               setipnum_re;
  // Register in_clrip
  logic [NR_REG:0][31:0]              in_clrip_qi, in_clrip_di;
  logic [NR_REG:0][31:0]              in_clrip_o;
  logic [NR_REG:0]                    in_clrip_we;
  logic [NR_REG:0]                    in_clrip_re;
  // Register clripnum
  logic [31:0]                        clripnum_qi, clripnum_di;
  logic [31:0]                        clripnum_o;
  logic                               clripnum_we;
  logic                               clripnum_re;
  // Register setie
  logic [NR_REG:0][31:0]              setie_qi, setie_di, sugg_setie_i;
  logic [NR_REG:0][31:0]              setie_o;
  logic [NR_REG:0]                    setie_we;
  logic [NR_REG:0]                    setie_re;
  // Register setienum
  logic [31:0]                        setienum_qi, setienum_di;
  logic [31:0]                        setienum_o;
  logic                               setienum_we;
  logic                               setienum_re;
  // Register clrie
  logic [NR_REG:0][31:0]              clrie_qi, clrie_di;
  logic [NR_REG:0][31:0]              clrie_o;
  logic [NR_REG:0]                    clrie_we;
  logic [NR_REG:0]                    clrie_re;
  // Register clrienum
  logic [31:0]                        clrienum_qi, clrienum_di;
  logic [31:0]                        clrienum_o;
  logic                               clrienum_we;
  logic                               clrienum_re;
  // Register target
  logic [NR_SRC-1:1][31:0]            target_qi, target_di, target_aux_di;
  logic [NR_SRC-1:1][31:0]            target_o;
  logic [NR_SRC-1:1]                  target_we;
  logic [NR_SRC-1:1]                  target_re;
  // Register idelivery
  logic [NR_IDCs-1:0][0:0]            idelivery_qi, idelivery_di;
  logic [NR_IDCs-1:0][0:0]            idelivery_o;
  logic [NR_IDCs-1:0]                 idelivery_we;
  logic [NR_IDCs-1:0]                 idelivery_re;
  // Register iforce
  logic [NR_IDCs-1:0][0:0]            iforce_qi, iforce_di;
  logic [NR_IDCs-1:0][0:0]            iforce_o;
  logic [NR_IDCs-1:0]                 iforce_we;
  logic [NR_IDCs-1:0]                 iforce_re;
  // Register ithreshold
  logic [NR_IDCs-1:0][IPRIOLEN-1:0]   ithreshold_qi, ithreshold_di;
  logic [NR_IDCs-1:0][IPRIOLEN-1:0]   ithreshold_o;
  logic [NR_IDCs-1:0]                 ithreshold_we;
  logic [NR_IDCs-1:0]                 ithreshold_re;
  // Register topi
  logic [NR_IDCs-1:0][25:0]           topi_qi, topi_di;
  logic [NR_IDCs-1:0]                 topi_re;
  // Register claimi
  logic [NR_IDCs-1:0]                 claimi_re, claimi_re_prev;

  // ENDIANESS
  // // Register setipnum_le
  // logic [31:0]                     setipnum_le_qi, setipnum_le_di;
  // logic [31:0]                     setipnum_le_o;
  // logic                            setipnum_le_we;
  // logic                            setipnum_le_re;
  // // Register setipnum_be
  // logic [31:0]                     setipnum_be_qi, setipnum_be_di;
  // logic [31:0]                     setipnum_be_o;
  // logic                            setipnum_be_we;
  // logic                            setipnum_be_re;

  // Register genmsi
  logic [31:0]                     genmsi_qi, genmsi_di;
  logic [31:0]                     genmsi_o;
  logic                            genmsi_we;
  logic                            genmsi_re;

  // MSI NOT IMPLEMENTED
  // // Register mmsiaddrcfg
  // logic [31:0]                     mmsiaddrcfg_qi, mmsiaddrcfg_di;
  // logic [31:0]                     mmsiaddrcfg_o;
  // logic                            mmsiaddrcfg_we;
  // logic                            mmsiaddrcfg_re;

  // // Register mmsiaddrcfgh
  // logic [31:0]                     mmsiaddrcfgh_qi, mmsiaddrcfgh_di;
  // logic [31:0]                     mmsiaddrcfgh_o;
  // logic                            mmsiaddrcfgh_we;
  // logic                            mmsiaddrcfgh_re;

  // // Register smsiaddrcfg
  // logic [31:0]                     smsiaddrcfg_qi, smsiaddrcfg_di;
  // logic [31:0]                     smsiaddrcfg_o;
  // logic                            smsiaddrcfg_we;
  // logic                            smsiaddrcfg_re;

  // // Register smsiaddrcfgh
  // logic [31:0]                     smsiaddrcfgh_qi, smsiaddrcfgh_di;
  // logic [31:0]                     smsiaddrcfgh_o;
  // logic                            smsiaddrcfgh_we;
  // logic                            smsiaddrcfgh_re;

  aplic_regmap #(
    .DOMAIN_ADDR(DOMAIN_ADDR),
    .NR_SRC(NR_SRC),
    .MIN_PRIO(MIN_PRIO),
    .IPRIOLEN(IPRIOLEN),
    .NR_IDCs(NR_IDCs),
    .reg_req_t(reg_req_t),
    .reg_rsp_t(reg_rsp_t)
  ) i_aplic_regmap (
    // Register: domaincfg
    .i_domaincfg(domaincfg_qi),
    .o_domaincfg(domaincfg_o),
    .o_domaincfg_we(domaincfg_we),
    .o_domaincfg_re(domaincfg_re),
    // Register: sourcecfg
    .i_sourcecfg(sourcecfg_qi),
    .o_sourcecfg(sourcecfg_o),
    .o_sourcecfg_we(sourcecfg_we),
    .o_sourcecfg_re(sourcecfg_re),
    // Register: mmsiaddrcfg
    .i_mmsiaddrcfg(),
    .o_mmsiaddrcfg(),
    .o_mmsiaddrcfg_we(),
    .o_mmsiaddrcfg_re(),
    // Register: mmsiaddrcfgh
    .i_mmsiaddrcfgh(),
    .o_mmsiaddrcfgh(),
    .o_mmsiaddrcfgh_we(),
    .o_mmsiaddrcfgh_re(),
    // Register: smsiaddrcfg
    .i_smsiaddrcfg(),
    .o_smsiaddrcfg(),
    .o_smsiaddrcfg_we(),
    .o_smsiaddrcfg_re(),
    // Register: smsiaddrcfgh
    .i_smsiaddrcfgh(),
    .o_smsiaddrcfgh(),
    .o_smsiaddrcfgh_we(),
    .o_smsiaddrcfgh_re(),
    // Register: setip
    .i_setip(setip_qi),
    .o_setip(setip_o),
    .o_setip_we(setip_we),
    .o_setip_re(setip_re),
    // Register: setipnum
    .i_setipnum('0),
    .o_setipnum(setipnum_o),
    .o_setipnum_we(setipnum_we),
    .o_setipnum_re(),
    // Register: in_clrip
    .i_in_clrip(in_rectified_qi),
    .o_in_clrip(in_clrip_o),
    .o_in_clrip_we(in_clrip_we),
    .o_in_clrip_re(in_clrip_re),
    // Register: clripnum
    .i_clripnum('0),
    .o_clripnum(clripnum_o),
    .o_clripnum_we(clripnum_we),
    .o_clripnum_re(),
    // Register: setie
    .i_setie(setie_qi),
    .o_setie(setie_o),
    .o_setie_we(setie_we),
    .o_setie_re(setie_re),
    // Register: setienum
    .i_setienum('0),
    .o_setienum(setienum_o),
    .o_setienum_we(setienum_we),
    .o_setienum_re(),
    // Register: clrie
    .i_clrie('0),
    .o_clrie(clrie_o),
    .o_clrie_we(clrie_we),
    .o_clrie_re(),
    // Register: clrienum
    .i_clrienum('0),
    .o_clrienum(clrienum_o),
    .o_clrienum_we(clrienum_we),
    .o_clrienum_re(),
    // Register: setipnum_le
    .i_setipnum_le(),
    .o_setipnum_le(),
    .o_setipnum_le_we(),
    .o_setipnum_le_re(),
    // Register: setipnum_be
    .i_setipnum_be(),
    .o_setipnum_be(),
    .o_setipnum_be_we(),
    .o_setipnum_be_re(),
    // Register: genmsi
    .i_genmsi(genmsi_qi),
    .o_genmsi(genmsi_o),
    .o_genmsi_we(genmsi_we),
    .o_genmsi_re(genmsi_re),
    // Register: target
    .i_target(target_qi),
    .o_target(target_o),
    .o_target_we(target_we),
    .o_target_re(target_re),
    // Register: idelivery
    .i_idelivery(idelivery_qi),
    .o_idelivery(idelivery_o),
    .o_idelivery_we(idelivery_we),
    .o_idelivery_re(idelivery_re),
    // Register: iforce
    .i_iforce(iforce_qi),
    .o_iforce(iforce_o),
    .o_iforce_we(iforce_we),
    .o_iforce_re(iforce_re),
    // Register: ithreshold
    .i_ithreshold(ithreshold_qi),
    .o_ithreshold(ithreshold_o),
    .o_ithreshold_we(ithreshold_we),
    .o_ithreshold_re(ithreshold_re),
    // Register: topi
    .i_topi(topi_qi),
    .o_topi_re(topi_re),
    // Register: claimi
    .i_claimi(topi_qi),
    .o_claimi_re(claimi_re),
    .i_req(i_req),
    .o_resp(o_resp)
  ); // End of Regmap instance

// =========================================================

// ========================== ACTIVE ==============================
  // Determines which interrupts are active
  always_comb begin
    for (int i = 1; i < NR_SRC; i++) begin
        if(!((sourcecfg_qi[i][10] == DELEGATED) || 
          ((sourcecfg_qi[i][10] == NON_DELEGATED) && (sourcecfg_qi[i][2:0] == INACTIVE)))) begin
          active_i[i/32][i%32] = INTP_ACTIVE;
        end else begin
          active_i[i/32][i%32] = INTP_NOT_ACTIVE; 
        end
    end
    active_i[0][0] = 1'b0;
  end
// ================================================================

// ========================= DOMAINCFG ============================
  always_comb begin
    if (domaincfg_we == 1'b1) begin
      domaincfg_di = {8'h80, 15'b0 , domaincfg_o[8], 5'b0 , domaincfg_o[2], 1'b0, domaincfg_o[0]};
    end else begin
      domaincfg_di = {8'h80, 15'b0 , domaincfg_qi[8], 5'b0 , domaincfg_qi[2], 1'b0, domaincfg_qi[0]};;
    end
  end
// ================================================================

// ========================= SOURCECFG ============================
  // Determines the new value of sourcecfg
  always_comb begin
    for (int i = 1; i < NR_SRC; i++) begin
      case (sourcecfg_o[i][10])
        NON_DELEGATED : sourcecfg_aux_di[i] = {sourcecfg_o[i][10], 7'b0, sourcecfg_o[i][2:0]};
        DELEGATED     : sourcecfg_aux_di[i] = (APLIC == "LEAF") ? '0 : sourcecfg_o[i];
        default:; 
      endcase
      sourcecfg_di[i] = (sourcecfg_we[i]) ? sourcecfg_aux_di[i] : sourcecfg_qi[i];
    end
  end
// ================================================================

// =========================== TARGET =============================
  // Determines the new value of target
  // TODO:  a ideia é depois ter um case generate aqui. Desta forma só iremos implementar
  //        a lógica necessária para o tipo de mode do aplic.
  //        A implementação presente é para o caso 3 : full configurable
  always_comb begin
    for (int i = 1; i < NR_SRC; i++) begin
      case (domaincfg_qi[2])
        APLIC_DIRECT_MODE: target_aux_di[i] = {target_o[i][31:18], 10'b0, (target_o[i][7:0] == 0) ? 8'h1: target_o[i][7:0]};  
        APLIC_MSI_MODE: target_aux_di[i] = {target_o[i][31:12], 1'b0, target_o[i][10:0]};
        default: target_aux_di[i] = '0;
      endcase
      target_di[i] = (target_we[i]) ? target_aux_di[i] : target_qi[i];
    end
  end
// ================================================================

// =========================== ENABLE =============================
  // Set interrupt enable registers registers modifiers
  assign setienum_di    = (setienum_we) ? setienum_o : setienum_qi;
  assign clrienum_di    = (clrienum_we) ? clrienum_o : clrienum_qi;
  for (genvar i = 0; i <= NR_REG; i++) begin
    assign clrie_di[i]       = (clrie_we[i])    ? clrie_o[i]    : clrie_qi[i];
  end

  //==== Control Unit ====
  /** Prioritize writes from regmap*/
  always_comb begin
    setie_select_i = DEFAULT;
    if (|setie_we) begin
      setie_select_i = W_SETIE;
    end else if (|clrie_we) begin
      setie_select_i = CLRIE;
    end else if (setienum_we) begin
      setie_select_i = SETIENUM;
    end else if (clrienum_we) begin
      setie_select_i = CLRIENUM;
    end
  end

  /**==== setie logic ====*/
  always_comb begin
    for (int i = 0; i <= NR_REG; i++) begin
      sugg_setie_i[i]                                   = setie_qi[i];
      case (setie_select_i)  
        CLRIE       : sugg_setie_i[i]                   = ~clrie_di[i] & setie_qi[i];
        SETIENUM    : sugg_setie_i[i][setienum_di%32]   = ((setienum_di/32) == i) ? 1'b1 : sugg_setie_i[i][setienum_di%32];
        CLRIENUM    : sugg_setie_i[i][clrienum_di%32]   = ((clrienum_di/32) == i) ? 1'b0 : sugg_setie_i[i][clrienum_di%32];
        W_SETIE     : sugg_setie_i[i]                   = setie_o[i];
        default     : sugg_setie_i[i]                   = setie_qi[i];
      endcase
      /** Zero inactive sources */
      setie_di[i]                                       = sugg_setie_i[i] & active_i[i];
    end
    setie_di[0][0]                                      = 1'b0;
  end
// ================================================================

// ========================== PENDING =============================
  // Set interrupt pending registers modifiers

  always_comb begin
      setipnum_di          = setipnum_qi;
      
      if (setipnum_we) begin
        if (((i_intp_pen_src[setipnum_o] == LEVELXDM1_C) && i_rectified_src[setipnum_o/32][setipnum_o%32]) || 
              (i_intp_pen_src[setipnum_o] != LEVELXDM1_C)) begin
          setipnum_di = setipnum_o;
        end
      end
  end

  assign clripnum_di    = (clripnum_we) ? clripnum_o : clripnum_qi;
  for (genvar i = 0; i <= NR_REG; i++) begin
    assign in_clrip_di[i]       = (in_clrip_we[i])    ? in_clrip_o[i]    : in_clrip_qi[i];
  end

  //==== Control Unit ====
  /** Prioritize writes from regmap*/
  always_comb begin
    setip_select_i = DEFAULT;
    if (|setip_we) begin
      setip_select_i = W_SETIP;
    end else if (|in_clrip_we) begin
      setip_select_i = CLRIP;
    end else if (setipnum_we) begin
      setip_select_i = SETIPNUM;
    end else if (clripnum_we) begin
      setip_select_i = CLRIPNUM;
    end
  end

  //==== Setip Logic ====
  always_comb begin
    for (int i = 0; i <= NR_REG; i++) begin
      sugg_setip_i[i] = setip_qi[i];
      case (setip_select_i)       
        CLRIP       : sugg_setip_i[i]           = ~in_clrip_di[i] & setip_qi[i];
        SETIPNUM    : sugg_setip_i[i][setipnum_di%32] = ((setipnum_di/32) == i) ? 1'b1 : sugg_setip_i[i][setipnum_qi%32];
        CLRIPNUM    : sugg_setip_i[i][clripnum_di%32] = ((clripnum_di/32) == i) ? 1'b0 : sugg_setip_i[i][clripnum_qi%32];
        W_SETIP     : sugg_setip_i[i]           = setip_o[i];
        default     : sugg_setip_i[i]           = setip_qi[i];
      endcase
    end
    sugg_setip_i[0][0]                          = 1'b0;
  end
// ================================================================

// ===================== CLAIMED FORWARDED ========================
  always_comb begin
    claimed_forwarded_i = '0;
    `ifdef DIRECT_MODE
      for (int i = 0; i < NR_IDCs; i++) begin
        if ((claimi_re[i] == 1'b1) && (claimi_re_prev[i] == 1'b0)) begin
          claimed_forwarded_i[topi_qi[i][16 +: NR_SRC_W]/32][topi_qi[i][16 +: NR_SRC_W]%32] = 1'b1;
        end 
      end
    `elsif MSI_MODE
      if (i_forwarded_valid == 1'b1) begin
          claimed_forwarded_i[i_intp_forwd_id/32][i_intp_forwd_id%32] = 1'b1;
      end
    `endif
  end
// ================================================================

// ============================ IDC ===============================
  // Control Unit
  always_comb begin
    for (int i = 0; i < NR_IDCs; i++) begin
      if (iforce_we[i]) begin
        iforce_select_i[i] = W_FORCE;
      end else if (claimi_re[i] && (topi_qi[i] == 0)) begin
        iforce_select_i[i] = ZERO_FORCE;
      end else begin
        iforce_select_i[i] = DEFAULT;
      end
    end
  end
  // Logic
  always_comb begin
    for (int i = 0; i < NR_IDCs; i++) begin
      ithreshold_di[i]  = (ithreshold_we[i]) ? ithreshold_o[i] : ithreshold_qi[i];
      idelivery_di[i]   = (idelivery_we[i]) ? idelivery_o[i] : idelivery_qi[i];
      topi_di[i]        = ((topi_update_i[i]) || ((topi_sugg_i[i] == 0) && claimi_re[i])) ? topi_sugg_i[i] : topi_qi[i];
      case (iforce_select_i[i])
        ZERO_FORCE: iforce_di[i]  = '0;
        W_FORCE: iforce_di[i]     = iforce_o[i]; 
        default: iforce_di[i]     = iforce_qi[i];
      endcase
    end
  end
// ================================================================

// ========================== GENMSI ==============================
  `ifdef MSI_MODE
  always_comb begin
    genmsi_di = genmsi_qi;
    if (genmsi_we && ~genmsi_qi[12] && (genmsi_o[10:0] != '0)) begin
      genmsi_di = {genmsi_o[31:18], {5{1'b0}}, 1'b1, 1'b0, genmsi_o[10:0]};
    end
    if (i_genmsi_sent) begin
      /** clear the busy bit */
      genmsi_di = genmsi_qi & ~(32'h1<<12);
    end
  end
  `endif
// ================================================================

// ===================== ASSIGN INTERFACE =========================
  /** Assign outputs to the corresponding registers */
  assign o_domaincfgDM            = domaincfg_qi[2];
  assign o_domaincfgIE            = domaincfg_qi[8];
  for (genvar i = 1; i < NR_SRC; i++) begin
    assign o_sourcecfg[i]         = sourcecfg_qi[i];
    assign o_target_q[i]          = target_qi[i];
  end
  for (genvar i = 0; i <= NR_REG; i++) begin
    assign o_setip_q[i]           = setip_qi[i];
    assign o_setie_q[i]           = setie_qi[i];
    assign o_active[i]            = active_i[i];
    assign o_sugg_setip[i]        = sugg_setip_i[i];
    assign o_claimed_forwarded[i] = claimed_forwarded_i[i];
  end
  for (genvar i = 0; i < NR_IDCs; i++) begin
    assign o_idelivery[i]         = idelivery_qi[i];
    assign o_iforce[i]            = iforce_qi[i];
    assign o_ithreshold[i]        = ithreshold_qi[i];
  end

  /** Assign inputs to the corresponding registers */
  for (genvar i = 0; i <= NR_REG; i++) begin
    assign setip_di[i]            = i_intp_pen[i];
    assign in_rectified_di[i]     = i_rectified_src[i];
  end
  for (genvar i = 0; i < NR_IDCs; i++) begin
    assign topi_sugg_i[i]         = i_topi_sugg[i];
    assign topi_update_i[i]       = i_topi_update[i];
  end
  `ifdef MSI_MODE
    assign o_genmsi = genmsi_qi;
  `endif
// ================================================================

/**=================== Registers sequential logic ===============*/
  always_ff @( posedge i_clk or negedge ni_rst ) begin
    if (!ni_rst) begin
      `ifdef MSI_MODE
      domaincfg_qi <= 32'h80000010;
      `else
      domaincfg_qi <= 32'h80000000;
      `endif
      setipnum_qi <= '0;
      clripnum_qi <= '0;
      setienum_qi <= '0;
      clrienum_qi <= '0;
      claimi_re_prev <= '0;
      //  setipnum_le_qi <= '0;
      //  setipnum_be_qi <= '0;
      //  mmsiaddrcfg_qi <= '0;
      //  mmsiaddrcfgh_qi <= '0;
      //  smsiaddrcfg_qi <= '0;
      //  smsiaddrcfgh_qi <= '0;   
      genmsi_qi <= '0;
      for (int i = 1; i < NR_SRC; i++) begin
        sourcecfg_qi[i] <= '0;
        target_qi[i] <= '0;
      end
      for (int i = 0; i <= NR_REG; i++) begin
        setip_qi[i] <= '0;
        in_clrip_qi[i] <= '0;
        in_rectified_qi[i] <= '0;
        setie_qi[i] <= '0;
        clrie_qi[i] <= '0;
      end
      for (int i = 0; i < NR_IDCs; i++) begin
        idelivery_qi[i] <= '0;
        iforce_qi[i] <= '0;
        ithreshold_qi[i] <= '0;
        topi_qi[i] <= '0;
      end
    end else begin
        domaincfg_qi <= domaincfg_di;
        setipnum_qi <= setipnum_di;
        clripnum_qi <= clripnum_di;
        setienum_qi <= setienum_di;
        clrienum_qi <= clrienum_di;
        claimi_re_prev <= claimi_re;
        //  setipnum_le_qi <= setipnum_le_di;
        //  setipnum_be_qi <= setipnum_be_di;
        //  mmsiaddrcfg_qi <= mmsiaddrcfg_di;
        //  mmsiaddrcfgh_qi <= mmsiaddrcfgh_di;
        //  smsiaddrcfg_qi <= smsiaddrcfg_di;
        //  smsiaddrcfgh_qi <= smsiaddrcfgh_di;
        genmsi_qi <= genmsi_di;
        for (int i = 1; i < NR_SRC; i++) begin
          sourcecfg_qi[i] <= sourcecfg_di[i];
          target_qi[i] <= target_di[i];    
        end
        for (int i = 0; i <= NR_REG; i++) begin
          setip_qi[i] <= setip_di[i];
          in_clrip_qi[i] <= in_clrip_di[i];
          in_rectified_qi[i] <= in_rectified_di[i]; 
          setie_qi[i] <= setie_di[i];
          clrie_qi[i] <= clrie_di[i];
        end
        for (int i = 0; i < NR_IDCs; i++) begin
          idelivery_qi[i] <= idelivery_di[i];
          iforce_qi[i] <= iforce_di[i];
          ithreshold_qi[i] <= ithreshold_di[i];
          topi_qi[i] <= topi_di[i];
        end
    end
  end
// ================================================================

endmodule