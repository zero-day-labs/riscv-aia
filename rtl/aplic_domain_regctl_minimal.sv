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
*   dstributed under the License is dstributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONdTIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*
* Description: This module is responsible for all the
*              logic used to determine the registers value.
*
* Notes: The sourcecfg register needs to be implemented separatly for each domain. 
*        As it is, creates a security breach where S domain can take control of 
*        M domain interrupts even if they were not delegated.
*
*/

module aplic_domain_regctl #(
    parameter int                                                   NR_DOMAINS          = 2,
    parameter int                                                   DOMAIN_M_ADDR       = 32'hc000000,
    parameter int                                                   DOMAIN_S_ADDR       = 32'hd000000,
    parameter int                                                   NR_SRC              = 32,
    parameter int                                                   NR_IDCs             = 1,
    parameter int                                                   MIN_PRIO            = 6,
    parameter type                                                  reg_req_t           = logic,
    parameter type                                                  reg_rsp_t           = logic,
    // DO NOT EdT BY PARAMETER
    parameter int                                                   IPRIOLEN            = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO),
    parameter int                                                   NR_BITS_SRC         = 32,//(NR_SRC > 31) ? 32 : NR_SRC,
    parameter int                                                   NR_SRC_W            = 10,//(NR_SRC == 1) ? 1 : $clog2(NR_SRC),
    parameter int                                                   NR_REG              = (NR_SRC-1)/32  
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
    output  logic [NR_DOMAINS-1:0][NR_REG:0][NR_BITS_SRC-1:0]       o_active            ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_claimed_or_forwarded ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_intp_pen          ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_rectified_src     ,
    /** Notifier */
    output  logic [NR_DOMAINS-1:0]                                  o_domaincfgIE       , 
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_setip             ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                       o_setie             ,
    output  logic [NR_SRC-1:1][31:0]                                o_target            ,
`ifdef DIRECT_MODE
    /**  interface for direct mode */
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                o_idelivery         ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                o_iforce            ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0]       o_ithreshold        ,
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][25:0]               i_topi              ,
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     i_topi_update
`endif
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

logic [NR_DOMAINS-1:0][NR_REG:0][NR_BITS_SRC-1:0]   active;
logic [2:0]                                         setie_select_i, setip_select_i;
logic [NR_DOMAINS-1:0][NR_IDCs:0][1:0]              iforce_ctl;

// =============== Register Map instantiation ==============
  // Register domaincfg
  logic [NR_DOMAINS-1:0][31:0]                      domaincfg_q, domaincfg_d;
  logic [NR_DOMAINS-1:0][31:0]                      domaincfg_o;
  logic [NR_DOMAINS-1:0]                            domaincfg_we;
  // Register sourcecfg
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][10:0]          sourcecfg_q, sourcecfg_d;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][10:0]          sourcecfg_o;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1]                sourcecfg_we;
  // Register setip
  logic [NR_REG:0][31:0]                            setip_q, setip_d;
  logic [3:0][NR_REG:0][31:0]                       setip_mux0_in;
  logic [NR_REG:0][31:0]                            setip_mux0_o;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setip_full;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setip_or_in;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setip_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  setip_we;
  // Register setipnum
  logic [31:0]                                      setipnum_q, setipnum_d;
  logic [31:0]                                      setip_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      setipnum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      setipnum_o;
  logic [NR_DOMAINS-1:0]                            setipnum_we;
  // Register in_clrip
  logic [NR_REG:0][31:0]                            in_clrip_q, in_clrip_d;
  logic [NR_REG:0][31:0]                            clrip_mux0_i1;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            in_clrip_full, clrip_or_in;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            in_clrip_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  in_clrip_we;
  // Register clripnum
  logic [31:0]                                      clripnum_q, clripnum_d;
  logic [31:0]                                      clrip_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      clripnum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      clripnum_o;
  logic [NR_DOMAINS-1:0]                            clripnum_we;
  // Register setie
  logic [NR_REG:0][31:0]                            setie_q, setie_d;
  logic [3:0][NR_REG:0][31:0]                       setie_mux0_in;
  logic [NR_REG:0][31:0]                            setie_mux0_o;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setie_full;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setie_or_in;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            setie_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  setie_we;
  // Register setienum
  logic [31:0]                                      setienum_q, setienum_d;
  logic [31:0]                                      setie_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      setienum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      setienum_o;
  logic [NR_DOMAINS-1:0]                            setienum_we;
  // Register clrie
  logic [NR_REG:0][31:0]                            clrie_q, clrie_d;
  logic [NR_REG:0][31:0]                            clrie_mux0_i1;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            clrie_full, clrie_or_in;
  logic [NR_DOMAINS-1:0][NR_REG:0][31:0]            clrie_o;
  logic [NR_DOMAINS-1:0][NR_REG:0]                  clrie_we;
  // Register clrienum
  logic [31:0]                                      clrienum_q, clrienum_d;
  logic [31:0]                                      clrie_mux2_i1;
  logic [NR_DOMAINS-1:0][31:0]                      clrienum_mux0_out;
  logic [NR_DOMAINS-1:0][31:0]                      clrienum_o;
  logic [NR_DOMAINS-1:0]                            clrienum_we;
  // Register target
  logic [NR_SRC-1:1][31:0]                          target_q, target_d;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][31:0]          target_full;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1][31:0]          target_o;
  logic [NR_DOMAINS-1:0][NR_SRC-1:1]                target_we;

  logic debug;
`ifdef DIRECT_MODE
  // Register idelivery
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]          idelivery_q, idelivery_d;
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]          idelivery_o;
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]               idelivery_we;
  // Register iforce
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]          iforce_q, iforce_d;
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]          iforce_o;
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]               iforce_we;
  // Register ithreshold
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0] ithreshold_q, ithreshold_d;
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0] ithreshold_o;
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]               ithreshold_we;
  // Register topi
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][25:0]         topi_q, topi_d;
  // Register claimi
  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]               claimi_re, claimi_re_q;
`endif
`ifdef MSI_MODE
  // Register genmsi
  logic [NR_DOMAINS-1:0][31:0]                      genmsi_q, genmsi_d;
  logic [NR_DOMAINS-1:0][31:0]                      genmsi_o;
  logic [NR_DOMAINS-1:0]                            genmsi_we;
`endif

  aplic_regmap_minimal #(
    .DOMAIN_M_ADDR          ( DOMAIN_M_ADDR     ),
    .DOMAIN_S_ADDR          ( DOMAIN_S_ADDR     ),
    .NR_SRC                 ( NR_SRC            ),
    .MIN_PRIO               ( MIN_PRIO          ),
    .IPRIOLEN               ( IPRIOLEN          ),
    .NR_IDCs                ( NR_IDCs           ),
    .reg_req_t              ( reg_req_t         ),
    .reg_rsp_t              ( reg_rsp_t         )
  ) i_aplic_regmap_minimal (
    // Register: domaincfg
    .i_domaincfg            ( domaincfg_q       ),
    .o_domaincfg            ( domaincfg_o       ),
    .o_domaincfg_we         ( domaincfg_we      ),
    .o_domaincfg_re         (),
    // Register: sourcecfg
    .i_sourcecfg            ( sourcecfg_q       ),
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
`ifdef DIRECT_MODE
    // Register: idelivery
    .i_idelivery            ( idelivery_q       ),
    .o_idelivery            ( idelivery_o       ),
    .o_idelivery_we         ( idelivery_we      ),
    .o_idelivery_re         (),
    // Register: iforce
    .i_iforce               ( iforce_q          ),
    .o_iforce               ( iforce_o          ),
    .o_iforce_we            ( iforce_we         ),
    .o_iforce_re            (),
    // Register: ithreshold
    .i_ithreshold           ( ithreshold_q      ),
    .o_ithreshold           ( ithreshold_o      ),
    .o_ithreshold_we        ( ithreshold_we     ),
    .o_ithreshold_re        (),
    // Register: topi
    .i_topi                 ( topi_q            ),
    .o_topi_re              (),
    // Register: claimi
    .i_claimi               ( topi_q            ),
    .o_claimi_re            ( claimi_re         ),
    // Register: genmsi
    .i_genmsi               (),
    .o_genmsi               (),
    .o_genmsi_we            (),
    .o_genmsi_re            (),
`else
    // Register: idelivery
    .i_idelivery            (),
    .o_idelivery            (),
    .o_idelivery_we         (),
    .o_idelivery_re         (),
    // Register: iforce
    .i_iforce               (),
    .o_iforce               (),
    .o_iforce_we            (),
    .o_iforce_re            (),
    // Register: ithreshold
    .i_ithreshold           (),
    .o_ithreshold           (),
    .o_ithreshold_we        (),
    .o_ithreshold_re        (),
    // Register: topi
    .i_topi                 (),
    .o_topi_re              (),
    // Register: claimi
    .i_claimi               (),
    .o_claimi_re            (),
    // Register: genmsi
    .i_genmsi               ( genmsi_q          ),
    .o_genmsi               ( genmsi_o          ),
    .o_genmsi_we            ( genmsi_we         ),
    .o_genmsi_re            (),
`endif
    .i_req                  ( i_req_cfg         ),
    .o_resp                 ( o_resp_cfg        )
  ); // End of Regmap instance

// ========================== ACTIVE ==============================
    always_comb begin
        active = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 1; j < NR_SRC; j++) begin
                if(!((sourcecfg_q[i][j][10] == DELEGATED) || 
                    ((sourcecfg_q[i][j][10] == NON_DELEGATED) && (sourcecfg_q[i][j][2:0] == INACTIVE)))) begin
                    active[i][j/32][j%32] = INTP_ACTIVE;
                end
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
    always_comb begin :sourcecfg_logic
        /** reset value */
        sourcecfg_d = sourcecfg_q;
    
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 1; j < NR_SRC; j++) begin
                case ({sourcecfg_o[i][j][10], sourcecfg_we[i][j]})
                    {NON_DELEGATED, 1'b1} : sourcecfg_d[i][j] = {sourcecfg_o[i][j][10], 7'b0, sourcecfg_o[i][j][2:0]};
                    /** We only support M -> S configuration for now. 
                        As so, the last domain (S) is the only leaf. 
                        When we try to delegate an intp on a leaf domain, zero the reg. */
                    {DELEGATED, 1'b1}     : sourcecfg_d[i][j] = (i == NR_DOMAINS-1) ? '0 : sourcecfg_o[i][j];
                    default:;
                endcase
            end
        end
    end

    /** We only send to the gateway the sourcecfg of active intp. 
        For the gateway there is no concept of domain (+-) */
    always_comb begin : sourcecfg_out_logic
        o_sourcecfg = '0;
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 1; j < NR_SRC; j++) begin
                if(active[i][j/32][j%32]) begin
                    o_sourcecfg[j] = sourcecfg_q[i][j];
                end
            end
        end
    end
    
// ================================================================

// ========================== PENDING =============================
    always_comb begin : setipnum_logic
        for (int i = 0; i < NR_DOMAINS; i++) begin
            setipnum_mux0_out[i]    = (active[i][setipnum_o[i]/32][setipnum_o[i]%32]) ? setipnum_o[i] : '0;
        end
        setip_mux2_i1   = setipnum_mux0_out[0] | setipnum_mux0_out[1];
        setipnum_d      = (|setipnum_we) ? setip_mux2_i1 : setipnum_q;
    end
    always_comb begin : clripnum_logic
        for (int i = 0; i < NR_DOMAINS; i++) begin
            clripnum_mux0_out[i]    = (active[i][clripnum_o[i]/32][clripnum_o[i]%32]) ? clripnum_o[i] : '0;
        end
        clrip_mux2_i1   = clripnum_mux0_out[0] | clripnum_mux0_out[1];
        clripnum_d      = (|clripnum_we) ? clrip_mux2_i1 : clripnum_q;
    end
    always_comb begin : inclrip_logic
        clrip_or_in = in_clrip_o & active;
        clrip_mux0_i1 = clrip_or_in[1] | clrip_or_in[0];
        for (int j = 0; j <= NR_REG; j++) begin 
            in_clrip_d[j]    = (in_clrip_we[0][j] || in_clrip_we[1][j]) ? clrip_mux0_i1[j] : in_clrip_q[j]; 
        end 
    end
    always_comb begin : rebuild_inclrip
        for (int i = 0; i < NR_DOMAINS; i++) begin
            in_clrip_full[i] = active[i] & i_rectified_src;
        end
    end
    always_comb begin : setip_control_unit
        setip_select_i = DEFAULT;
        if (|setip_we) begin
            setip_select_i = SETIX;
        end else if (|in_clrip_we) begin
            setip_select_i = CLRIX;
        end else if (|setipnum_we) begin
            setip_select_i = SETIXNUM;
        end else if (|clripnum_we) begin
            setip_select_i = CLRIXNUM;
        end
    end
    always_comb begin : setip_logic
        setip_mux0_in[0]    = ~in_clrip_d & setip_q;

        setip_mux0_in[1]    = setip_q;
        setip_mux0_in[1][setipnum_d/32][setipnum_d%32] = 1'b1;

        setip_mux0_in[2]    = setip_q;
        setip_mux0_in[2][clripnum_d/32][clripnum_d%32] = 1'b0;
        
        setip_or_in         = setip_o & active;
        setip_mux0_in[3]    = (setip_or_in[1] | (setip_q & ~active[1])) | (setip_or_in[0] | (setip_q & ~active[0]));

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
        for (int i = 0; i < NR_DOMAINS; i++) begin
            setip_full[i] = active[i] & setip_q;
        end
    end

    assign setip_d      = i_intp_pen;
    assign o_sugg_setip = setip_mux0_o;
    assign o_setip      = setip_q;
// ================================================================

// =========================== ENABLE =============================
    always_comb begin : setienum_logic
        for (int i = 0; i < NR_DOMAINS; i++) begin
            setienum_mux0_out[i]    = (active[i][setienum_o[i]/32][setienum_o[i]%32]) ? setienum_o[i] : '0;
        end
        setie_mux2_i1   = setienum_mux0_out[0] | setienum_mux0_out[1];
        setienum_d      = (|setienum_we) ? setie_mux2_i1 : setienum_q;
    end
    always_comb begin : clrienum_logic
        for (int i = 0; i < NR_DOMAINS; i++) begin
            clrienum_mux0_out[i]    = (active[i][clrienum_o[i]/32][clrienum_o[i]%32]) ? clrienum_o[i] : '0;
        end
        clrie_mux2_i1   = clrienum_mux0_out[0] | clrienum_mux0_out[1];
        clrienum_d      = (|clrienum_we) ? clrie_mux2_i1 : clrienum_q;
    end
    always_comb begin : clrie_logic
        clrie_or_in = clrie_o & active;
        clrie_mux0_i1 = clrie_or_in[1] | clrie_or_in[0];
        for (int j = 0; j <= NR_REG; j++) begin 
            clrie_d[j]    = (clrie_we[0][j] || clrie_we[1][j]) ? clrie_mux0_i1[j] : clrie_q[j]; 
        end 
    end
    always_comb begin : setie_control_unit
        setie_select_i = DEFAULT;
        if (|setie_we) begin
            setie_select_i = SETIX;
        end else if (|clrie_we) begin
            setie_select_i = CLRIX;
        end else if (|setienum_we) begin
            setie_select_i = SETIXNUM;
        end else if (|clrienum_we) begin
            setie_select_i = CLRIXNUM;
        end
    end
    always_comb begin : setie_logic
        setie_mux0_in[0]    = ~clrie_q & setie_q;

        setie_mux0_in[1]    = setie_q;
        setie_mux0_in[1][setienum_d/32][setienum_d%32] = 1'b1;

        setie_mux0_in[2]    = setie_q;
        setie_mux0_in[2][clrienum_d/32][clrienum_d%32] = 1'b0;
        
        setie_or_in         = setie_o & active;
        setie_mux0_in[3]    = (setie_or_in[1] | (setie_q & ~active[1])) | (setie_or_in[0] | (setie_q & ~active[0]));

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
        for (int i = 0; i < NR_DOMAINS; i++) begin
            setie_full[i] = active[i] & setie_q;
        end
    end
    assign setie_d = setie_mux0_o & (active[0] | active[1]);

    assign o_setie = setie_q;
// ================================================================

// =========================== TARGET =============================
  // Determines the new value of target
  always_comb begin : target_logic
      for (int i = 0; i < NR_DOMAINS ; i++) begin
          for (int j = 1; j < NR_SRC; j++) begin
            /** if the interrupt is active in the domain and has write enable,
                then choose the APLIC functioning mode to properly config the reg
                otherwise keep the same value */
            if(active[i][j/32][j%32] && target_we[i][j]) begin
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
    for (int i = 0; i < NR_DOMAINS; i++) begin
        for (int j = 1; j < NR_SRC; j++) begin
            target_full[i][j] = (active[i][j/32][j%32]) ? target_q[j] : '0;
        end 
    end
  end

  assign o_target = target_q;
// ================================================================

// ===================== CLAIMED FORWARDED ========================
  always_comb begin
    o_claimed_or_forwarded = '0;
    `ifdef DIRECT_MODE
        for (int i = 0; i < NR_DOMAINS; i++) begin
           for (int j = 0; j < NR_IDCs; j++) begin
                if ((claimi_re[i][j] == 1'b1) && (claimi_re_q[i][j] == 1'b0)) begin
                    o_claimed_or_forwarded[topi_q[i][j][16 +: NR_SRC_W]/32][topi_q[i][j][16 +: NR_SRC_W]%32] = 1'b1;
                end 
            end 
        end
    `endif
  end
// ================================================================

// ============================ IDC ===============================
    `ifdef DIRECT_MODE
    always_comb begin : iforce_control_unit
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 0; j < NR_IDCs; j++) begin
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
        for (int i = 0; i < NR_DOMAINS; i++) begin
            for (int j = 0; j < NR_IDCs; j++) begin
                idelivery_d[i][j]       = (idelivery_we[i][j]) ? idelivery_o[i][j] : idelivery_q[i][j];
                ithreshold_d[i][j]      = (ithreshold_we[i][j]) ? ithreshold_o[i][j] : ithreshold_q[i][j];
                topi_d[i][j]            = ((topi_q[i][j] != 0) && claimi_re[i][j]) ? '0 :
                                        ((i_topi_update[i][j])) ? i_topi[i][j] : topi_q[i][j]; 
                case (iforce_ctl[i][j])
                    ZERO_FORCE: iforce_d[i]  = '0;
                    W_FORCE:    iforce_d[i]  = iforce_o[i][j]; 
                    default:    iforce_d[i]  = iforce_q[i][j];
                endcase
            end
        end
    end

    assign o_idelivery    = idelivery_q;
    assign o_ithreshold   = ithreshold_q;
    assign o_iforce       = iforce_q;
    `endif
// ================================================================

/**=================== Registers sequential logic ===============*/
  always_ff @( posedge i_clk or negedge ni_rst ) begin
    if (!ni_rst) begin
        for (int i = 0; i < NR_DOMAINS; i++) begin
        `ifdef MSI_MODE
            domaincfg_q[i]     <= 32'h80000010;
        `else
            domaincfg_q[i]     <= 32'h80000000;
        `endif
        end
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
        `ifdef DIRECT_MODE
        idelivery_q         <= '0;
        ithreshold_q        <= '0;
        topi_q              <= '0;
        iforce_q            <= '0;
        claimi_re_q         <= '0;
        `endif
    end else begin
        domaincfg_q         <= domaincfg_d;
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
        `ifdef DIRECT_MODE
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