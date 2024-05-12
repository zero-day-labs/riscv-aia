/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/
 
module imsic_regmap #(
    parameter int                         NR_SRC_LEN                =   32,
    parameter int unsigned                IMSIC_M_BASE_ADDR         =   32'h24000000,
    parameter int unsigned                IMSIC_S_BASE_ADDR         =   32'h28000000,
    parameter int unsigned                AXI_ADDR_WIDTH            =   64,
    parameter int unsigned                AXI_DATA_WIDTH            =   64,
    parameter int unsigned                AXI_ID_WIDTH              =   10,
    parameter int unsigned                NR_IMSICS                 =   1,
    parameter int unsigned                NR_VS_FILES_PER_IMSIC     =   0,
    // Do not overwrite this
    parameter int unsigned                NR_INTP_FILES             =   2 + NR_VS_FILES_PER_IMSIC,
    parameter type                        axi_req_t                 =   ariane_axi::req_t,
    parameter type                        axi_resp_t                =   ariane_axi::resp_t   
) (
    input  logic                                                        i_clk            ,
    input  logic                                                        ni_rst           ,
    input  logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]     i_setipnum       ,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]     o_setipnum       ,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                     o_setipnum_we    ,
    output logic [NR_IMSICS-1:0][NR_INTP_FILES-1:0]                     o_setipnum_re    ,
    // Bus Interface
    input  axi_req_t                                                    i_req            ,
    output axi_resp_t                                                   o_resp            
);
    // signals from AXI 4 Lite
    logic [AXI_ADDR_WIDTH-1:0]            address;
    logic                                 en;
    logic                                 we;
    logic [7:0]                           be;
    logic [AXI_DATA_WIDTH-1:0]            wdata;
    logic [AXI_DATA_WIDTH-1:0]            rdata;

    logic [31:0]                          register_address;
    logic [31:0]                          imsic_index;
    logic [31:0]                          file_index;
    assign register_address               = address[31:0];

    // -----------------------------
    // AXI Interface Logic
    // -----------------------------
    axi_lite_interface #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH   ),
        .axi_req_t      ( axi_req_t      ),
        .axi_resp_t     ( axi_resp_t     )
    ) axi_lite_interface_i (
        .clk_i      ( i_clk      ),
        .rst_ni     ( ni_rst     ),
        .axi_req_i  ( i_req      ),
        .axi_resp_o ( o_resp     ),
        .address_o  ( address    ),
        .en_o       ( en         ),
        .we_o       ( we         ),
        .be_o       ( be         ),
        .data_i     ( rdata      ),
        .data_o     ( wdata      )
    );

    // -----------------------------
    // Register Update Logic
    // -----------------------------
    /** Process a write request */
    always_comb begin
        o_setipnum                  = '0;
        o_setipnum_we               = '0;
        imsic_index                 = '0;
        file_index                  = '0;

        if (en && we) begin
            unique case (register_address) inside
                [IMSIC_M_BASE_ADDR : IMSIC_M_BASE_ADDR + ((NR_IMSICS-1)*'h1000)]: begin
                    // 13:12 because for now we support a max of 4 IMSICs
                    o_setipnum[register_address[13:12]][0][NR_SRC_LEN-1:0]  = wdata[NR_SRC_LEN-1:0];
                    o_setipnum_we[register_address[13:12]][0]               = 1'b1;
                end

                [IMSIC_S_BASE_ADDR : (IMSIC_S_BASE_ADDR + 
                            ((NR_IMSICS*(NR_INTP_FILES-1))*'h1000) - 4)]: begin
                    // 14:12 because for now we support a max of 4 IMSICs w/ 
                    // 1 VS-file -> (4-1)*2(S+VS) = 7 -> 111
                    imsic_index = {{32-3{1'b0}}, register_address[14:12]}/(NR_INTP_FILES-1); 
                    file_index = ({{32-3{1'b0}}, register_address[14:12]}%(NR_INTP_FILES-1))+1; 

                    o_setipnum[imsic_index][file_index][NR_SRC_LEN-1:0]  
                                                        = wdata[NR_SRC_LEN-1:0];

                    o_setipnum_we[imsic_index][file_index] = 1'b1;
                end            
                default:;
            endcase
        end
    end

    /** Process a read request */
    assign rdata = 'b0;
    assign o_setipnum_re = '0;
    
endmodule
