/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/
 
module imsic_regmap 
import imsic_protocol_pkg::*;
import imsic_pkg::*;
#(
    parameter imsic_cfg_t    ImsicCfg       =   DefaultImsicCfg,
    parameter protocol_cfg_t ProtocolCfg    =   DefaultImsicProtocolCfg,
    parameter type           axi_req_t      =   ariane_axi::req_t,
    parameter type           axi_resp_t     =   ariane_axi::resp_t   
) (
    input  logic                                i_clk,
    input  logic                                ni_rst,
    input  imsic_ipnum_t [ImsicCfg.NrHarts-1:0] i_setipnum,
    output imsic_ipnum_t [ImsicCfg.NrHarts-1:0] o_setipnum,
    output imsic_ipfile_t[ImsicCfg.NrHarts-1:0] o_setipnum_we,
    // Bus Interface
    input  axi_req_t                            i_req,
    output axi_resp_t                           o_resp            
);

    logic [31:0]   register_address;
    logic [31:0]   imsic_index;
    logic [31:0]   file_index;

    /********************************************************************
    *                      AXI Protocol Converter                       *
    ********************************************************************/
    logic                                               en;
    logic                                               we;
    logic [7:0]                                         be;
    logic [ProtocolCfg.AXI_ADDR_WIDTH-1:0]  address;
    logic [ProtocolCfg.AXI_DATA_WIDTH-1:0]  wdata;
    logic [ProtocolCfg.AXI_DATA_WIDTH-1:0]  rdata;

    axi_lite_interface #(
        .AXI_ADDR_WIDTH ( ProtocolCfg.AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( ProtocolCfg.AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( ProtocolCfg.AXI_ID_WIDTH   ),
        .axi_req_t      ( axi_req_t                              ),
        .axi_resp_t     ( axi_resp_t                             )
    ) axi_lite_interface_i (
        .clk_i          ( i_clk      ),
        .rst_ni         ( ni_rst     ),
        .axi_req_i      ( i_req      ),
        .axi_resp_o     ( o_resp     ),
        .address_o      ( address    ),
        .en_o           ( en         ),
        .we_o           ( we         ),
        .be_o           ( be         ),
        .data_i         ( rdata      ),
        .data_o         ( wdata      )
    );

    /********************************************************************
    *                      IMSIC Register Update                        *
    ********************************************************************/
    assign register_address = address[31:0];
    always_comb begin
        o_setipnum                  = '0;
        o_setipnum_we               = '0;
        imsic_index                 = '0;
        file_index                  = '0;

        if (en && we) begin
            unique case (register_address) inside
                [ImsicCfg.InptFilesMAddr : ImsicCfg.InptFilesMAddr + ((ImsicCfg.NrHarts-1)*'h1000)]: begin
                    o_setipnum[register_address[12 +: ImsicCfg.NrHartsW]][0][ImsicCfg.NrSourcesW-1:0] = wdata[ImsicCfg.NrSourcesW-1:0];
                    o_setipnum_we[register_address[12 +: ImsicCfg.NrHartsW]][0] = 1'b1;
                end

                [ImsicCfg.InptFilesSAddr : (ImsicCfg.InptFilesSAddr + 
                            ((ImsicCfg.NrHarts*(ImsicCfg.NrInptFiles-1))*'h1000) - 4)]: begin
                    imsic_index = 32'(register_address[12 +: UserNrSFileGroup])/(ImsicCfg.NrInptFiles-1); 
                    file_index = (32'(register_address[12 +: UserNrSFileGroup])%(ImsicCfg.NrInptFiles-1))+1; 

                    o_setipnum[imsic_index][file_index][ImsicCfg.NrSourcesW-1:0] = wdata[ImsicCfg.NrSourcesW-1:0];
                    o_setipnum_we[imsic_index][file_index] = 1'b1;
                end            
                default:;
            endcase
        end
    end

    /** Reads are not allowed in IMSIC */
    assign rdata = 'b0;
    
endmodule
