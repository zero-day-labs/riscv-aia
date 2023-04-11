
module imsic_top_wrapper #(
    parameter int                           NR_SRC          = 30,
    parameter int                           MIN_PRIO        = 6 ,
    parameter int                           NR_INTP_FILES   = 2 ,
    parameter int unsigned                  AXI_ADDR_WIDTH  = 64,
    parameter int unsigned                  AXI_DATA_WIDTH  = 64,
    parameter int unsigned                  AXI_ID_WIDTH    = 4 ,
    //
    parameter int                           VS_INTP_FILE_LEN = $clog2(NR_INTP_FILES-2),
    parameter int                           NR_SRC_LEN       = $clog2(NR_SRC)
) (
    input  logic                            i_clk,
    input  logic                            ni_rst,
    /** Register config: AXI interface From/To system bus */
    input logic                             ready_i    ,
    input logic [AXI_ADDR_WIDTH-1:0]        addr_i     ,
    input logic [AXI_DATA_WIDTH-1:0]        data_i     ,     
    /** Register config: CRSs interface From/To interrupt files */
    input  logic [1:0]                      i_priv_lvl,
    input  logic [VS_INTP_FILE_LEN:0]       i_vgein,
    input  logic [32-1:0]                   i_imsic_addr,
    input  logic [32-1:0]                   i_imsic_data,
    input  logic                            i_imsic_we,
    input  logic                            i_imsic_claim,
    output logic [32-1:0]                   o_imsic_data,
    output logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]   o_xtopei,
    output logic [NR_INTP_FILES-1:0]        o_Xeip_targets,
    output logic                            o_imsic_exception
);

ariane_axi::req_t                           req;
ariane_axi::resp_t                          resp;

axi_lite_master_write_only#(
    .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH    ),
    .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH    )
) axi_lite_master_write_only_i (
    .clk_i              ( i_clk             ),
    .rst_ni             ( ni_rst            ),
    .ready_i            ( ready_i           ),
    .id_i               ( '0                ),
    .busy_o             (                   ),
    .addr_i             ( addr_i            ),
    .data_i             ( data_i            ),
    .req_o              ( req               ),
    .resp_i             ( resp              )
);

imsic_top #(
    .NR_SRC             ( NR_SRC            ),
    .MIN_PRIO           ( MIN_PRIO          ),
    .NR_INTP_FILES      ( NR_INTP_FILES     )
) i_imsic_top (
    .i_clk              ( i_clk             ),
    .ni_rst             ( ni_rst            ),
    .i_req              ( req               ),
    .o_resp             ( resp              ),
    .i_priv_lvl         ( i_priv_lvl        ),
    .i_vgein            ( i_vgein           ),
    .i_imsic_addr       ( i_imsic_addr      ),
    .i_imsic_data       ( i_imsic_data      ),
    .i_imsic_we         ( i_imsic_we        ),
    .i_imsic_claim      ( i_imsic_claim     ),
    .o_imsic_data       ( o_imsic_data      ),
    .o_xtopei           ( o_xtopei          ),
    .o_Xeip_targets     ( o_Xeip_targets    ),
    .o_imsic_exception  ( o_imsic_exception )
);

endmodule