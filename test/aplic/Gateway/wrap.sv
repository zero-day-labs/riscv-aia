/**
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_gateway_wrapper #(
    parameter int NR_SRC = 32,
    parameter int NR_BITS_SRC = (NR_SRC > 32)? 32 : NR_SRC,
    parameter int NR_REG = (NR_SRC-1)/32 
) (
    input   logic                                       i_clk,
    input   logic                                       ni_rst,
    input   logic [NR_SRC-1:0]                          i_sources,
    input   logic [((NR_SRC)*11)-1:0]                   i_sourcecfg,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_sugg_setip,
    input   logic                                       i_domaincfgDM,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_active,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_claimed,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_intp_pen,
    output  logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        o_rectified_src
);

logic                                     clk_i;
logic                                     rst_ni;
logic [NR_SRC-1:0]                        sources_i;
logic [NR_SRC-1:1][10:0]                  sourcecfg_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]         sugg_setip_i;
logic                                     domaincfgDM_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]         active_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]         claimed_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]         intp_pen_o;
logic [NR_REG:0][NR_BITS_SRC-1:0]         rectified_src_o;

/** Assign single lines */
assign clk_i            = i_clk;
assign rst_ni           = ni_rst;
assign domaincfgDM_i    = i_domaincfgDM;

/** Converts 1D array into 2D array */
for (genvar i = 0; i < NR_SRC; i++) begin
    assign sources_i[i]         = i_sources[i];
end
for (genvar i = 1; i < NR_SRC-1; i++) begin
    assign sourcecfg_i[i]       = i_sourcecfg[i*11 +: 11];
end
for (genvar i = 0; i <= NR_REG; i++) begin
    assign sugg_setip_i[i]      = i_sugg_setip[i*NR_BITS_SRC +: NR_BITS_SRC];
    assign active_i[i]          = i_active[i*NR_BITS_SRC +: NR_BITS_SRC];
    assign claimed_i[i]         = i_claimed[i*NR_BITS_SRC +: NR_BITS_SRC];

    assign o_intp_pen[i*NR_BITS_SRC +: NR_BITS_SRC]         = intp_pen_o[i];
    assign o_rectified_src[i*NR_BITS_SRC +: NR_BITS_SRC]    = rectified_src_o[i];
end

/** Instantiate the DUT*/
aplic_domain_gateway#(
    .NR_SRC(NR_SRC)
) aplic_domain_gateway_i(
        .i_clk(clk_i),
        .ni_rst(rst_ni),
        .i_sources(sources_i),
        .i_sourcecfg(sourcecfg_i),
        .i_sugg_setip(sugg_setip_i),
        .i_domaincfgDM(domaincfgDM_i),
        .i_active(active_i),
        .i_claimed(claimed_i),
        .o_intp_pen(intp_pen_o),
        .o_rectified_src(rectified_src_o)
);

endmodule