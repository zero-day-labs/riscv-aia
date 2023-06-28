/** 
*   Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda.
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
* NOTE:        This module is part of minimal APLIC. Our minimal APLIC implements only
*              two domains (M and S). From the AIA specification can be read (section 4.5):
*              "APLIC implementations can exploit the fact that each source is ultimately active 
*              in only one domain."
*              As so, this minimal version implements only one domain and relies on logic to mask 
*              the interrupt to the correct domain.
* NOTE2:       This gateway implements only one source mode (raising edge1) besides the inactive mode 
               in order to reduce the hardware utilization
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
    localparam INACTIVE                         = 3'h0;
    localparam EDGE1                            = 3'h4;

    localparam logic [2:0] EDGE1_MASK           = (1 << EDGE1);
// =========================================================

/** Internal signals*/
logic [NR_SRC-1:0]  sources_q;

/** Converts the rectified 1D array into a 2D array format */
for (genvar i = 0; i <= NR_REG; i++) begin
    assign o_rectified_src[i] = i_sources[NR_BITS_SRC*i +: NR_BITS_SRC];
end

// =============== Choose logic to set pend ================
    always_comb begin
        o_setip = '0;
        for (int i = 1; i < NR_SRC; i++) begin
            /** Only raising edge source is allowed*/
            if (i_sourcecfg[i][2]) begin
                o_setip[i/32][i%32] = ((i_sources[i] & ~sources_q[i]) | i_sugg_setip[i/32][i%32]) & 
                                        i_active[i/32][i%32] & ~(i_claimed[i/32][i%32]);
            end
        end
    end
// =========================================================

// =============== Registers sequential logic ==============
    always_ff @(posedge i_clk, negedge ni_rst) begin
        if(!ni_rst)begin
            sources_q <= '0;
        end else begin
            sources_q <= i_sources;
        end
    end
// =========================================================

endmodule