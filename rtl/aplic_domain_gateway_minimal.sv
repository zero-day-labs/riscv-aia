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
* Description: The APLIC domain gateway is the module encharge of
*              receiving the current setip array, and the new setip 
*              and follow the section 4.6 of AIA spec to determine the
*              new valid setip array value.
*              Also in this module happens the inverted interrupts rectification
* NOTE: This module is part of minimal APLIC. Our minimal APLIC implements only
*       two domains (M and S). From the AIA specification can be read (section 4.5):
*       "APLIC implementations can exploit the fact that each source is ultimately active 
*       in only one domain."
*       As so, this minimal version implements only one domain and relies on logic to mask 
*       the interrupt to the correct domain.
*/
module aplic_domain_gateway #(
    parameter int                                               NR_SRC        = 32,
    parameter int                                               NR_DOMAINS    = 2 ,
    // DO NOT EDIT BY PARAMETER
    parameter int                                               NR_BITS_SRC   = (NR_SRC > 32)? 32 : NR_SRC,
    parameter int                                               NR_REG        = (NR_SRC-1)/32  
) (
    input   logic                                               i_clk             ,
    input   logic                                               ni_rst            ,
    input   logic [NR_SRC-1:0]                                  i_sources         ,
    input   logic [NR_SRC-1:1][10:0]                            i_sourcecfg       ,
    input   logic [NR_DOMAINS-1:0]                              i_domaincfgDM     ,
    input   logic [NR_SRC-1:1]                                  i_intp_domain     ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                   i_active          ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                   i_sugg_setip      ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                   i_claimed         ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                   o_setip           ,
    output  logic [NR_REG:0][NR_BITS_SRC-1:0]                   o_rectified_src
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
logic [NR_SRC-1:0]                      rectified_src, rectified_src_q;
logic [NR_REG:0][NR_BITS_SRC-1:0]       new_intp;
/** Control signals */
logic [NR_SRC-1:0]                      new_intp_src;
logic [NR_SRC-1:0][2:0]                 intp_pen_src;

// ===================== Control Logic =====================
    always_comb begin
        for (integer i = 1; i < NR_SRC; i++) begin
            new_intp_src[i]                 = FROM_RECTIFIER;
            intp_pen_src[i]                 = INACTIVE_C;

            case (i_sourcecfg[i][2:0])
                INACTIVE: begin
                    intp_pen_src[i]         = INACTIVE_C;
                end
                DETACHED: begin
                    intp_pen_src[i]         = DETACHED_C;
                end
                EDGE1, EDGE0: begin
                    new_intp_src[i]         = FROM_EDGE_DETECTOR;
                    intp_pen_src[i]         = EDGEX_C;
                end
                LEVEL1, LEVEL0: begin
                    for (int j = 0; j < NR_DOMAINS; j++) begin
                        if (i_intp_domain[j] == j[0]) begin
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
// =========================================================

/** Rectify the input*/
for (genvar i = 1; i < NR_SRC; i++) begin
    assign rectified_src[i] = i_sources[i] ^ i_sourcecfg[i][0];
end
/** Converts the rectified 1D array into a 2D array format */
for (genvar i = 0; i <= NR_REG; i++) begin
    assign o_rectified_src[i] = rectified_src[NR_BITS_SRC*i +: NR_BITS_SRC];
end

/** Select the new interrupt */
for (genvar i = 1 ; i < NR_SRC; i++) begin    
    assign new_intp[i/32][i%32] = (new_intp_src[i]) ? (rectified_src[i] & ~rectified_src_q[i]) : rectified_src[i];
end

// =============== Choose logic to set pend ================
    always_comb begin
        for (int i = 1; i < NR_SRC; i++) begin
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
                    o_setip[i/32][i%32] = (new_intp[i/32][i%32] | i_sugg_setip[i/32][i%32]) & i_active[i/32][i%32] & 
                                        ~(~new_intp[i/32][i%32] | i_claimed[i/32][i%32]);
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