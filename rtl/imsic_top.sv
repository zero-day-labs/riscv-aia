/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module imsic_island_top 
import imsic_protocol_pkg::*;
import imsic_pkg::*;
#(
   parameter imsic_cfg_t          ImsicCfg         = DefaultImsicCfg,
   parameter protocol_cfg_t       ProtocolCfg      = DefaultImsicProtocolCfg,
   parameter type                 axi_req_t        = ariane_axi::req_t ,
   parameter type                 axi_resp_t       = ariane_axi::resp_t,
   // DO NOT EDIT BY PARAMETER
   parameter int unsigned         NR_INTP_FILES    = 2 + ImsicCfg.NrVSInptFiles,
   parameter int                  NR_INTP_PER_REG  = ImsicCfg.NrSourcesPerReg,
   parameter int                  NR_REG           = imsic_pkg::NR_REG,
   parameter int                  NR_SRC_LEN       = $clog2(ImsicCfg.NrSources)
) (
   input  logic                                                 i_clk,
   input  logic                                                 ni_rst,
   /** AXI interface */
   input  axi_req_t                                             i_req,
   output axi_resp_t                                            o_resp,
   /** CSR interface*/
   input  csr_channel_to_imsic_t     [ImsicCfg.NrHarts-1:0]     csr_channel_i, 
   output csr_channel_from_imsic_t   [ImsicCfg.NrHarts-1:0]     csr_channel_o 
   `ifdef AIA_EMBEDDED
   /** APLIC interface */
   ,input aplic_imsic_channel_t                                 aplic_imsic_channel_i 
   `endif
);

    logic [ImsicCfg.NrHarts-1:0][ImsicCfg.NrInptFilesW-1:0] select_intp_file_i;
    /** Interrupt files registers */
    imsic_ipfile_t     [ImsicCfg.NrHarts-1:0] eidelivery_d, eidelivery_q;
    imsic_ipfile_t     [ImsicCfg.NrHarts-1:0] xeip_targets;
    imsic_ipnum_t      [ImsicCfg.NrHarts-1:0] eithreshold_d, eithreshold_q;
    imsic_ipnum_t      [ImsicCfg.NrHarts-1:0] xtopei;
    imsic_bitmap_reg_t [ImsicCfg.NrHarts-1:0] eip_d, eip_q;
    imsic_bitmap_reg_t [ImsicCfg.NrHarts-1:0] eie_d, eie_q;

    logic [ImsicCfg.NrHarts-1:0][31:0] target_register;
    logic [ImsicCfg.NrHarts-1:0][31:0] target_intp;

// ======================= CONTROL LOGIC ==========================
    for (genvar i = 0; i < ImsicCfg.NrHarts; i++) begin
        always_comb begin
            case (csr_channel_i[i].priv_lvl)
                PRIV_LVL_M: select_intp_file_i[i]  = M_FILE;
                PRIV_LVL_S: select_intp_file_i[i]  = S_FILE + csr_channel_i[i].vgein;
                default: select_intp_file_i[i]     = '0;
            endcase
        end
    end
// ================================================================

// ======================== REGISTER MAP ==========================
    
    imsic_ipfile_t [ImsicCfg.NrHarts-1:0] setipnum_we;
    imsic_ipnum_t  [ImsicCfg.NrHarts-1:0] setipnum;

    imsic_regmap #(
        .ImsicCfg       ( ImsicCfg              ),
        .ProtocolCfg    ( ProtocolCfg           ),
        .axi_req_t      ( axi_req_t             ),
        .axi_resp_t     ( axi_resp_t            )
    ) imsic_regmap_i (
        .i_clk          ( i_clk                 ),
        .ni_rst         ( ni_rst                ),
        .i_setipnum     ( '0                    ),
        .o_setipnum     ( setipnum              ),
        .o_setipnum_we  ( setipnum_we           ),
        .i_req          ( i_req                 ),
        .o_resp         ( o_resp                )
    );
// ================================================================

// ================== SELECT REG IN INTP FILE =====================
    logic [ImsicCfg.NrHarts-1:0][NR_INTP_FILES-1:0][31:0] aux;
    for (genvar i = 0; i < ImsicCfg.NrHarts; i++) begin
        
        always_comb begin
            /** reset val */
            csr_channel_o[i].imsic_data        = '0;
            csr_channel_o[i].imsic_exception   = '0;
            eidelivery_d[i]        = eidelivery_q[i];
            eithreshold_d[i]       = eithreshold_q[i];
            eip_d[i]               = eip_q[i];
            eie_d[i]               = eie_q[i];
            target_register[i]     = '0;
            target_intp[i]         = '0;
            aux[i]                 = '0;

            /** CSRs channel handler */
            if (csr_channel_i[i].imsic_we) begin
                case (csr_channel_i[i].imsic_addr) inside
                    EIDELIVERY_OFF: begin
                        eidelivery_d[i][select_intp_file_i[i]] = csr_channel_i[i].imsic_data[0];
                    end
                    EITHRESHOLD_OFF:begin
                        eithreshold_d[i][select_intp_file_i[i]] = csr_channel_i[i].imsic_data[NR_SRC_LEN-1:0];
                    end
                    [EIP0_OFF:EIP63_OFF]:begin
                        if((csr_channel_i[i].imsic_addr-EIP0_OFF) <= NR_REG-1) begin
                            eip_d[i][(csr_channel_i[i].imsic_addr-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)] = csr_channel_i[i].imsic_data[31:0];
                            if (ImsicCfg.XLEN == 64) begin
                                eip_d[i][(csr_channel_i[i].imsic_addr-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)+1] = csr_channel_i[i].imsic_data[63:32];
                            end
                        end
                    end
                    [EIE0_OFF:EIE63_OFF]:begin
                        if((csr_channel_i[i].imsic_addr-EIE0_OFF) <= NR_REG-1) begin
                            eie_d[i][(csr_channel_i[i].imsic_addr-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)] = csr_channel_i[i].imsic_data[31:0];
                            if (ImsicCfg.XLEN == 64) begin
                                eie_d[i][(csr_channel_i[i].imsic_addr-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)+1] = csr_channel_i[i].imsic_data[63:32];
                            end
                        end
                    end
                    default: csr_channel_o[i].imsic_exception = 1'b1;
                endcase
            end

            case (csr_channel_i[i].imsic_addr) inside
                EIDELIVERY_OFF: begin
                    csr_channel_o[i].imsic_data = {{ImsicCfg.XLEN-1{1'b0}}, eidelivery_q[i][select_intp_file_i[i]]};
                end
                EITHRESHOLD_OFF:begin
                    csr_channel_o[i].imsic_data = {{ImsicCfg.XLEN-NR_SRC_LEN{1'b0}}, eithreshold_q[i][select_intp_file_i[i]]};
                end
                [EIP0_OFF:EIP63_OFF]:begin
                    if((csr_channel_i[i].imsic_addr-EIP0_OFF) <= NR_REG-1) begin
                        csr_channel_o[i].imsic_data[31:0] = eip_q[i][(csr_channel_i[i].imsic_addr-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)];
                        if (ImsicCfg.XLEN == 64) begin
                            csr_channel_o[i].imsic_data[63:32] = eip_q[i][(csr_channel_i[i].imsic_addr-EIP0_OFF)+(select_intp_file_i[i]*NR_REG)+1];
                        end
                    end
                end
                [EIE0_OFF:EIE63_OFF]:begin
                    if((csr_channel_i[i].imsic_addr-EIE0_OFF) <= NR_REG-1) begin
                        csr_channel_o[i].imsic_data[31:0] = eie_q[i][(csr_channel_i[i].imsic_addr-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)];
                        if (ImsicCfg.XLEN == 64) begin
                            csr_channel_o[i].imsic_data[63:32] = eie_q[i][(csr_channel_i[i].imsic_addr-EIE0_OFF)+(select_intp_file_i[i]*NR_REG)+1];
                        end
                    end
                end
                default: csr_channel_o[i].imsic_exception = 1'b1;
            endcase

            /** AXI channel handler */
            for (int k = 0; k < NR_INTP_FILES; k++) begin
                aux[i][k] = {{32-NR_SRC_LEN{1'b0}}, setipnum[i][k]};
                if (setipnum_we[i][k] && (aux[i][k] <= ImsicCfg.NrSources)) begin
                    eip_d[i][(aux[i][k]/32)+(k*NR_REG)][aux[i][k]%32] = 1'b1;
                end 
            end

            `ifdef AIA_EMBEDDED
            /** APLIC channel handler */
            if (aplic_imsic_channel_i.imsic_en[i] == 1'b1) begin
                target_register[i] = {{32-NR_SRC_LEN{1'b0}}, aplic_imsic_channel_i.setipnum}/32;
                target_intp[i]     = {{32-NR_SRC_LEN{1'b0}}, aplic_imsic_channel_i.setipnum}%32;
                eip_d[i][target_register[i]+(aplic_imsic_channel_i.select_file*NR_REG)]
                        [target_intp[i]] = 1'b1;
            end
            `endif

            /** If a core is claiming the intp, unpend it */
            if (csr_channel_i[i].imsic_claim) begin
                eip_d[i][({{32-NR_SRC_LEN{1'b0}}, xtopei[i][select_intp_file_i[i]]}/32)+(select_intp_file_i[i]*NR_REG)]
                    [{{32-NR_SRC_LEN{1'b0}}, xtopei[i][select_intp_file_i[i]]}%32] = 1'b0;
            end

            /** Intp 0 is always 0 for pend and enable */
            for (int j = 0; j < NR_INTP_FILES; j++) begin
                eip_d[i][j*NR_REG][0] = 1'b0;
                eie_d[i][j*NR_REG][0] = 1'b0;
            end
        end
    end
    
// ================================================================

// ========================= NOTIFIER =============================
    /** For each interrupt file look for the highest pending and 
        enable interrupt 
        w - imsic index
        k - interrupt file;
        i - register number;
        j - interrupt number in i; 
        
        k*NR_REG - select the interrupt file */
    logic [ImsicCfg.NrHarts-1:0][NR_INTP_FILES-1:0][31:0] acc; 
    for (genvar w = 0; w < ImsicCfg.NrHarts; w++) begin
        for (genvar k = 0; k < NR_INTP_FILES; k++) begin
            always_comb begin
                /** reset val */
                xtopei[w][k]           = '0;
                xeip_targets[w][k]     = '0;
                acc[w][k]              = '0;
                for (int i = 0; i < NR_REG; i++) begin
                    for (int j = 0; j < NR_INTP_PER_REG; j++) begin
                        if ((eie_q[w][(k*NR_REG)+i][j] && eip_q[w][(k*NR_REG)+i][j]) &&
                            ((eithreshold_q[w][k] == 0) || (j[NR_SRC_LEN-1:0] < eithreshold_q[w][k]))) begin
                            acc[w][k]              = i*NR_INTP_PER_REG;
                            xtopei[w][k]           = j[NR_SRC_LEN-1:0] + acc[w][k][NR_SRC_LEN-1:0];
                            /** If delivery is enable for this intp file, notify the hart */
                            if (eidelivery_q[w][k]) begin
                                xeip_targets[w][k] = 1'b1;
                            end
                            break;
                        end
                    end
                end
            end
        end
    end
    
// ================================================================

// ======================= ASSIGN VALUES ==========================
    for (genvar i = 0; i < ImsicCfg.NrHarts; i++) begin
        assign csr_channel_o[i].xtopei         = xtopei[i];
        assign csr_channel_o[i].Xeip_targets   = xeip_targets[i];
    end
    
    always_ff @( posedge i_clk or negedge ni_rst ) begin
        if (!ni_rst) begin
            eidelivery_q    <= '0;
            eithreshold_q   <= '0;
            eip_q           <= '0;
            eie_q           <= '0;
        end else begin
            eidelivery_q    <= eidelivery_d;
            eithreshold_q   <= eithreshold_d;
            eip_q           <= eip_d;
            eie_q           <= eie_d;
        end
    end
// ================================================================


endmodule