// // Copyright (c) 2014-2018 ETH Zurich, University of Bologna
// //
// // Copyright and related rights are licensed under the Solderpad Hardware
// // License, Version 0.51 (the "License"); you may not use this file except in
// // compliance with the License.  You may obtain a copy of the License at
// // http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// // or agreed to in writing, software, hardware and materials distributed under
// // this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// // CONDITIONS OF ANY KIND, either express or implied. See the License for the
// // specific language governing permissions and limitations under the License.
// //
// // Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// //
// // This file defines the interfaces we support.


// /// An AXI4-Lite interface.
// interface AXI_LITE #(
//   parameter AXI_ADDR_WIDTH = -1,
//   parameter AXI_DATA_WIDTH = -1
// );

//   import axi_pkg::*;

//   localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

//   typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
//   typedef logic [AXI_DATA_WIDTH-1:0] data_t;
//   typedef logic [AXI_STRB_WIDTH-1:0] strb_t;

//   // AW channel
//   addr_t aw_addr;
//   logic  aw_valid;
//   logic  aw_ready;

//   data_t w_data;
//   strb_t w_strb;
//   logic  w_valid;
//   logic  w_ready;

//   resp_t b_resp;
//   logic  b_valid;
//   logic  b_ready;

//   addr_t ar_addr;
//   logic  ar_valid;
//   logic  ar_ready;

//   data_t r_data;
//   resp_t r_resp;
//   logic  r_valid;
//   logic  r_ready;

//   modport Master (
//     output aw_addr, aw_valid, input aw_ready,
//     output w_data, w_strb, w_valid, input w_ready,
//     input b_resp, b_valid, output b_ready,
//     output ar_addr, ar_valid, input ar_ready,
//     input r_data, r_resp, r_valid, output r_ready
//   );

// endinterface

package axi_master;

  typedef struct packed {
    axi_pkg::addr_t aw_addr;
    logic  aw_valid;
    logic  aw_ready;

    axi_pkg::data_t w_data;
    axi_pkg::strb_t w_strb;
    logic  w_valid;
    logic  w_ready;

    axi_pkg::resp_t b_resp;
    logic  b_valid;
    logic  b_ready;

    axi_pkg::addr_t ar_addr;
    logic  ar_valid;
    logic  ar_ready;

    axi_pkg::data_t r_data;
    axi_pkg::resp_t r_resp;
    logic  r_valid;
    logic  r_ready;
  } master_t;
endpackage
