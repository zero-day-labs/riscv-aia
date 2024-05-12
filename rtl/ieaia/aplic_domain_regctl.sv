/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_regctl #(
    parameter int                                                   NR_DOMAINS          = 2,
    parameter int                                                   DOMAIN_M_ADDR       = 32'hc000000,
    parameter int                                                   DOMAIN_S_ADDR       = 32'hd000000,
    parameter int                                                   NR_SRC              = 32,
    parameter int                                                   MIN_PRIO            = 6,
    parameter type                                                  reg_req_t           = logic,
    parameter type                                                  reg_rsp_t           = logic,
    // DO NOT EdT BY PARAMETER
    parameter int                                                   IPRIOLEN            = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
    parameter int                                                   NR_BITS_SRC         = 32,
    parameter int                                                   NR_SRC_W            = 10,
    parameter int                                                   NR_REG              = (NR_SRC-1)/NR_BITS_SRC  
) (
    input   logic                                                   i_clk               ,
    input   logic                                                   ni_rst              ,
    /** Register config: AXI interface From/To system bus */
    input   reg_req_t                                               i_req_cfg           ,
    output  reg_rsp_t                                               o_resp_cfg          ,
    /** Gateway */
    output  logic [NR_SRC-1:1][10:0]                                o_sourcecfg         ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_sugg_setip        ,
    output  logic [NR_DOMAINS-1:0]                                  o_domaincfgDM       ,
    output  logic [NR_SRC-1:1]                                      o_intp_domain       ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_active            ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_claimed_or_forwarded ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_intp_pen          ,
    input   logic [NR_SRC-1:0]                                      i_rectified_src     ,
    input   logic [NR_SRC-1:0][2:0]                                 i_intp_pen_src      ,
    /** Notifier */
    output  logic [NR_DOMAINS-1:0]                                  o_domaincfgIE       , 
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_setip             ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_setie             ,
    output  logic [NR_SRC-1:1][31:0]                                o_target            ,
    output  logic [NR_DOMAINS-1:0][31:0]                            o_genmsi            ,
    input   logic [NR_DOMAINS-1:0]                                  i_genmsi_sent       ,
    input   logic                                                   i_forwarded_valid   ,
    input   logic [10:0]                                            i_intp_forwd_id     
);

// ==================== LOCAL PARAMETERS ===================
  /** aplic function mode */
  localparam APLIC_DIRECT_MODE        = 1'b0;
  localparam APLIC_MSI_MODE           = 1'b1;

  localparam NON_DELEGATED            = 1'b0;
  localparam DELEGATED                = 1'b1;
  localparam INACTIVE                 = 3'b000;
  localparam INTP_ACTIVE              = 1'b1;
  localparam INTP_NOT_ACTIVE          = 1'b0;

  localparam LEVELXDM1_C              = 3'h4;

  /** setie/setip control unit macros */
  localparam DEFAULT                  = 0;
  localparam CLRIX                    = 3'h1;
  localparam SETIXNUM                 = 3'h2;
  localparam CLRIXNUM                 = 3'h3;
  localparam SETIX                    = 3'h4;

  /** iforce control unit macros */
  localparam ZERO_FORCE               = 2'h1;
  localparam W_FORCE                  = 2'h2;
// =========================================================

  logic [NR_REG:0][NR_BITS_SRC-1:0]                 active;
  logic [NR_SRC-1:1]                                intp_domain_d, intp_domain_q;
  logic [NR_SRC-1:1]                                change_of_domain_detected;
  logic [2:0]                                       setie_select_i, setip_select_i;

// =============== Register Map instantiation ==============
  // Register domaincfg
  logic [NR_DOMAINS-1:0][31:0]                      domaincfg_q, domaincfg_d;
  logic [NR_DOMAINS-1:0][31:0]                      domaincfg_o;
  logic [NR_DOMAINS-1:0]                            domaincfg_we;
  // Register sourcecfg
  logic [NR_SRC-1:1][10:0]                          sourcecfg_q, sourcecfg_d;
  logic [NR_SRC-1:1][10:0]                          sourcecfg_mux3_i0;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][10:0]          sourcecfg_full;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][10:0]          sourcecfg_o;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1]                sourcecfg_we;
  logic [NR_SRC-1:1]                                sourcecfg_final_we;
  // Register setip
  logic [NR_REG:0][31:0]                            setip_q, setip_d;
  logic [3:0][NR_REG:0][31:0]                       setip_mux0_in;
  logic [NR_REG:0][31:0]                            setip_mux0_o;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setip_full;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setip_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  setip_we;
  logic [NR_REG:0]                                  setip_final_we;
  // Register setipnum
  logic [31:0]                                      setipnum_q, setipnum_d;
  logic [31:0]                                      setip_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      setipnum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      setipnum_o;
  logic [NR_DOMAINS-1:0]                            setipnum_we;
  logic                                             setipnum_final_we;
  // Register in_clrip
  logic [NR_REG:0][31:0]                            in_clrip_q, in_clrip_d;
  logic [NR_REG:0][31:0]                            clrip_mux0_i1;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            in_clrip_full;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            in_clrip_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  in_clrip_we;
  logic [NR_REG:0]                                  clrip_final_we;
  // Register clripnum
  logic [31:0]                                      clripnum_q, clripnum_d;
  logic [31:0]                                      clrip_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      clripnum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      clripnum_o;
  logic [NR_DOMAINS-1:0]                            clripnum_we;
  logic                                             clripnum_final_we;
  // Register setie
  logic [NR_REG:0][31:0]                            setie_q, setie_d;
  logic [3:0][NR_REG:0][31:0]                       setie_mux0_in;
  logic [NR_REG:0][31:0]                            setie_mux0_o;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setie_full;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setie_or_in;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setie_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  setie_we;
  logic [NR_REG:0]                                  setie_final_we;
  // Register setienum
  logic [31:0]                                      setienum_q, setienum_d;
  logic [31:0]                                      setie_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      setienum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      setienum_o;
  logic [NR_DOMAINS-1:0]                            setienum_we;
  logic                                             setienum_final_we;
  // Register clrie
  logic [NR_REG:0][31:0]                            clrie_q, clrie_d;
  logic [NR_REG:0][31:0]                            clrie_mux0_i1;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            clrie_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  clrie_we;
  logic [NR_REG:0]                                  clrie_final_we;
  // Register clrienum
  logic [31:0]                                      clrienum_q, clrienum_d;
  logic [31:0]                                      clrie_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      clrienum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      clrienum_o;
  logic [NR_DOMAINS-1:0]                            clrienum_we;
  logic                                             clrienum_final_we;
  // Register target
  logic [NR_SRC-1:1][31:0]                          target_q, target_d;
  /* verilator lint_off WIDTHCONCAT */
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][31:0]          target_full;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][31:0]          target_o;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1]                target_we;
  // Register genmsi
  logic [NR_DOMAINS-1:0][31:0]                      genmsi_q, genmsi_d;
  logic [NR_DOMAINS-1:0][31:0]                      genmsi_o;
  logic [NR_DOMAINS-1:0]                            genmsi_we;

  aplic_regmap_minimal #(
    .DOMAIN_M_ADDR          ( DOMAIN_M_ADDR     ),
    .DOMAIN_S_ADDR          ( DOMAIN_S_ADDR     ),
    .NR_SRC                 ( NR_SRC            ),
    .MIN_PRIO               ( MIN_PRIO          ),
    .IPRIOLEN               ( IPRIOLEN          ),
    .reg_req_t              ( reg_req_t         ),
    .reg_rsp_t              ( reg_rsp_t         )
  ) i_aplic_regmap_minimal (
    // Register: domaincfg
    .i_domaincfg            ( domaincfg_q       ),
    .o_domaincfg            ( domaincfg_o       ),
    .o_domaincfg_we         ( domaincfg_we      ),
    .o_domaincfg_re         (),
    // Register: sourcecfg
    .i_sourcecfg            ( sourcecfg_full    ),
    .o_sourcecfg            ( sourcecfg_o       ),
    .o_sourcecfg_we         ( sourcecfg_we      ),
    .o_sourcecfg_re         (),
    // Register: mmsiaddrcfg
    .i_mmsiaddrcfg          (),
    .o_mmsiaddrcfg          (),
    .o_mmsiaddrcfg_we       (),
    .o_mmsiaddrcfg_re       (),
    // Register: mmsiaddrcfgh
    .i_mmsiaddrcfgh         (),
    .o_mmsiaddrcfgh         (),
    .o_mmsiaddrcfgh_we      (),
    .o_mmsiaddrcfgh_re      (),
    // Register: smsiaddrcfg
    .i_smsiaddrcfg          (),
    .o_smsiaddrcfg          (),
    .o_smsiaddrcfg_we       (),
    .o_smsiaddrcfg_re       (),
    // Register: smsiaddrcfgh
    .i_smsiaddrcfgh         (),
    .o_smsiaddrcfgh         (),
    .o_smsiaddrcfgh_we      (),
    .o_smsiaddrcfgh_re      (),
    // Register: setip
    .i_setip                ( setip_full        ),
    .o_setip                ( setip_o           ),
    .o_setip_we             ( setip_we          ),
    .o_setip_re             (),
    // Register: setipnum
    .i_setipnum             ( '0                ),
    .o_setipnum             ( setipnum_o        ),
    .o_setipnum_we          ( setipnum_we       ),
    .o_setipnum_re          (),
    // Register: in_clrip
    .i_in_clrip             ( in_clrip_full     ),
    .o_in_clrip             ( in_clrip_o        ),
    .o_in_clrip_we          ( in_clrip_we       ),
    .o_in_clrip_re          (),
    // Register: clripnum
    .i_clripnum             ( '0                ),
    .o_clripnum             ( clripnum_o        ),
    .o_clripnum_we          ( clripnum_we       ),
    .o_clripnum_re          (),
    // Register: setie
    .i_setie                ( setie_full        ),
    .o_setie                ( setie_o           ),
    .o_setie_we             ( setie_we          ),
    .o_setie_re             (),
    // Register: setienum
    .i_setienum             ( '0                ),
    .o_setienum             ( setienum_o        ),
    .o_setienum_we          ( setienum_we       ),
    .o_setienum_re          (),
    // Register: clrie
    .i_clrie                ( '0                ),
    .o_clrie                ( clrie_o           ),
    .o_clrie_we             ( clrie_we          ),
    .o_clrie_re             (),
    // Register: clrienum
    .i_clrienum             ( '0                ),
    .o_clrienum             ( clrienum_o        ),
    .o_clrienum_we          ( clrienum_we       ),
    .o_clrienum_re          (),
    // Register: setipnum_le
    .i_setipnum_le          (),
    .o_setipnum_le          (),
    .o_setipnum_le_we       (),
    .o_setipnum_le_re       (),
    // Register: setipnum_be
    .i_setipnum_be          (),
    .o_setipnum_be          (),
    .o_setipnum_be_we       (),
    .o_setipnum_be_re       (),
    // Register: target
    .i_target               ( target_full       ),
    .o_target               ( target_o          ),
    .o_target_we            ( target_we         ),
    .o_target_re            (),
    // Register: genmsi
    .i_genmsi               ( genmsi_q          ),
    .o_genmsi               ( genmsi_o          ),
    .o_genmsi_we            ( genmsi_we         ),
    .o_genmsi_re            (),
    // AXI port
    .i_req                  ( i_req_cfg         ),
    .o_resp                 ( o_resp_cfg        )
  ); // End of Regmap instance

// ========================== ACTIVE ==============================
    always_comb begin
        active = '0;
        for (int j = 1; j < NR_SRC; j++) begin
            if(!((sourcecfg_q[j][10] == DELEGATED) || 
                ((sourcecfg_q[j][10] == NON_DELEGATED) && (sourcecfg_q[j][2:0] == INACTIVE)))) begin
                active[j/32][j%32] = INTP_ACTIVE;
            end
        end
    end

    assign o_active = active;
// ================================================================

// ========================= DOMAINCFG ============================
    for (genvar i = 0; i < NR_DOMAINS; i++) begin
        assign domaincfg_d[i] = (domaincfg_we[i]) ? {8'h80, 15'b0 , domaincfg_o[i][8], 5'b0 , domaincfg_o[i][2], 1'b0, domaincfg_o[i][0]} : domaincfg_q[i];
    end

    for (genvar i = 0; i < NR_DOMAINS; i++) begin
        assign o_domaincfgIE[i] = domaincfg_d[i][8]; 
        assign o_domaincfgDM[i] = domaincfg_d[i][2]; 
    end
// ================================================================

// ========================= SOURCECFG ============================
    logic zero_reg;
    always_comb begin : intp_domain_logic
        intp_domain_d   = intp_domain_q;
        zero_reg        = '0;
        for (int i = 0; i < NR_SRC; i++) begin
            if ((sourcecfg_o[0][i][10] != intp_domain_q[i]) && sourcecfg_we[0][i]) begin
                intp_domain_d[i] = ~intp_domain_q[i];
            end
            if ((sourcecfg_o[1][i][10] == 1'b1) && sourcecfg_we[1][i]) begin
                zero_reg = 1'b1;
            end
        end
    end

    assign o_intp_domain = intp_domain_q;

    always_comb begin :sourcecfg_logic
        /** reset value */
        sourcecfg_d         = sourcecfg_q;
        sourcecfg_mux3_i0   = '0;
        sourcecfg_final_we  = '0;

        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 1; j < NR_SRC; j++) begin
                if (intp_domain_d[j] == i[0]) begin
                    sourcecfg_mux3_i0[j]    = (zero_reg) ? '0 : sourcecfg_o[i][j];
                    sourcecfg_final_we[j]   = sourcecfg_we[i][j];
                end
                sourcecfg_d[j] = (sourcecfg_final_we[j]) ? sourcecfg_mux3_i0[j] : sourcecfg_q[j];
            end
        end
        o_sourcecfg = sourcecfg_q;
    end
    
    always_comb begin : sourcecfg_rebuild
        sourcecfg_full = '0;
        for (int j = 0; j < NR_SRC; j++) begin
            if (intp_domain_q[j] == 1'b1) begin
                sourcecfg_full[0][j] = (1 << 10);    
            end
            sourcecfg_full[intp_domain_q[j]][j] = sourcecfg_q[j];
        end
    end
// ================================================================

// ========================== PENDING =============================
    always_comb begin : setipnum_logic
        setipnum_d          = setipnum_q;
        setipnum_final_we   = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            /** If the intp written in setipnum_o is delegated to this domain AND
                an update was requested, update setipnum_d */
            if ((intp_domain_q[setipnum_o[i]] == i[0]) && setipnum_we[i]) begin
                if (i_intp_pen_src[setipnum_o[i]] == LEVELXDM1_C) begin
                    if (i_rectified_src[i]) begin
                        setipnum_d          = setipnum_o[i];
                        setipnum_final_we   = setipnum_we[i];
                    end
                end else begin
                    setipnum_d          = setipnum_o[i];
                    setipnum_final_we   = setipnum_we[i];
                end
            end
        end
    end
    always_comb begin : clripnum_logic
        clripnum_d          = clripnum_q;
        clripnum_final_we   = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            if ((intp_domain_q[clripnum_o[i]] == i[0]) && clripnum_we[i]) begin
                clripnum_d          = clripnum_o[i];
                clripnum_final_we   = clripnum_we[i];
            end
        end
    end
    always_comb begin : inclrip_logic
        for (int i = 0; i < NR_SRC; i++) begin
            clrip_mux0_i1[i/32][i%32] = in_clrip_o[intp_domain_q[i]][i/32][i%32];
        end
        clrip_final_we = in_clrip_we[0] | in_clrip_we[1];

        for (int i = 0; i <= NR_REG; i++) begin
            in_clrip_d[i] = (clrip_final_we[i]) ? clrip_mux0_i1[i] : in_clrip_q[i];         
        end
    end
    always_comb begin : rebuild_inclrip
        in_clrip_full = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 0; j < NR_SRC; j++) begin
                in_clrip_full[intp_domain_q[j]][j/32][j%32] = i_rectified_src[j];
            end
        end
    end
    always_comb begin : setip_control_unit
        setip_select_i = DEFAULT;
        if (|setip_final_we) begin
            setip_select_i = SETIX;
        end else if (|clrip_final_we) begin
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
        
        for (int i = 1; i < NR_SRC; i++) begin
            setip_mux0_in[3][i/32][i%32]    = setip_o[intp_domain_q[i]][i/32][i%32]; 
        end
        setip_final_we = setip_we[0] | setip_we[1];

        case (setip_select_i)       
            CLRIX       : setip_mux0_o           = setip_mux0_in[0];
            SETIXNUM    : setip_mux0_o           = setip_mux0_in[1];
            CLRIXNUM    : setip_mux0_o           = setip_mux0_in[2];
            SETIX       : setip_mux0_o           = setip_mux0_in[3];
            default     : setip_mux0_o           = setip_q;
        endcase
        setip_mux0_o[0][0]                          = 1'b0;
    end
    always_comb begin : rebuild_setip
        setip_full = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 0; j < NR_SRC; j++) begin
                setip_full[intp_domain_q[j]][j/32][j%32] = setip_q[j/32][j%32];
            end
        end
    end

    assign setip_d      = i_intp_pen;
    assign o_sugg_setip = setip_mux0_o;
    assign o_setip      = setip_q;
// ================================================================

// =========================== ENABLE =============================
    always_comb begin : setienum_logic
        setienum_d          = setienum_q;
        setienum_final_we   = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            /** If the intp written in setienum_o is delegated to this domain AND
                an update was requested, update setipnum_d */
            if ((intp_domain_q[setienum_o[i]] == i[0]) && setienum_we[i]) begin
                setienum_d          = setienum_o[i];
                setienum_final_we   = setienum_we[i];
            end
        end
    end
    always_comb begin : clrienum_logic
        clrienum_d          = clrienum_q;
        clrienum_final_we   = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            if ((intp_domain_q[clrienum_o[i]] == i[0]) && clrienum_we[i]) begin
                clrienum_d          = clrienum_o[i];
                clrienum_final_we   = clrienum_we[i];
            end
        end
    end
    always_comb begin : clrie_logic
        for (int i = 0; i < NR_SRC; i++) begin
            clrie_mux0_i1[i/32][i%32] = clrie_o[intp_domain_q[i]][i/32][i%32];
        end
        clrie_final_we = clrie_we[0] | clrie_we[1];

        for (int i = 0; i <= NR_REG; i++) begin
            clrie_d[i] = (clrie_final_we[i]) ? clrie_mux0_i1[i] : clrie_q[i];         
        end
    end
    always_comb begin : setie_control_unit
        setie_select_i = DEFAULT;
        if (|setie_final_we) begin
            setie_select_i = SETIX;
        end else if (|clrie_final_we) begin
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
        
        for (int i = 0; i < NR_SRC; i++) begin
            setie_mux0_in[3][i/32][i%32] = setie_o[intp_domain_q[i]][i/32][i%32]; 
        end
        setie_final_we = setie_we[0] | setie_we[1];

        case (setie_select_i)       
            CLRIX       : setie_mux0_o           = setie_mux0_in[0];
            SETIXNUM    : setie_mux0_o           = setie_mux0_in[1];
            CLRIXNUM    : setie_mux0_o           = setie_mux0_in[2];
            SETIX       : setie_mux0_o           = setie_mux0_in[3];
            default     : setie_mux0_o           = setie_q;
        endcase
        setie_mux0_o[0][0]                          = 1'b0;
    end
    always_comb begin : rebuild_setie
        setie_full = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 0; j < NR_SRC; j++) begin
                setie_full[intp_domain_q[j]][j/32][j%32] = setie_q[j/32][j%32];
            end
        end
    end

    assign setie_d = setie_mux0_o & active;
    assign o_setie = setie_q;
// ================================================================

// =========================== TARGET =============================
  // Determines the new value of target
  always_comb begin : target_logic
    target_d = target_q;
    for (int i = 0; i < NR_DOMAINS ; i++) begin
        for (int j = 1; j < NR_SRC; j++) begin
        /** if the interrupt is active in the domain and has write enable,
            then choose the APLIC functioning mode to properly config the reg
            otherwise keep the same value */
        if((intp_domain_q[j] == i[0]) && active[j/32][j%32] && target_we[i][j]) begin
            case (domaincfg_q[i][2])
                APLIC_DIRECT_MODE:    target_d[j]    = {target_o[i][j][31:18], 10'b0, (target_o[i][j][7:0] == 0) ? 8'h1: target_o[i][j][7:0]};
                APLIC_MSI_MODE:       target_d[j]    = {target_o[i][j][31:12], 1'b0, target_o[i][j][10:0]};
                default:              target_d[j]    = target_q[j];     
            endcase               
        end
        end
    end
  end

  always_comb begin : target_rebuild
    target_full = '0;
    for (int i = 0; i < NR_DOMAINS; i++) begin
        for (int j = 1; j < NR_SRC; j++) begin
            target_full[intp_domain_q[j]][j] = target_q[j];
        end
    end
  end

  assign o_target = target_q;
// ================================================================

// ===================== CLAIMED FORWARDED ========================
  always_comb begin
    o_claimed_or_forwarded = '0;
    if (i_forwarded_valid) begin
        o_claimed_or_forwarded[i_intp_forwd_id/32][i_intp_forwd_id%32] = 1'b1;
    end
  end
// ================================================================

// ========================== GENMSI ==============================
  always_comb begin
    genmsi_d = genmsi_q;

    for (int i = 0; i < NR_DOMAINS; i++) begin
        if (genmsi_we[i] && !genmsi_q[i][12] && (genmsi_o[i][10:0] != '0)) begin
            genmsi_d[i] = {genmsi_o[i][31:18], {5{1'b0}}, 1'b1, 1'b0, genmsi_o[i][10:0]};
        end
        if (i_genmsi_sent[i]) begin
            /** clear the busy bit */
            genmsi_d[i] = genmsi_q[i] & ~(32'h1<<12);
        end
    end
  end

  assign o_genmsi = genmsi_q;
// ================================================================

/**=================== Registers sequential logic ===============*/
  always_ff @( posedge i_clk or negedge ni_rst ) begin
    if (!ni_rst) begin
        for (int i = 0; i < NR_DOMAINS; i++) begin
            domaincfg_q[i]     <= 32'h80000010;
        end
        intp_domain_q       <= '0;
        sourcecfg_q         <= '0;
        setipnum_q          <= '0;
        clripnum_q          <= '0;
        in_clrip_q          <= '0;
        setip_q             <= '0;
        setienum_q          <= '0;
        clrienum_q          <= '0;
        clrie_q             <= '0;
        setie_q             <= '0;
        target_q            <= '0;
        genmsi_q            <= '0;
    end else begin
        domaincfg_q         <= domaincfg_d;
        intp_domain_q       <= intp_domain_d;
        sourcecfg_q         <= sourcecfg_d;
        setipnum_q          <= setipnum_d;
        clripnum_q          <= clripnum_d;
        in_clrip_q          <= in_clrip_d;
        setip_q             <= setip_d;
        setienum_q          <= setienum_d;
        clrienum_q          <= clrienum_d;
        clrie_q             <= clrie_d;
        setie_q             <= setie_d;
        target_q            <= target_d;
        genmsi_q            <= genmsi_d;
    end
  end
// ================================================================

endmodule