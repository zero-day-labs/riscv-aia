/** 
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*/

module synchronizer_multi_level #(
    parameter DataW     = 32,
    parameter NrLevels  = 2
) (
    input  logic                i_clk,
    input  logic                ni_rst,
    input  logic [DataW-1:0]    data_i,
    output logic [DataW-1:0]    data_o
);

    logic [NrLevels-1:0][DataW-1:0] sync_data;

    always_ff @( posedge i_clk or negedge ni_rst) begin
        if(!ni_rst)begin
            sync_data <= '0;
        end else begin
            if (NrLevels != 1) begin
                sync_data[0] <= data_i;
                for (int i = 1; i < NrLevels; i++) begin
                    sync_data[i] <= sync_data[i-1];
                end
            end
        end
    end

    assign data_o = sync_data[NrLevels-1];

endmodule