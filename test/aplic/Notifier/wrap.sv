/**
* Name: Gatway Wrapper
* Date: 7/10/2022
* Author: F.Marques <fmarques_00@protonmail.com>
*
* Description: Cocotb apparently in version 1.7.1 cannot read multidimensional
*              arrays (array[x][y]). As so, to make sure that the DUT is properly 
*              tested, this wrapper converts 2D arrays into 1D for the DUT interface.
*/

module aplic_domain_notifier_wrapper #(
    parameter int                                       NR_SRC      = 32,
    parameter int                                       NR_BITS_SRC = (NR_SRC > 32)? 32:NR_SRC,
    parameter int                                       NR_REG      = (NR_SRC-1)/32,
    parameter int                                       NR_IDCs     = 1,
    parameter                                           APLIC       = "NON-LEAF",
    parameter                                           MODE        = "DIRECT"
) (
    input   logic                                       i_clk,
    input   logic                                       ni_rst,
    input   logic                                       i_domaincfgIE,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_setip_q,
    input   logic [((NR_REG+1)*NR_BITS_SRC)-1:0]        i_setie_q,
    input   logic [(NR_SRC*32)-1:0]                     i_target_q,
    `ifdef DIRECT_MODE
    /**  interface for direct mode */
    input   logic [NR_IDCs-1:0]                         i_idelivery,
    input   logic [NR_IDCs-1:0]                         i_iforce,
    input   logic [(NR_IDCs*3)-1:0]                     i_ithreshold,
    output  logic [(NR_IDCs*26)-1:0]                    o_topi_sugg,
    output  logic [NR_IDCs-1:0]                         o_topi_update,
    output  logic [NR_IDCs-1:0]                         o_Xeip_targets
    `elsif MSI_MODE
    /** interface for MSI mode */
    output  ariane_axi::req_t                           o_req           ,
    input   ariane_axi::resp_t                          i_resp
    `endif
);


logic                                   clk_i;
logic                                   rst_ni;
logic                                   domaincfgIE_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]       setip_q_i;
logic [NR_REG:0][NR_BITS_SRC-1:0]       setie_q_i;
logic [NR_SRC-1:1][31:0]                target_q_i;
/**  interface for direct mode */
logic [NR_IDCs-1:0]                      idelivery_i;
logic [NR_IDCs-1:0]                      iforce_i;
logic [NR_IDCs-1:0][2:0]                 ithreshold_i;
logic [NR_IDCs-1:0][25:0]                topi_sugg_o;
logic [NR_IDCs-1:0]                      topi_update_o;
logic [NR_IDCs-1:0]                      Xeip_targets_o;
/** interface for MSI mode */
// logic [31:0]                            mmsiaddrcfg_i;
// logic [31:0]                            mmsiaddrcfgh_i;
// logic [31:0]                            smsiaddrcfg_i;
// logic [31:0]                            smsiaddrcfgh_i;
// Outputs for MSI interface here

/** Assign single lines */
assign clk_i            = i_clk;
assign rst_ni           = ni_rst;
assign domaincfgIE_i    = i_domaincfgIE;

/** Converts 1D array into 2D array */
for (genvar i = 1; i < NR_SRC; i++) begin
    assign target_q_i[i]         = i_target_q[i*32 +: 32];
end
for (genvar i = 0; i <= NR_REG; i++) begin
    assign setip_q_i[i]         = i_setip_q[i*NR_BITS_SRC +: NR_BITS_SRC];
    assign setie_q_i[i]         = i_setie_q[i*NR_BITS_SRC +: NR_BITS_SRC];
end

`ifdef DIRECT_MODE
for (genvar i = 0; i < NR_IDCs; i++) begin
    assign idelivery_i[i]                   = i_idelivery[i];
    assign iforce_i[i]                      = i_iforce[i];
    assign ithreshold_i[i]                  = i_ithreshold[i*(2+1) +: (2+1)];
    assign o_topi_sugg[i*(25+1) +: (25+1)]  = topi_sugg_o[i];
    assign o_Xeip_targets[i]                = Xeip_targets_o[i];
    assign o_topi_update[i]                 = topi_update_o[i];
end
`endif

/** Instantiate the DUT*/
aplic_domain_notifier #(
    .NR_SRC(NR_SRC),
    .NR_BITS_SRC(NR_BITS_SRC),
    .NR_REG(NR_REG),
    .NR_IDCs(NR_IDCs),
    .APLIC(APLIC),
    .MODE(MODE)
) aplic_domain_notifier_i (
    .i_clk(clk_i),
    .ni_rst(rst_ni),
    .i_domaincfgIE(domaincfgIE_i),
    .i_setip_q(setip_q_i),
    .i_setie_q(setie_q_i),
    .i_target_q(target_q_i),
    `ifdef DIRECT_MODE
    .i_idelivery(idelivery_i),
    .i_iforce(iforce_i),
    .i_ithreshold(ithreshold_i),
    .o_topi_sugg(topi_sugg_o),
    .o_topi_update(topi_update_o),
    .o_Xeip_targets(Xeip_targets_o)
    `elsif MSI_MODE
    .o_req(o_req),
    .i_resp(i_resp)
    `endif
);

endmodule