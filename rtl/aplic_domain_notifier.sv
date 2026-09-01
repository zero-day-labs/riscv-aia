/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module aplic_domain_notifier 
import aplic_pkg::*;
import imsic_pkg::*;
import imsic_protocol_pkg::*;
#(
    parameter aplic_cfg_t          AplicCfg                = DefaultAplicCfg,
    parameter imsic_cfg_t          ImsicCfg                = DefaultImsicCfg,
    parameter protocol_cfg_t       ProtocolCfg             = DefaultImsicProtocolCfg,
    parameter type                 axi_req_t               = ariane_axi::req_t ,
    parameter type                 axi_resp_t              = ariane_axi::resp_t,
    // DO NOT EDIT BY PARAMETER
    parameter int                  NR_REG                  = (AplicCfg.NrSources-1)/32,
    parameter int                  IMSICS_LEN              = (ImsicCfg.NrHarts == 1) ? 1 : $clog2(ImsicCfg.NrHarts)
) (
    input   logic                                              i_clk,
    input   logic                                              ni_rst,
    input   logic                                              i_domaincfgIE [AplicCfg.NrDomains-1:0],
    input   setip_t [NR_REG:0]                                 i_setip_q,
    input   setie_t [NR_REG:0]                                 i_setie_q,
    input   target_t [AplicCfg.NrSources-1:1]                  i_target_q,
    input   intp_domain_t [AplicCfg.NrSources-1:1]             i_intp_domain,
    `ifdef MSI_MODE
    output  logic                                              o_forwarded_valid,
    output  eiid_t                                             o_intp_forwd_id,
    input   genmsi_t                                           i_genmsi [AplicCfg.NrDomains-1:0],
    output  logic                                              o_genmsi_sent [AplicCfg.NrDomains-1:0],
    `ifdef AIA_EMBEDDED
    /** IMSIC island CSR interface */
    input  csr_channel_to_imsic_t [ImsicCfg.NrHarts-1:0]       i_imsic_csr, 
    output csr_channel_from_imsic_t [ImsicCfg.NrHarts-1:0]     o_imsic_csr,
    /** IMSIC island AXI interface*/
    input   axi_req_t                                          i_imsic_req,
    output  axi_resp_t                                         o_imsic_resp
    `elsif AIA_DISTRIBUTED
    output  axi_req_t                                          o_msi_req,
    input   axi_resp_t                                         i_msi_rsp
    `endif
    `elsif DIRECT_MODE
    // should this be a struct?
    input  idelivery_t  [AplicCfg.NrHarts-1:0]   i_idelivery   [AplicCfg.NrDomains-1:0],
    input  iforce_t     [AplicCfg.NrHarts-1:0]   i_iforce      [AplicCfg.NrDomains-1:0],
    input  ithreshold_t [AplicCfg.NrHarts-1:0]   i_ithreshold  [AplicCfg.NrDomains-1:0],
    output claimi_t     [AplicCfg.NrHarts-1:0]   o_topi_sugg   [AplicCfg.NrDomains-1:0],
    output logic        [AplicCfg.NrHarts-1:0]   o_topi_update [AplicCfg.NrDomains-1:0],
    output logic        [AplicCfg.NrHarts-1:0]   o_eintp_cpu   [AplicCfg.NrDomains-1:0]
    `endif
);

    `ifdef MSI_MODE
        `ifdef AIA_EMBEDDED
            aplic_imsic_channel_t       aplic_imsic_channel;
            eiid_t                      forwarded_intp_id;
            logic                       forwarded_valid;
            logic  genmsi_sent [AplicCfg.NrDomains-1:0];

            always_comb begin : find_pen_en_intp
                forwarded_intp_id   = '0;
                forwarded_valid     = '0;
                for (int i = 0; i < AplicCfg.NrDomains; i++) begin
                    genmsi_sent[i]  = '0;
                end
                aplic_imsic_channel.setipnum      = '0;    
                aplic_imsic_channel.select_file   = '0;           
                aplic_imsic_channel.imsic_en            = '0;

                for (int i = 1 ; i < AplicCfg.NrSources ; i++) begin
                    if (i_setip_q[i/32][i%32] && i_setie_q[i/32][i%32] && 
                        i_domaincfgIE[i_intp_domain[i]]) begin
                        aplic_imsic_channel.setipnum      = i_target_q[i].dmdf.mf.eiid[ImsicCfg.NrSourcesW-1:0];
                        /** if intp belongs to M domain i_intp_domain = 0, else = 1. + guest index*/
                        aplic_imsic_channel.select_file   = (i_intp_domain[i] == 0) ? 0 : 1 + i_target_q[i].dmdf.mf.gi[0+:ImsicCfg.NrInptFilesW];
                        aplic_imsic_channel.imsic_en      = (1'b1 << i_target_q[i].hi[0+:IMSICS_LEN]);
                        forwarded_intp_id   = i[10:0];
                        forwarded_valid     = 1'b1;
                    end
                end
            end

            assign o_genmsi_sent        = genmsi_sent;
            assign o_forwarded_valid    = forwarded_valid;
            assign o_intp_forwd_id      = forwarded_intp_id;

            imsic_top #(
                .ImsicCfg               ( ImsicCfg              ),
                .ProtocolCfg            ( ProtocolCfg           ),             
                .axi_req_t              ( axi_req_t             ),
                .axi_resp_t             ( axi_resp_t            )
            ) i_imsic_top (
                .i_clk                  ( i_clk                 ),
                .ni_rst                 ( ni_rst                ),
                .i_req                  ( i_imsic_req           ),
                .o_resp                 ( o_imsic_resp          ),
                .csr_channel_i          ( i_imsic_csr           ),
                .csr_channel_o          ( o_imsic_csr           ),
                .aplic_imsic_channel_i  ( aplic_imsic_channel   )  
            );
        `elsif AIA_DISTRIBUTED
            // signals from AXI 4 Lite
            logic [ProtocolCfg.AXI_ADDR_WIDTH-1:0] addr_d, addr_q;
            logic [ProtocolCfg.AXI_DATA_WIDTH-1:0] data_d, data_q;

            logic                      axi_busy, axi_busy_q;
            eiid_t                     intp_forwd_id_d, intp_forwd_id_q;
            logic                      ready_i;
            logic                      forwarded_valid;
            logic genmsi_sent [AplicCfg.NrDomains-1:0];
            logic [ProtocolCfg.AXI_ADDR_WIDTH-1:0] base_addr_target;
            logic [ProtocolCfg.AXI_ADDR_WIDTH-1:0] hart_addr_offset;

            always_comb begin : find_pen_en_intp
                ready_i             = '0;
                intp_forwd_id_d     = intp_forwd_id_q;
                forwarded_valid     = '0;
                for (int i = 0; i < AplicCfg.NrDomains; i++) begin
                    genmsi_sent[i]  = '0;
                end
                data_d              = data_q;
                addr_d              = addr_q;
                base_addr_target    = '0;
                hart_addr_offset    = '0;

                for (int i = 1 ; i < AplicCfg.NrSources ; i++) begin
                    /** If the interrupt is pending and enabled in its domain*/
                    if (i_setip_q[i/32][i%32] && i_setie_q[i/32][i%32] && i_domaincfgIE[i_intp_domain[i]] && !axi_busy_q) begin
                        /** Save the APLIC interrupt ID, so we can clear it in register controller*/
                        intp_forwd_id_d = eiid_t'(i);
                        /** Get the IMSIC interrut ID of the APLIC interrupt ID we want to send to IMSIC*/
                        data_d          = ProtocolCfg.AXI_DATA_WIDTH'(i_target_q[i].dmdf.mf.eiid);

                        /** Compute the destiny address */
                        /** We will support the msi address computation suggested in the specification soon */
                        base_addr_target = (AplicCfg.DomainsCfg[i_intp_domain[i]].LevelMode == DOMAIN_IN_M_MODE) ? 
                                            ProtocolCfg.AXI_ADDR_WIDTH'(ImsicCfg.InptFilesMAddr) : 
                                            ProtocolCfg.AXI_ADDR_WIDTH'(ImsicCfg.InptFilesSAddr);
                        hart_addr_offset = (AplicCfg.DomainsCfg[i_intp_domain[i]].LevelMode == DOMAIN_IN_M_MODE) ?
                                            ProtocolCfg.AXI_ADDR_WIDTH'(i_target_q[i].hi) :
                                            (ProtocolCfg.AXI_ADDR_WIDTH'(i_target_q[i].hi) * 
                                            (ProtocolCfg.AXI_ADDR_WIDTH'(ImsicCfg.NrVSInptFiles) + 'h1)) + 
                                            ProtocolCfg.AXI_ADDR_WIDTH'(i_target_q[i].dmdf.mf.gi);
                        
                        addr_d          = base_addr_target + (hart_addr_offset << 12); 
                        ready_i         = 1'b1;
                        forwarded_valid = 1'b1;
                    end
                end

                // /** Lastly, check if genmsi wants to send a MSI*/
                    // for (int i = 0; i < AplicCfg.NrDomains; i++) begin
                    //     if (i_genmsi[i].busy && !axi_busy_q) begin
                    //         intp_forwd_id_d = '0;
                    //         data_d          = ProtocolCfg.AXI_DATA_WIDTH'(i_genmsi[i].eiid);
                    //         base_addr_target= (!i_intp_domain[i]) ? IMSIC_M_ADDR_TARGET : 
                    //         IMSIC_S_ADDR_TARGET  + ({{AXI_ADDR_WIDTH-32{1'b0}}, i_target_q[data_d[31:0]]} & TARGET_GUEST_IDX_MASK);
                    //         hart_addr_offset= (!i_intp_domain[i]) ? {{AXI_ADDR_WIDTH-14{1'b0}}, i_target_q[data_d[31:0]][31:18]} * 'h1000 : 
                    //                         {{AXI_ADDR_WIDTH-14{1'b0}}, i_target_q[data_d[31:0]][31:18]} * 'h1000 * (NR_VS_FILES_PER_IMSIC + 'h1);
                    //         addr_d          = base_addr_target + hart_addr_offset; 
                    //         genmsi_sent[i]  = 1'b1;
                    //         ready_i         = 1'b1;
                    //     end
                    // end
            end

            assign o_genmsi_sent        = genmsi_sent;
            assign o_forwarded_valid    = forwarded_valid;
            assign o_intp_forwd_id      = intp_forwd_id_q;

            // -----------------------------
            // AXI Interface
            // -----------------------------
            axi4_lite_write_master #(
                .AXI_ADDR_WIDTH ( ProtocolCfg.AXI_ADDR_WIDTH    ),
                .AXI_DATA_WIDTH ( ProtocolCfg.AXI_DATA_WIDTH    ),
                .axi_req_t      ( axi_req_t                     ),
                .axi_resp_t     ( axi_resp_t                    )
            ) axi_lite_write_master_i (
                .clk_i          ( i_clk                         ),
                .rst_ni         ( ni_rst                        ),
                .ready_i        ( ready_i                       ),
                .addr_i         ( addr_d                        ),
                .data_i         ( data_d                        ),
                .busy_o         ( axi_busy                      ),
                .req_o          ( o_msi_req                     ),
                .resp_i         ( i_msi_rsp                     )
            );

            always_ff @( posedge i_clk, negedge ni_rst ) begin
                if (!ni_rst) begin
                    axi_busy_q      <= '0;
                    intp_forwd_id_q <= '0;
                    data_q          <= '0;
                    addr_q          <= '0;
                end else begin
                    axi_busy_q      <= axi_busy;
                    intp_forwd_id_q <= intp_forwd_id_d;
                    data_q          <= data_d;
                    addr_q          <= addr_d;
                end
            end
        `endif
    `elsif DIRECT_MODE

        typedef struct packed {
            logic  valid;
            prio_t prio;
            iid_t  iid;
        } topi_candidate_t;

        localparam int unsigned NR_TOPI_CANDIDATES = AplicCfg.NrSources - 1;
        localparam int unsigned TOPI_TREE_LEVELS = (NR_TOPI_CANDIDATES <= 1) ? 0 : $clog2(NR_TOPI_CANDIDATES);

        // Round the number of interrupt sources up to a power of two.
        localparam int unsigned TOPI_TREE_LEAVES = 1 << TOPI_TREE_LEVELS;

        /*
         * Tree representation:
         *
         *                  [1]
         *              /         \
         *            [2]         [3]
         *           /   \       /   \
         *         ...   ...   ...   ...
         *
         * Internal nodes:
         *     1 .. TOPI_TREE_LEAVES-1
         *
         * Leaf nodes:
         *     TOPI_TREE_LEAVES .. 2*TOPI_TREE_LEAVES-1
         *
         * Index zero is not used.
         */
        topi_candidate_t topi_tree [AplicCfg.NrDomains-1:0] [AplicCfg.NrHarts-1:0] [2*TOPI_TREE_LEAVES-1:1];

        logic [AplicCfg.NrHarts-1:0]    has_valid_intp  [AplicCfg.NrDomains-1:0];
        logic [AplicCfg.NrHarts-1:0]    eintp_cpu_q     [AplicCfg.NrDomains-1:0];

        /*
         * Select the higher-priority candidate.
         *
         * A lower numerical iprio value means a higher interrupt
         * priority.
         *
         * When priorities are equal, lhs is selected. Because the tree
         * is built with lower interrupt IDs on the left, this preserves
         * the original lower-interrupt-ID tie-breaking behavior without
         * requiring an additional IID comparator.
         */
        function automatic topi_candidate_t select_topi_candidate(
            input topi_candidate_t lhs, input topi_candidate_t rhs
        );
            begin
                if (!lhs.valid) begin
                    select_topi_candidate = rhs;
                end else if (!rhs.valid) begin
                    select_topi_candidate = lhs;
                end else if (rhs.prio < lhs.prio) begin
                    select_topi_candidate = rhs;
                end else begin
                    select_topi_candidate = lhs;
                end
            end
        endfunction

        /*
         * Construct one candidate at every real leaf.
         *
         * Leaf zero represents interrupt source 1, leaf one represents
         * source 2, and so on. Consequently, the left side of every
         * subtree always contains lower interrupt IDs.
         */
        for (genvar d = 0; d < AplicCfg.NrDomains; d++) begin : gen_topi_domain
            for (genvar h = 0; h < AplicCfg.NrHarts; h++) begin : gen_topi_hart
                for (genvar l = 0; l < TOPI_TREE_LEAVES; l++) begin : gen_topi_leaf

                    if (l < NR_TOPI_CANDIDATES) begin
                        localparam int unsigned SOURCE_ID = l + 1;

                        assign topi_tree [d][h][TOPI_TREE_LEAVES + l].valid =
                                i_setip_q[SOURCE_ID/32][SOURCE_ID%32] && i_setie_q[SOURCE_ID/32][SOURCE_ID%32] &&
                                (i_intp_domain[SOURCE_ID] == intp_domain_t'(d)) &&
                                (i_target_q[SOURCE_ID].hi == hart_index_t'(h));
                        assign topi_tree [d][h][TOPI_TREE_LEAVES + l].prio =
                                i_target_q[SOURCE_ID].dmdf.df.iprio;
                        assign topi_tree[d][h][TOPI_TREE_LEAVES + l].iid = iid_t'(SOURCE_ID);

                    end else begin : gen_padding_leaf
                        /*
                         * Pad the tree to a power of two. Invalid leaves
                         * can never beat a valid candidate.
                         */
                        assign topi_tree [d][h][TOPI_TREE_LEAVES + l] = '0;
                    end
                end

                /*
                 * Build the balanced reduction tree.
                 *
                 * Each node depends only on two children at the next
                 * level, giving logarithmic rather than linear depth.
                 */
                for (genvar n = 1; n < TOPI_TREE_LEAVES; n++) begin : gen_topi_node

                    assign topi_tree [d][h][n] = select_topi_candidate(
                                topi_tree[d][h][2*n],
                                topi_tree[d][h][2*n + 1]);
                end
            end
        end

        /*
         * The root of each domain/hart tree is node 1.
         * Apply the threshold after selecting the best candidate.
         */
        always_comb begin : topi_output_logic
            for (int d = 0; d < AplicCfg.NrDomains; d++) begin

                o_topi_sugg[d]   = '0;
                o_topi_update[d] = '0;
                has_valid_intp[d] = '0;

                for (int h = 0; h < AplicCfg.NrHarts; h++) begin

                    if (topi_tree[d][h][1].valid &&
                        ((i_ithreshold[d][h] == '0) || 
                         (topi_tree[d][h][1].prio < i_ithreshold[d][h]))) begin

                        o_topi_sugg[d][h].iid = topi_tree[d][h][1].iid;
                        o_topi_sugg[d][h].prio = topi_tree[d][h][1].prio;
                        o_topi_update[d][h] = 1'b1;
                        has_valid_intp[d][h] = 1'b1;
                    end
                end
            end
        end

        /** CPU line logic*/
        for (genvar i = 0; i < AplicCfg.NrDomains; i++) begin
            for (genvar j = 0; j < AplicCfg.NrHarts; j++) begin
                assign o_eintp_cpu[i][j] =  eintp_cpu_q[i][j];
            end
        end

        always_ff @( posedge i_clk or negedge ni_rst ) begin
            if (!ni_rst) begin
                for (int unsigned i = 0; i < AplicCfg.NrDomains; i++) begin
                    for (int unsigned j = 0; j < AplicCfg.NrHarts; j++) begin
                        eintp_cpu_q[i][j] <=  1'b0;
                    end
                end
            end
            else begin
                for (int unsigned i = 0; i < AplicCfg.NrDomains; i++) begin
                    for (int unsigned j = 0; j < AplicCfg.NrHarts; j++) begin
                        eintp_cpu_q[i][j] <=  (i_domaincfgIE[i] & i_idelivery[i][j] & 
                                                (has_valid_intp[i][j] | i_iforce[i][j]));
                    end
                end
            end
        end
    `endif

endmodule