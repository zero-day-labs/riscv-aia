/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_gateway 
import aplic_pkg::*;
#(
    parameter aplic_cfg_t                 AplicCfg      = DefaultAplicCfg,
    // DO NOT EDIT BY PARAMETER
    parameter int                         NR_REG        = (AplicCfg.NrSources-1)/32  
) (
    input   logic                                       i_clk,
    input   logic                                       ni_rst,
    input   logic  i_domaincfgDM                        [AplicCfg.NrDomains-1:0],
    input   logic [AplicCfg.NrSources-1:0]              i_sources,
    input   sourcecfg_t [AplicCfg.NrSources-1:1]        i_sourcecfg,
    input   intp_domain_t [AplicCfg.NrSources-1:1]      i_intp_domain,
    input   aia_bitmap_t [NR_REG:0]                     i_active,
    input   aia_bitmap_t [NR_REG:0]                     i_claimed,
    input   setip_t [NR_REG:0]                          i_sugg_setip,
    output  setip_t [NR_REG:0]                          o_setip,
    output  logic [AplicCfg.NrSources-1:0]              o_rectified_src,
    output  logic [AplicCfg.NrSources-1:0][2:0]         o_intp_pen_src
);

// ==================== LOCAL PARAMETERS ===================
    localparam INACTIVE             = 3'h0;
    localparam DETACHED             = 3'h1;
    localparam EDGE1                = 3'h4;
    localparam EDGE0                = 3'h5;
    localparam LEVEL1               = 3'h6;
    localparam LEVEL0               = 3'h7;

    localparam INACTIVE_C           = 3'h0;
    localparam DETACHED_C           = 3'h1;
    localparam EDGEX_C              = 3'h2;
    localparam LEVELXDM0_C          = 3'h3;
    localparam LEVELXDM1_C          = 3'h4;

    localparam FROM_RECTIFIER       = 1'b0;
    localparam FROM_EDGE_DETECTOR   = 1'b1;
// =========================================================

    /** Internal signals*/
    logic [AplicCfg.NrSources-1:0]          rectified_src, rectified_src_q;
    aia_bitmap_t [NR_REG:0]                 new_intp;
    /** Control signals */
    logic [AplicCfg.NrSources-1:0]          new_intp_src;
    logic [AplicCfg.NrSources-1:0][2:0]     intp_pen_src;

// ===================== Control Logic =====================
    always_comb begin
        for (integer i = 1; i < AplicCfg.NrSources; i++) begin
            new_intp_src[i]                 = FROM_RECTIFIER;
            intp_pen_src[i]                 = INACTIVE_C;

            case (i_sourcecfg[i].ddf.nd.sm)
                APLIC_SM_INACTIVE: begin
                    intp_pen_src[i]         = INACTIVE_C;
                end
                APLIC_SM_DETACHED: begin
                    intp_pen_src[i]         = DETACHED_C;
                end
                APLIC_SM_EDGE1, APLIC_SM_EDGE0: begin
                    new_intp_src[i]         = FROM_EDGE_DETECTOR;
                    intp_pen_src[i]         = EDGEX_C;
                end
                APLIC_SM_LEVEL1, APLIC_SM_LEVEL0: begin
                    for (int j = 0; j < AplicCfg.NrDomains; j++) begin
                        if (i_intp_domain[i] == j[AplicCfg.NrDomainsW-1:0]) begin
                            if(i_domaincfgDM[j])begin
                                new_intp_src[i]     = FROM_EDGE_DETECTOR;
                                intp_pen_src[i]     = LEVELXDM1_C;
                            end else begin
                                intp_pen_src[i]     = LEVELXDM0_C;
                            end
                        end
                    end
                end
                default: begin 
                    new_intp_src[i]         = FROM_RECTIFIER;
                    intp_pen_src[i]         = INACTIVE_C;
                end 
            endcase
        end
    end

    assign o_intp_pen_src = intp_pen_src;
// =========================================================

    /** Rectify the input*/
    always_comb begin
        for (int i = 1; i < AplicCfg.NrSources; i++) begin
            if ((i_sourcecfg[i].ddf.nd.sm == APLIC_SM_INACTIVE) || (i_sourcecfg[i].ddf.nd.sm == APLIC_SM_DETACHED)) begin
                rectified_src[i] = 0;
            end else begin
                rectified_src[i] = i_sources[i] ^ i_sourcecfg[i][0];
            end
        end
    end

    assign o_rectified_src = rectified_src_q;

    /** Select the new interrupt */
    for (genvar i = 1 ; i < AplicCfg.NrSources; i++) begin    
        assign new_intp[i/32][i%32] = (new_intp_src[i]) ? (rectified_src[i] & ~rectified_src_q[i]) : rectified_src[i];
    end

// =============== Choose logic to set pend ================
    always_comb begin
        for (int i = 1; i < AplicCfg.NrSources; i++) begin
            case (intp_pen_src[i])
                DETACHED_C: begin
                    o_setip[i/32][i%32] = i_sugg_setip[i/32][i%32] & i_active[i/32][i%32] & ~(i_claimed[i/32][i%32]);
                end
                EDGEX_C: begin
                    o_setip[i/32][i%32] = (new_intp[i/32][i%32] | i_sugg_setip[i/32][i%32]) & 
                                           i_active[i/32][i%32] & ~(i_claimed[i/32][i%32]);
                end
                LEVELXDM0_C: begin
                    o_setip[i/32][i%32] = new_intp[i/32][i%32] & i_active[i/32][i%32];
                end
                LEVELXDM1_C: begin
                    o_setip[i/32][i%32] = (new_intp[i/32][i%32] | (i_sugg_setip[i/32][i%32] & rectified_src[i])) & 
                                           i_active[i/32][i%32] & ~(~new_intp[i/32][i%32] | i_claimed[i/32][i%32]);
                end
                default: begin
                    o_setip[i/32][i%32] = 1'b0;
                end
            endcase
        end
    end
// =========================================================

// =============== Registers sequential logic ==============
    always_ff @(posedge i_clk, negedge ni_rst) begin
        if(!ni_rst)begin
            rectified_src_q <= '0;
        end else begin
            rectified_src_q <= rectified_src;
        end
    end
// =========================================================

endmodule