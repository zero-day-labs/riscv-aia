module aplic_imsic_top_wrapper #(
    parameter int                           NR_SRC          = 32,
    parameter int                           MIN_PRIO        = 6 ,
    parameter int                           NR_IDCs         = 1 ,
    parameter int                           NR_INTP_FILES   = 3 ,
    parameter int unsigned                  AXI_ADDR_WIDTH  = 64,
    parameter int unsigned                  AXI_DATA_WIDTH  = 64,
    parameter int unsigned                  AXI_ID_WIDTH    = 4 ,
    //
    parameter int                           VS_INTP_FILE_LEN = $clog2(NR_INTP_FILES-2),
    parameter int                           NR_SRC_LEN       = $clog2(NR_SRC)
   
) (
    input  logic                            i_clk,
    input  logic                            ni_rst,
    /**========================== IMSIC ==============================*/     
    /** Register config: CRSs interface From/To interrupt files */
    input  logic [1:0]                      i_priv_lvl,
    input  logic [VS_INTP_FILE_LEN:0]       i_vgein,
    input  logic [32-1:0]                   i_imsic_addr,
    input  logic [32-1:0]                   i_imsic_data,
    input  logic                            i_imsic_we,
    input  logic                            i_imsic_claim,
    output logic [32-1:0]                   o_imsic_data,
    output logic [NR_SRC_LEN-1:0]           o_mtopei,
    output logic [NR_SRC_LEN-1:0]           o_stopei,
    output logic                            o_imsic_exception,
    /**===============================================================*/
    /** Register config: AXI interface From/To system bus for domain*/
    input   logic [31:0]                    reg_intf_req_a32_d32_addr_1,
    input   logic                           reg_intf_req_a32_d32_write_1,
    input   logic [31:0]                    reg_intf_req_a32_d32_wdata_1,
    input   logic [3:0]                     reg_intf_req_a32_d32_wstrb_1,
    input   logic                           reg_intf_req_a32_d32_valid_1,
    output  logic [31:0]                    reg_intf_resp_d32_rdata_1,
    output  logic                           reg_intf_resp_d32_error_1,
    output  logic                           reg_intf_resp_d32_ready_1,
    input   logic [NR_SRC-1:0]              i_irq_sources,
`ifdef DIRECT_MODE
    output  logic [(NR_IDCs*2)-1:0]         o_Xeip_targets
`elsif MSI_MODE
    output  logic [NR_INTP_FILES-1:0]       o_Xeip_targets
`endif
);

logic [NR_INTP_FILES-1:0][NR_SRC_LEN-1:0]   xtopei;

assign o_mtopei = xtopei[0];
assign o_stopei = xtopei[1];

reg_intf::reg_intf_req_a32_d32              i_req_1;
reg_intf::reg_intf_resp_d32                 o_resp_1;
logic [(NR_IDCs*2)-1:0]                     Xeip_targets_o;
ariane_axi::req_t                           master_req;          
ariane_axi::resp_t                          master_resp;

assign i_req_1.addr   = reg_intf_req_a32_d32_addr_1;
assign i_req_1.write  = reg_intf_req_a32_d32_write_1;
assign i_req_1.wdata  = reg_intf_req_a32_d32_wdata_1;
assign i_req_1.wstrb  = reg_intf_req_a32_d32_wstrb_1;
assign i_req_1.valid  = reg_intf_req_a32_d32_valid_1;

assign reg_intf_resp_d32_rdata_1 = o_resp_1.rdata;
assign reg_intf_resp_d32_error_1 = o_resp_1.error;
assign reg_intf_resp_d32_ready_1 = o_resp_1.ready;

`ifdef DIRECT_MODE

    aplic_top #(
        .NR_SRC(NR_SRC),
        .MIN_PRIO(MIN_PRIO),
        .NR_IDCs(NR_IDCs)
    ) i_aplic_top (
        .i_clk(i_clk),
        .ni_rst(ni_rst),
        .i_req_1(i_req_1),
        .o_resp_1(o_resp_1),
        .i_req_2(i_req_2),
        .o_resp_2(o_resp_2),
        .i_irq_sources(i_irq_sources),
        .o_Xeip_targets(o_Xeip_targets)
    );

`elsif MSI_MODE

    aplic_top #(
        .NR_SRC(NR_SRC),
        .MIN_PRIO(MIN_PRIO),
        .NR_IDCs(NR_IDCs)
    ) i_aplic_top (
        .i_clk(i_clk),
        .ni_rst(ni_rst),
        // .i_req_1(i_req_1),
        // .o_resp_1(o_resp_1),
        // .i_req_2(i_req_2),
        // .o_resp_2(o_resp_2),
        .i_req_cfg(i_req_1),
        .o_resp_cfg(o_resp_1),
        .i_irq_sources(i_irq_sources),
        .o_req(master_req),
        .i_resp(master_resp)
    );

    imsic_top #(
        .NR_SRC             ( NR_SRC            ),
        .MIN_PRIO           ( MIN_PRIO          ),
        .NR_INTP_FILES      ( NR_INTP_FILES     )
    ) i_imsic_top (
        .i_clk              ( i_clk             ),
        .ni_rst             ( ni_rst            ),
        .i_req              ( master_req        ),
        .o_resp             ( master_resp       ),
        .i_priv_lvl         ( i_priv_lvl        ),
        .i_vgein            ( i_vgein           ),
        .i_imsic_addr       ( i_imsic_addr      ),
        .i_imsic_data       ( i_imsic_data      ),
        .i_imsic_we         ( i_imsic_we        ),
        .i_imsic_claim      ( i_imsic_claim     ),
        .o_imsic_data       ( o_imsic_data      ),
        .o_xtopei           ( xtopei            ),
        .o_Xeip_targets     ( o_Xeip_targets    ),
        .o_imsic_exception  ( o_imsic_exception )
    );

`endif

endmodule