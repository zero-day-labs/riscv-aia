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
* Description: This module can have two possible implementations, depending on the 
*              chosen delivery mode. Therefore, if the delivery mode is direct, the 
*              notifier will implement a basic algorithm to detect the highest-priority 
*              interrupt that is pending and enabled. If the chosen delivery mode is MSI, 
*              the notifier does not make any judgment regarding the priority of an interrupt 
*              (which is done in the IMSIC and RISC-V core), limiting itself to forwarding 
*              an interrupt as soon as it becomes pending and enabled.
*
* NOTE:        4.5.3 " For APLICs that support MSI delivery mode, it is recommended, 
*              if feasible, that the APLIC internally hardwire the physical addresses 
*              for all target IMSICs, putting those addresses beyond the reach of 
*              software to change"
*/
module aplic_domain_notifier #(
    parameter int                                                   NR_DOMAINS      = 2,
    parameter int                                                   NR_SRC          = 32,
    parameter int                                                   NR_IDCs         = 1,
    parameter int                                                   MIN_PRIO        = 6,
    // DO NOT EDIT BY PARAMETER
    parameter int                                                   NR_BITS_SRC     = (NR_SRC > 32) ? 32 : NR_SRC,
    parameter int                                                   NR_REG          = (NR_SRC-1)/32,
    parameter int                                                   IPRIOLEN        = (MIN_PRIO == 1) ? 1 : $clog2(MIN_PRIO)
) (
    input   logic                                                   i_clk           ,
    input   logic                                                   ni_rst          ,
    input   logic [NR_DOMAINS-1:0]                                  i_domaincfgIE   ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_setip_q       ,
    input   logic [NR_REG:0][NR_BITS_SRC-1:0]                       i_setie_q       ,
    input   logic [NR_SRC-1:1][31:0]                                i_target_q      ,
    input   logic [NR_DOMAINS-1:0][NR_REG:0][NR_BITS_SRC-1:0]       i_active        ,
    `ifdef DIRECT_MODE
    /** interface for direct mode */
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                i_idelivery     ,
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][0:0]                i_iforce        ,
    input   logic [NR_DOMAINS-1:0][NR_IDCs-1:0][IPRIOLEN-1:0]       i_ithreshold    ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0][25:0]               o_topi_sugg     ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     o_topi_update   ,
    output  logic [NR_DOMAINS-1:0][NR_IDCs-1:0]                     o_Xeip_targets  
    // `elsif MSI_MODE
    // /** interface for MSI mode */
    // input   logic [31:0]                            i_genmsi         ,
    // output  logic                                   o_genmsi_sent    ,
    // output  logic                                   o_forwarded_valid,
    // output  logic [10:0]                            o_intp_forwd_id  ,
    // output  logic                                   o_busy           ,
    // output  ariane_axi::req_t                       o_req            ,
    // input   ariane_axi::resp_t                      i_resp
    `endif
);

localparam TARGET_HART_IDX          = 18;
localparam NR_IDC_W                 = (NR_IDCs == 1) ? 1 : $clog2(NR_IDCs);

`ifdef DIRECT_MODE
    
    logic [NR_DOMAINS-1:0][NR_IDCs-1:0]         has_valid_intp;
    logic [NR_DOMAINS-1:0][NR_IDC_W-1:0]        idc_index;
    logic [NR_DOMAINS-1:0][9:0]                 intp_id;
    logic [NR_DOMAINS-1:0][7:0]                 intp_prio;
    logic [NR_DOMAINS-1:0][IPRIOLEN-1:0]        prev_higher_prio;

    /** Detect highest pending-enabled interrut and notify the hart */
    always_comb begin
        /** internal signals reset values*/
        has_valid_intp      = '0;
        idc_index           = '0;
        intp_id             = '0;
        intp_prio           = '0;
        prev_higher_prio    = '1;
        /** outputs reset values */
        o_topi_sugg         = '0;
        o_topi_update       = '0;

        for (int i = 0; i < NR_DOMAINS; i++) begin
            /** Find the the highest pend. and en. intp per domain algorithm */
            for (int j = 1; j < NR_SRC; j++) begin
                /** Check if the interrupt is pending and enabled, active in the domain, 
                    and is also the higher (lower number) priority*/
                if (i_setip_q[j/32][j%32] && i_setie_q[j/32][j%32] &&
                    i_active[i][j/32][j%32] &&
                    (i_target_q[j][IPRIOLEN-1:0] < prev_higher_prio[i][IPRIOLEN-1:0])) begin
                    intp_id[i]          = j[9:0];
                    intp_prio[i]        = i_target_q[j][7:0];
                    prev_higher_prio[i] = intp_prio[i][IPRIOLEN-1:0];
                    idc_index[i]        = i_target_q[j][TARGET_HART_IDX +: NR_IDC_W];
                end
            end

            /** Hart/IDC related logic */
            if (intp_id[i] != '0) begin
                /** Is the interrupt able to contribute to IDC interrupt? */
                if((intp_prio[i][IPRIOLEN-1:0] < i_ithreshold[i][idc_index[i]]) || 
                   (i_ithreshold[i][idc_index[i]] == 0)) begin
                    has_valid_intp[i][idc_index[i]] = 1'b1;
                    o_topi_sugg[i][idc_index[i]]    = {intp_id[i], 8'b0, intp_prio[i]};
                    o_topi_update[i][idc_index[i]]  = 1'b1;
                end
            end
        end 
    end

    /** CPU line logic*/
    for (genvar i = 0; i < NR_DOMAINS; i++) begin
        for (genvar j = 0; j < NR_IDCs; j++) begin
            assign o_Xeip_targets[i][j] =   i_domaincfgIE[i] & i_idelivery[i][j] & 
                                            (has_valid_intp[i][j] | i_iforce[i][j]);
        end
    end

`endif

endmodule