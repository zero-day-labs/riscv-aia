/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_regctl 
import aplic_pkg::*;
#(
    parameter aplic_cfg_t                           AplicCfg            = DefaultAplicCfg,
    parameter type                                  reg_req_t           = logic,
    parameter type                                  reg_rsp_t           = logic,
    // DO NOT EDIT BY PARAMETER
    parameter int                                   NR_SRC_PER_REG      = 32,
    parameter int                                   NR_REG              = (AplicCfg.NrSources-1)/NR_SRC_PER_REG,
    parameter int                                   NR_REG_LEN          = (NR_REG == 0 | NR_REG == 1) ? 1 : $clog2(NR_REG)
) (
    input   logic                                          i_clk,
    input   logic                                          ni_rst,
    /** AXI interface From/To system bus */
    input   reg_req_t                                      i_req_cfg,
    output  reg_rsp_t                                      o_resp_cfg,
    /** Gateway */
    output  logic        o_domaincfgDM                     [AplicCfg.NrDomains-1:0],
    output  sourcecfg_t  [AplicCfg.NrSources-1:1]          o_sourcecfg,
    output  setip_t      [NR_REG:0]                        o_sugg_setip,
    output  logic        [AplicCfg.NrSources-1:1][AplicCfg.NrDomainsW-1:0] o_intp_domain,
    output  aia_bitmap_t [NR_REG:0]                        o_active,
    output  aia_bitmap_t [NR_REG:0]                        o_claimed_or_forwarded ,
    input   setip_t      [NR_REG:0]                        i_setip_gateway,
    input   logic        [AplicCfg.NrSources-1:0]          i_rectified_src,
    input   logic        [AplicCfg.NrSources-1:0][2:0]     i_intp_pen_src,
    /** Notifier */
    output  logic                                 o_domaincfgIE [AplicCfg.NrDomains-1:0], 
    output  setip_t      [NR_REG:0]               o_setip,
    output  setie_t      [NR_REG:0]               o_setie,
    output  target_t     [AplicCfg.NrSources-1:1] o_target,
    `ifdef MSI_MODE
    output  genmsi_t                              o_genmsi      [AplicCfg.NrDomains-1:0],
    input   logic                                 i_genmsi_sent [AplicCfg.NrDomains-1:0],
    input   logic                                 i_forwarded_valid,
    input   eiid_t                                i_intp_forwd_id
    `elsif DIRECT_MODE
    output  idelivery_t  [AplicCfg.NrHarts-1:0]   o_idelivery   [AplicCfg.NrDomains-1:0],
    output  iforce_t     [AplicCfg.NrHarts-1:0]   o_iforce      [AplicCfg.NrDomains-1:0],
    output  ithreshold_t [AplicCfg.NrHarts-1:0]   o_ithreshold  [AplicCfg.NrDomains-1:0],
    input   claimi_t     [AplicCfg.NrHarts-1:0]   i_topi        [AplicCfg.NrDomains-1:0],
    input   logic        [AplicCfg.NrHarts-1:0]   i_topi_update [AplicCfg.NrDomains-1:0]
    `endif
);

    function bit domain_is_leaf(input logic[AplicCfg.NrDomainsW-1:0] domain_idx);
        if (AplicCfg.DomainsCfg[domain_idx].NrChilds == 0) begin
            domain_is_leaf = 1;
        end else begin
            domain_is_leaf = 0;
        end
    endfunction

// ==================== LOCAL PARAMETERS ===================
    /** setie/setip control unit macros */
    localparam DEFAULT    = 0;
    localparam CLRIX      = 3'h1;
    localparam SETIXNUM   = 3'h2;
    localparam CLRIXNUM   = 3'h3;
    localparam SETIX      = 3'h4;
// =========================================================

// =============== Register Map instantiation ==============
    intp_domain_t   [AplicCfg.NrSources-1:1] intp_domain_d, intp_domain_q;
    aia_bitmap_t    [NR_REG:0]               active;
    // Register domaincfg
    domaincfg_t                              domaincfg_q    [AplicCfg.NrDomains-1:0]; 
    domaincfg_t                              domaincfg_d    [AplicCfg.NrDomains-1:0];
    domaincfg_t                              domaincfg_o    [AplicCfg.NrDomains-1:0];
    logic                                    domaincfg_we   [AplicCfg.NrDomains-1:0];
    // Register sourcecfg
    sourcecfg_t     [AplicCfg.NrSources-1:1] sourcecfg_q;
    sourcecfg_t     [AplicCfg.NrSources-1:1] sourcecfg_d;
    sourcecfg_t     [AplicCfg.NrSources-1:1] sourcecfg_mux3_i0 ;
    sourcecfg_t     [AplicCfg.NrSources-1:1] sourcecfg_o;
    logic           [AplicCfg.NrSources-1:1] sourcecfg_we;
    logic           [AplicCfg.NrSources-1:1] sourcecfg_final_we;
    // Register setip
    setip_t         [NR_REG:0]               setip_q, setip_d;
    setip_t         [3:0][NR_REG:0]          setip_mux0_in;
    setip_t         [NR_REG:0]               setip_mux0_o;
    setip_t         [NR_REG:0]               setip_o;
    logic           [NR_REG:0]               setip_we;
    logic           [2:0]                    setip_select_i;
    // Register setipnum
    setipnum_t                               setipnum_d;
    setipnum_t                               setipnum_o      [AplicCfg.NrDomains-1:0];
    logic                                    setipnum_we     [AplicCfg.NrDomains-1:0];
    logic                                    setipnum_final_we;
    // Register in_clrip
    clrip_t         [NR_REG:0]               in_clrip_q, in_clrip_d;
    clrip_t         [NR_REG:0]               in_clrip_o;
    logic           [NR_REG:0]               in_clrip_we;
    logic           [NR_REG:0]               clrip_final_we;
    // Register clripnum
    clripnum_t                               clripnum_d;
    clripnum_t                               clripnum_o      [AplicCfg.NrDomains-1:0];
    logic                                    clripnum_we     [AplicCfg.NrDomains-1:0];
    logic                                    clripnum_final_we;
    // Register setie
    setie_t         [NR_REG:0]               setie_q, setie_d;
    setie_t         [3:0][NR_REG:0]          setie_mux0_in;
    setie_t         [NR_REG:0]               setie_mux0_o;
    setie_t         [NR_REG:0]               setie_o;
    logic           [NR_REG:0]               setie_we;
    logic           [2:0]                    setie_select_i;
    // Register setienum
    setienum_t                               setienum_d;
    setienum_t                               setienum_o      [AplicCfg.NrDomains-1:0];
    logic                                    setienum_we     [AplicCfg.NrDomains-1:0];
    logic                                    setienum_final_we;
    // Register clrie
    clrie_t         [NR_REG:0]               clrie_d;
    clrie_t         [NR_REG:0]               clrie_mux0_i1;
    clrie_t         [NR_REG:0]               clrie_o;
    logic           [NR_REG:0]               clrie_we;
    // Register clrienum
    clrienum_t                               clrienum_d;
    clrienum_t                               clrienum_o      [AplicCfg.NrDomains-1:0];
    logic                                    clrienum_we     [AplicCfg.NrDomains-1:0];
    logic                                    clrienum_final_we;
    // Register target
    target_t        [AplicCfg.NrSources-1:1] target_q;
    target_t        [AplicCfg.NrSources-1:1] target_d;
    target_t        [AplicCfg.NrSources-1:1] target_o;
    logic           [AplicCfg.NrSources-1:1] target_we;
    `ifdef MSI_MODE
    // Register genmsi
    genmsi_t                                 genmsi_q        [AplicCfg.NrDomains-1:0]; 
    genmsi_t                                 genmsi_d        [AplicCfg.NrDomains-1:0]; 
    genmsi_t                                 genmsi_o        [AplicCfg.NrDomains-1:0];
    logic                                    genmsi_we       [AplicCfg.NrDomains-1:0];
    `elsif DIRECT_MODE
    // Register: idelivery
    idelivery_t     [AplicCfg.NrHarts-1:0]   idelivery_d     [AplicCfg.NrDomains-1:0];
    idelivery_t     [AplicCfg.NrHarts-1:0]   idelivery_q     [AplicCfg.NrDomains-1:0];
    idelivery_t     [AplicCfg.NrHarts-1:0]   idelivery_o     [AplicCfg.NrDomains-1:0];
    logic           [AplicCfg.NrHarts-1:0]   idelivery_we    [AplicCfg.NrDomains-1:0];
    // Register: iforce
    iforce_t        [AplicCfg.NrHarts-1:0]   iforce_d        [AplicCfg.NrDomains-1:0];
    iforce_t        [AplicCfg.NrHarts-1:0]   iforce_q        [AplicCfg.NrDomains-1:0];
    iforce_t        [AplicCfg.NrHarts-1:0]   iforce_o        [AplicCfg.NrDomains-1:0];
    logic           [AplicCfg.NrHarts-1:0]   iforce_we       [AplicCfg.NrDomains-1:0];
    // Register: ithreshold
    ithreshold_t    [AplicCfg.NrHarts-1:0]   ithreshold_d    [AplicCfg.NrDomains-1:0];
    ithreshold_t    [AplicCfg.NrHarts-1:0]   ithreshold_q    [AplicCfg.NrDomains-1:0];
    ithreshold_t    [AplicCfg.NrHarts-1:0]   ithreshold_o    [AplicCfg.NrDomains-1:0];
    logic           [AplicCfg.NrHarts-1:0]   ithreshold_we   [AplicCfg.NrDomains-1:0];
    // Register: topi
    claimi_t        [AplicCfg.NrHarts-1:0]   topi_d          [AplicCfg.NrDomains-1:0];
    claimi_t        [AplicCfg.NrHarts-1:0]   topi_q          [AplicCfg.NrDomains-1:0];
    // Register: claimi
    logic           [AplicCfg.NrHarts-1:0]   claimi_re       [AplicCfg.NrDomains-1:0];
    logic           [AplicCfg.NrHarts-1:0]   claimi_re_q     [AplicCfg.NrDomains-1:0];
  `endif

    logic [AplicCfg.NrDomainsW-1:0]   target_domain;
    logic [NR_REG_LEN-1:0]            target_source_reg;

    aplic_regmap #(
    .AplicCfg               ( AplicCfg          ),
    .reg_req_t              ( reg_req_t         ),
    .reg_rsp_t              ( reg_rsp_t         )
    ) i_aplic_regmap (
    .intp_domain_i          ( intp_domain_q     ),
    .target_domain_o        ( target_domain     ),
    .target_source_reg_o    ( target_source_reg ),
    // Register: domaincfg
    .i_domaincfg            ( domaincfg_q       ),
    .o_domaincfg            ( domaincfg_o       ),
    .o_domaincfg_we         ( domaincfg_we      ),
    // Register: sourcecfg
    .i_sourcecfg            ( sourcecfg_q       ),
    .o_sourcecfg            ( sourcecfg_o       ),
    .o_sourcecfg_we         ( sourcecfg_we      ),
    // Register: mmsiaddrcfg
    .i_mmsiaddrcfg          (),
    .o_mmsiaddrcfg          (),
    .o_mmsiaddrcfg_we       (),
    // Register: mmsiaddrcfgh
    .i_mmsiaddrcfgh         (),
    .o_mmsiaddrcfgh         (),
    .o_mmsiaddrcfgh_we      (),
    // Register: smsiaddrcfg
    .i_smsiaddrcfg          (),
    .o_smsiaddrcfg          (),
    .o_smsiaddrcfg_we       (),
    // Register: smsiaddrcfgh
    .i_smsiaddrcfgh         (),
    .o_smsiaddrcfgh         (),
    .o_smsiaddrcfgh_we      (),
    // Register: setip
    .i_setip                ( setip_q           ),
    .o_setip                ( setip_o           ),
    .o_setip_we             ( setip_we          ),
    // Register: setipnum
    .o_setipnum             ( setipnum_o        ),
    .o_setipnum_we          ( setipnum_we       ),
    // Register: in_clrip
    .i_in_clrip             ( in_clrip_q        ),
    .o_in_clrip             ( in_clrip_o        ),
    .o_in_clrip_we          ( in_clrip_we       ),
    // Register: clripnum
    .o_clripnum             ( clripnum_o        ),
    .o_clripnum_we          ( clripnum_we       ),
    // Register: setie
    .i_setie                ( setie_q           ),
    .o_setie                ( setie_o           ),
    .o_setie_we             ( setie_we          ),
    // Register: setienum
    .o_setienum             ( setienum_o        ),
    .o_setienum_we          ( setienum_we       ),
    // Register: clrie
    .o_clrie                ( clrie_o           ),
    .o_clrie_we             ( clrie_we          ),
    // Register: clrienum
    .o_clrienum             ( clrienum_o        ),
    .o_clrienum_we          ( clrienum_we       ),
    // Register: setipnum_le
    .i_setipnum_le          (),
    .o_setipnum_le          (),
    .o_setipnum_le_we       (),
    // Register: setipnum_be
    .i_setipnum_be          (),
    .o_setipnum_be          (),
    .o_setipnum_be_we       (),
    // Register: target
    .i_target               ( target_q          ),
    .o_target               ( target_o          ),
    .o_target_we            ( target_we         ),
    `ifdef MSI_MODE
    // Register: genmsi
    .i_genmsi               ( genmsi_q          ),
    .o_genmsi               ( genmsi_o          ),
    .o_genmsi_we            ( genmsi_we         ),
    `elsif DIRECT_MODE
    .i_idelivery            ( idelivery_q       ),               
    .o_idelivery            ( idelivery_o       ),               
    .o_idelivery_we         ( idelivery_we      ),               
    .i_iforce               ( iforce_q          ),           
    .o_iforce               ( iforce_o          ),           
    .o_iforce_we            ( iforce_we         ),               
    .i_ithreshold           ( ithreshold_q      ),               
    .o_ithreshold           ( ithreshold_o      ),               
    .o_ithreshold_we        ( ithreshold_we     ),                   
    .i_topi                 ( topi_q            ),       
    .i_claimi               ( topi_q            ),           
    .o_claimi_re            ( claimi_re         ),               
    `endif
    // AXI port
    .i_req                  ( i_req_cfg         ),
    .o_resp                 ( o_resp_cfg        )
    ); // End of Regmap instance

// ========================== ACTIVE ==============================
    function /* automatic */ bit source_is_active(input logic [AplicCfg.NrSourcesW-1:0] source_idx);
        if (!((sourcecfg_q[source_idx].d == SOURCE_DELEGATED) || 
            ((sourcecfg_q[source_idx].d == SOURCE_NOT_DELEGATED) && 
            (sourcecfg_q[source_idx].ddf.nd.sm == APLIC_SM_INACTIVE)))) begin
                source_is_active = 1;
            end else begin
                source_is_active = 0;
            end
    endfunction

    always_comb begin
        active = '0;
        for (int j = 1; j < AplicCfg.NrSources; j++) begin
            active[j/32][j%32] = source_is_active(j[AplicCfg.NrSourcesW-1:0]);
        end
    end

    assign o_active = active;
// ================================================================

// ========================= DOMAINCFG ============================
    for (genvar i = 0; i < AplicCfg.NrDomains; i++) begin
        assign domaincfg_d[i] = (domaincfg_we[i]) ? domaincfg_o[i] : domaincfg_q[i];
        assign o_domaincfgIE[i] = domaincfg_d[i].ie; 
        assign o_domaincfgDM[i] = domaincfg_d[i].dm; 
    end
// ================================================================

// ========================= SOURCECFG ============================
    logic zero_reg;
    always_comb begin
        intp_domain_d   = intp_domain_q;
        zero_reg        = '0;
        for (int j = 1; j < AplicCfg.NrSources; j++) begin
            if (sourcecfg_we[j] && sourcecfg_o[j].d) begin
                if (!domain_is_leaf(intp_domain_q[j])) begin
                    intp_domain_d[j] = intp_domain_t'(AplicCfg.DomainsCfg[intp_domain_q[j]].ChildsIdx[sourcecfg_o[j].ddf.ci]);
                end else begin
                    zero_reg = 1'b1;
                end
            end else if (sourcecfg_we[j] && !sourcecfg_o[j].d) begin 
                if (domain_is_parent(int'(target_domain), AplicCfg.DomainsCfg[intp_domain_q[j]].ParentID)) begin
                    intp_domain_d[j] = intp_domain_t'(AplicCfg.DomainsCfg[intp_domain_q[j]].ParentID);
                end
            end
        end
    end

    assign o_intp_domain = intp_domain_q;

    always_comb begin :sourcecfg_logic
        /** reset value */
        for (int i = 1; i < AplicCfg.NrSources; i++) begin
            sourcecfg_mux3_i0[i].d = '0;
            sourcecfg_mux3_i0[i].ddf.ci = '0;
        end
        sourcecfg_d         = sourcecfg_q;
        sourcecfg_final_we  = '0;

        for (int j = 1; j < AplicCfg.NrSources; j++) begin
            if (intp_domain_d[j] == target_domain) begin
                sourcecfg_mux3_i0[j]    = (zero_reg) ? '0 : sourcecfg_o[j];
                sourcecfg_final_we[j]   = sourcecfg_we[j];
            end
            sourcecfg_d[j] = (sourcecfg_final_we[j]) ? sourcecfg_mux3_i0[j] : sourcecfg_q[j];
        end
        o_sourcecfg = sourcecfg_q;
    end
    
// ================================================================

// ========================== PENDING =============================
    always_comb begin : setipnum_logic
        setipnum_d          = '0;
        setipnum_final_we   = '0;

        setipnum_d          = setipnum_o[target_domain];
        setipnum_final_we   = setipnum_we[target_domain];
    end
    always_comb begin : clripnum_logic
        clripnum_d          = '0;
        clripnum_final_we   = '0;

        clripnum_d          = clripnum_o[target_domain];
        clripnum_final_we   = clripnum_we[target_domain];
    end
    always_comb begin : inclrip_logic
        in_clrip_d =  '0;
        in_clrip_d[target_source_reg] = in_clrip_o[target_source_reg];
    end
    always_comb begin : setip_control_unit
        setip_select_i = DEFAULT;
        if (|setip_we) begin
            setip_select_i = SETIX;
        end else if (|in_clrip_we) begin
            setip_select_i = CLRIX;
        end else if (setipnum_final_we) begin
            setip_select_i = SETIXNUM;
        end else if (clripnum_final_we) begin
            setip_select_i = CLRIXNUM;
        end
    end
    always_comb begin : setip_logic
        setip_mux0_in[0]    = ~in_clrip_d & setip_q;

        setip_mux0_in[1]    = setip_q;
        setip_mux0_in[1][setipnum_d/32][setipnum_d%32] = 1'b1;

        setip_mux0_in[2]    = setip_q;
        setip_mux0_in[2][clripnum_d/32][clripnum_d%32] = 1'b0;
        
        setip_mux0_in[3] = setip_q;
        setip_mux0_in[3][target_source_reg] = setip_q[target_source_reg] | setip_o[target_source_reg];

        case (setip_select_i)       
            CLRIX       : setip_mux0_o           = setip_mux0_in[0];
            SETIXNUM    : setip_mux0_o           = setip_mux0_in[1];
            CLRIXNUM    : setip_mux0_o           = setip_mux0_in[2];
            SETIX       : setip_mux0_o           = setip_mux0_in[3];
            default     : setip_mux0_o           = setip_q;
        endcase
        setip_mux0_o[0][0]                          = 1'b0;
    end

    assign setip_d      = i_setip_gateway;
    assign o_sugg_setip = setip_mux0_o;
    assign o_setip      = setip_q;
// ================================================================

// =========================== ENABLE =============================
    always_comb begin : setienum_logic        
        setienum_d          = '0;
        setienum_final_we   = '0;

        setienum_d          = setienum_o[target_domain];
        setienum_final_we   = setienum_we[target_domain];
    end
    always_comb begin : clrienum_logic
        clrienum_d          = '0;
        clrienum_final_we   = '0;

        clrienum_d          = clrienum_o[target_domain];
        clrienum_final_we   = clrienum_we[target_domain];
    end
    always_comb begin : clrie_logic
        clrie_d =  '0;
        clrie_d[target_source_reg] = clrie_o[target_source_reg];
    end
    always_comb begin : setie_control_unit
        setie_select_i = DEFAULT;
        if (|setie_we) begin
            setie_select_i = SETIX;
        end else if (|clrie_we) begin
            setie_select_i = CLRIX;
        end else if (setienum_final_we) begin
            setie_select_i = SETIXNUM;
        end else if (clrienum_final_we) begin
            setie_select_i = CLRIXNUM;
        end
    end
    always_comb begin : setie_logic
        setie_mux0_in[0]    = ~clrie_d & setie_q;

        setie_mux0_in[1]    = setie_q;
        setie_mux0_in[1][setienum_d/32][setienum_d%32] = 1'b1;

        setie_mux0_in[2]    = setie_q;
        setie_mux0_in[2][clrienum_d/32][clrienum_d%32] = 1'b0;
        
        setie_mux0_in[3] = setie_q;
        setie_mux0_in[3][target_source_reg] = setie_q[target_source_reg] | setie_o[target_source_reg];

        case (setie_select_i)       
            CLRIX       : setie_mux0_o           = setie_mux0_in[0];
            SETIXNUM    : setie_mux0_o           = setie_mux0_in[1];
            CLRIXNUM    : setie_mux0_o           = setie_mux0_in[2];
            SETIX       : setie_mux0_o           = setie_mux0_in[3];
            default     : setie_mux0_o           = setie_q;
        endcase
        setie_mux0_o[0][0]                          = 1'b0;
    end

    assign setie_d = setie_mux0_o & active;
    assign o_setie = setie_q;
// ================================================================

// =========================== TARGET =============================
  // Determines the new value of target
  always_comb begin : target_logic
    target_d = target_q;
    for (int j = 1; j < AplicCfg.NrSources; j++) begin
        if((intp_domain_q[j] == target_domain) && active[j/32][j%32] && target_we[j]) begin
            target_d[j].hi = target_o[j].hi;
            // We dont support both delivery modes simultaneously in hardware
            if (AplicCfg.DeliveryMode == DOMAIN_IN_DIRECT_MODE) begin
                target_d[j].dmdf.df.iprio = (target_o[j].dmdf.df.iprio == 0) ? TARGERT_DEF_IPRIO : target_o[j].dmdf.df.iprio;
            end else if (AplicCfg.DeliveryMode == DOMAIN_IN_MSI_MODE) begin
                target_d[j].dmdf.mf   = target_o[j].dmdf.mf;
            end
        end
    end
  end

  assign o_target = target_q;
// ================================================================

// ===================== CLAIMED FORWARDED ========================
    always_comb begin
        o_claimed_or_forwarded = '0;
        `ifdef DIRECT_MODE
        for (int i = 0; i < AplicCfg.NrDomains; i++) begin
            for (int j = 0; j < AplicCfg.NrHarts; j++) begin
                if ((claimi_re[i][j] == 1'b1) && (claimi_re_q[i][j] == 1'b0)) begin
                    o_claimed_or_forwarded[topi_q[i][j].iid/32][topi_q[i][j].iid%32] = 1'b1;
                end 
            end 
        end
        `elsif MSI_MODE
        if (i_forwarded_valid) begin
            o_claimed_or_forwarded[i_intp_forwd_id/32][i_intp_forwd_id%32] = 1'b1;
        end
        `endif
    end
// ================================================================

// ============================ IDC ===============================
    `ifdef DIRECT_MODE
    /** iforce control unit macros */
    localparam ZERO_FORCE               = 2'h1;
    localparam W_FORCE                  = 2'h2;
    
    logic [AplicCfg.NrHarts-1:0][1:0] iforce_ctl [AplicCfg.NrDomains-1:0];

    always_comb begin : iforce_control_unit
        for (int i = 0; i < AplicCfg.NrDomains; i++) begin
            for (int j = 0; j < AplicCfg.NrHarts; j++) begin
                if (iforce_we[i][j]) begin
                    iforce_ctl[i][j] = W_FORCE;
                end else if (claimi_re[i][j] && (topi_q[i][j] == 0)) begin
                    iforce_ctl[i][j] = ZERO_FORCE;
                end else begin
                    iforce_ctl[i][j] = DEFAULT;
                end
            end
        end
    end

    always_comb begin : idc_logic
        for (int i = 0; i < AplicCfg.NrDomains; i++) begin
            for (int j = 0; j < AplicCfg.NrHarts; j++) begin
                idelivery_d[i][j]       = (idelivery_we[i][j]) ? idelivery_o[i][j] : idelivery_q[i][j];
                ithreshold_d[i][j]      = (ithreshold_we[i][j]) ? ithreshold_o[i][j] : ithreshold_q[i][j];
                topi_d[i][j]            = ((i_topi_update[i][j]) || 
                                          ((i_topi[i][j] == 0) && (claimi_re[i][j]||claimi_re_q[i][j]))) ? i_topi[i][j] : topi_q[i][j];
                case (iforce_ctl[i][j])
                    ZERO_FORCE: iforce_d[i][j]  = '0;
                    W_FORCE:    iforce_d[i][j]  = iforce_o[i][j]; 
                    default:    iforce_d[i][j]  = iforce_q[i][j];
                endcase
            end
        end
    end

    /** Signal to notifier module*/
    assign o_idelivery    = idelivery_q;
    assign o_ithreshold   = ithreshold_q;
    assign o_iforce       = iforce_q;
    `endif
// ================================================================

// ========================== GENMSI ==============================
    `ifdef MSI_MODE
    always_comb begin
    genmsi_d = genmsi_q;

    for (int i = 0; i < AplicCfg.NrDomains; i++) begin
        if (genmsi_we[i] && !genmsi_q[i].busy && (genmsi_o[i].eiid != '0)) begin
            genmsi_d[i] = genmsi_o[i];
        end
        if (i_genmsi_sent[i]) begin
            genmsi_d[i].busy = 1'b0;
        end
    end
    end

    assign o_genmsi = genmsi_q;
    `endif
// ================================================================

/**=================== Registers sequential logic ===============*/
  always_ff @( posedge i_clk or negedge ni_rst ) begin
    if (!ni_rst) begin
        sourcecfg_q         <= '0;
        setip_q             <= '0;
        in_clrip_q          <= '0;
        setie_q             <= '0;
        target_q            <= '0;
        intp_domain_q       <= '0;
        for (int i = 0; i < AplicCfg.NrDomains; i++) begin
            domaincfg_q[i]         <= '0;
            `ifdef MSI_MODE
            genmsi_q[i]            <= '0;
            `elsif DIRECT_MODE
            idelivery_q[i]         <= '0;
            ithreshold_q[i]        <= '0;
            topi_q[i]              <= '0;
            iforce_q[i]            <= '0;
            claimi_re_q[i]         <= '0;
            `endif
        end
    end else begin
        domaincfg_q         <= domaincfg_d;
        intp_domain_q       <= intp_domain_d;
        sourcecfg_q         <= sourcecfg_d;
        in_clrip_q          <= in_clrip_d;
        setip_q             <= setip_d;
        setie_q             <= setie_d;
        target_q            <= target_d;
        `ifdef MSI_MODE
        genmsi_q            <= genmsi_d;
        `elsif DIRECT_MODE
        idelivery_q         <= idelivery_d;         
        ithreshold_q        <= ithreshold_d;             
        topi_q              <= topi_d;     
        iforce_q            <= iforce_d;         
        claimi_re_q         <= claimi_re;         
        `endif
    end
  end
// ================================================================

endmodule