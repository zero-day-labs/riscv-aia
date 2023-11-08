/**
* Copyright 2023 Francisco Marques & Zero-Day Labs, Lda
* SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
* 
* Author: F.Marques <fmarques_00@protonmail.com>
*
* Description: Implements a basic axi4 lite master with write only capabilities
*               
* Notes: This module will be replaced in the future;
*/ 
module axi_lite_write_master #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64
) (
    input logic                      clk_i  ,
    input logic                      rst_ni ,
    input logic                      ready_i,
    output logic                     busy_o ,
    input logic [AXI_ADDR_WIDTH-1:0] addr_i ,
    input logic [AXI_DATA_WIDTH-1:0] data_i ,
    output ariane_axi::req_t         req_o  ,
    input ariane_axi::resp_t         resp_i
);

    typedef enum logic [1:0] {
        IDLE,
        AWAIT_RESPONSE,
        FINISH_TRANSACTION
    } state_t;

    logic [1:0] state;

    always_ff @(posedge clk_i) begin
        if (~rst_ni) begin
            state           <= IDLE;
            req_o.aw.addr   <= '0;
            req_o.aw.prot   <= '0;
            req_o.aw_valid  <= '0;
            req_o.aw.id     <= '0;
            req_o.w.data    <= '0;
            req_o.w.strb    <= '0;
            req_o.w_valid   <= '0;
            req_o.b_ready   <= '0;
            busy_o          <= '0;
            req_o.w.last    <= '0;

        end else begin
            case (state)
                IDLE: begin
                    req_o.aw.addr   <= addr_i;
                    req_o.w.data    <= data_i;
                    if (ready_i) begin
                        busy_o          <= 1'b1;
                        req_o.aw.size   <= 3;
                        req_o.aw.prot   <= '0;
                        req_o.aw_valid  <= '1;
                        req_o.w.strb    <= '1;
                        req_o.w_valid   <= '1;
                        req_o.w.last    <= '1;
                        state           <= AWAIT_RESPONSE;
                    end
                end
                AWAIT_RESPONSE: begin
                    req_o.aw.addr   <= '0;
                    if (resp_i.w_ready) begin
                        req_o.aw_valid  <= '0;
                        busy_o          <= 1'b1; 
                        req_o.w.last    <= '0;
                        req_o.w_valid   <= '0;
                        req_o.aw.prot   <= '0;
                        req_o.w.data    <= '0;
                        req_o.w.strb    <= '0;
                        req_o.b_ready   <= '1;
                        state           <= FINISH_TRANSACTION;
                    end
                end
                FINISH_TRANSACTION: begin
                    state <= IDLE;
                    req_o.b_ready   <= '0;
                    busy_o <= 1'b0;
                end
                default:;
            endcase
        end
    end
endmodule