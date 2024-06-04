//
module ieaia_wrapper 
import imsic_pkg::*;
import imsic_protocol_pkg::*;
import aplic_pkg::*;
#(
    parameter aplic_cfg_t          AplicCfg                = DefaultAplicCfg,
    parameter imsic_cfg_t          ImsicCfg                = DefaultImsicCfg,
    parameter protocol_cfg_t       ProtocolCfg             = DefaultImsicProtocolCfg
) (
    input   logic                                       i_clk                       ,
    input   logic                                       ni_rst                      ,
    input   logic [AplicCfg.NrSources-1:0]              i_sources                   ,
    /** Register config: AXI interface From/To system bus */
    input   logic [31:0]                                reg_intf_req_a32_d32_addr   ,
    input   logic                                       reg_intf_req_a32_d32_write  ,
    input   logic [31:0]                                reg_intf_req_a32_d32_wdata  ,
    input   logic [3:0]                                 reg_intf_req_a32_d32_wstrb  ,
    input   logic                                       reg_intf_req_a32_d32_valid  ,
    output  logic [31:0]                                reg_intf_resp_d32_rdata     ,
    output  logic                                       reg_intf_resp_d32_error     ,
    output  logic                                       reg_intf_resp_d32_ready     ,
    `ifdef MSI_MODE
    /** Signals to generate an AXI MSI transaction */
    input logic                                         i_ready                     ,
    input logic [ProtocolCfg.AXI_ADDR_WIDTH-1:0]        i_addr                      ,
    input logic [ProtocolCfg.AXI_DATA_WIDTH-1:0]        i_data                      ,   
    /** Register config: CRSs interface From/To interrupt files */
    input  logic [ImsicCfg.NrHarts-1:0]                 i_select_imsic              ,
    input  logic [1:0]                                  i_priv_lvl                  ,
    input  imsic_vgein_t                                i_vgein                     ,
    input  logic [31:0]                                 i_imsic_addr                ,
    input  imsic_data_t                                 i_imsic_data                ,
    input  logic                                        i_imsic_we                  ,
    input  logic                                        i_imsic_claim               ,
    output imsic_ipnum_t [ImsicCfg.NrHarts-1:0]         xtopei
    `elsif DIRECT_MODE
    output  logic [AplicCfg.NrHarts-1:0]   o_eintp_cpu  [AplicCfg.NrDomains-1:0]
    `endif
);

    /** APLIC configuration channel */
    reg_intf::reg_intf_req_a32_d32              i_aplic_confg_req;
    reg_intf::reg_intf_resp_d32                 o_aplic_confg_resp;

    assign i_aplic_confg_req.addr  = reg_intf_req_a32_d32_addr;
    assign i_aplic_confg_req.write = reg_intf_req_a32_d32_write;
    assign i_aplic_confg_req.wdata = reg_intf_req_a32_d32_wdata;
    assign i_aplic_confg_req.wstrb = reg_intf_req_a32_d32_wstrb;
    assign i_aplic_confg_req.valid = reg_intf_req_a32_d32_valid;

    assign reg_intf_resp_d32_rdata = o_aplic_confg_resp.rdata;
    assign reg_intf_resp_d32_error = o_aplic_confg_resp.error;
    assign reg_intf_resp_d32_ready = o_aplic_confg_resp.ready;

    `ifdef MSI_MODE
    /** IMSIC island CSRs interface*/
    csr_channel_to_imsic_t   [ImsicCfg.NrHarts-1:0]    in_imsic_csr; 
    csr_channel_from_imsic_t [ImsicCfg.NrHarts-1:0]    out_imsic_csr;
    always_comb begin
        for (int i = 0; i < ImsicCfg.NrHarts; i++) begin
            in_imsic_csr[i] = '0;
            if (i_select_imsic[i] == 1'b1) begin
                in_imsic_csr[i].vgein = i_vgein;
                in_imsic_csr[i].imsic_addr = i_imsic_addr;
                in_imsic_csr[i].imsic_data = i_imsic_data;
                in_imsic_csr[i].imsic_we = i_imsic_we;
                in_imsic_csr[i].imsic_claim = i_imsic_claim;
                in_imsic_csr[i].priv_lvl = i_priv_lvl;
            end
        end
    end

    for (genvar i = 0; i < ImsicCfg.NrHarts; i++) begin
        assign xtopei[i] = out_imsic_csr[i].xtopei;
    end

    /** IMSIC island MSI channel */
    ariane_axi::req_t                           req_msi_plat, req_msi_aplic, req_msi;
    ariane_axi::resp_t                          resp_msi_plat, resp_msi_aplic, resp_msi;
    `ifdef AIA_DISTRIBUTED
    assign req_msi = req_msi_aplic;
    assign resp_msi_aplic = resp_msi;

    imsic_island_top #(
        .ImsicCfg               ( ImsicCfg              ),
        .axi_req_t              ( ariane_axi::req_t     ),
        .axi_resp_t             ( ariane_axi::resp_t    )
    ) i_imsic_top (
        .i_clk                  ( i_clk                 ),
        .ni_rst                 ( ni_rst                ),
        .i_req                  ( req_msi               ),
        .o_resp                 ( resp_msi              ),
        .csr_channel_i          ( in_imsic_csr          ),
        .csr_channel_o          ( out_imsic_csr         )
    );
    `elsif AIA_EMBEDDED
    assign req_msi = req_msi_plat;
    assign resp_msi_plat = resp_msi;
    `endif

    axi_lite_write_master#(
        .AXI_ADDR_WIDTH     ( ProtocolCfg.AXI_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH     ( ProtocolCfg.AXI_DATA_WIDTH    )
    ) axi_lite_write_master_i (
        .clk_i              ( i_clk             ),
        .rst_ni             ( ni_rst            ),
        .ready_i            ( i_ready           ),
        .addr_i             ( i_addr            ),
        .data_i             ( i_data            ),
        `ifdef AIA_DISTRIBUTED
        .busy_o             ( ),
        .req_o              ( ),
        .resp_i             ( )
        `elsif AIA_EMBEDDED
        .busy_o             ( ),
        .req_o              ( req_msi_plat      ),
        .resp_i             ( resp_msi_plat     )
        `endif
    );
    `endif

    aplic_top #(
        .AplicCfg       ( AplicCfg                          ),
        .ImsicCfg       ( ImsicCfg                          ),
        .reg_req_t      ( reg_intf::reg_intf_req_a32_d32    ),
        .reg_rsp_t      ( reg_intf::reg_intf_resp_d32       ),
        .axi_req_t      ( ariane_axi::req_t                 ),
        .axi_resp_t     ( ariane_axi::resp_t                )
    ) aplic_top_minimal_i (
        .i_clk          ( i_clk                             ),
        .ni_rst         ( ni_rst                            ),
        .i_irq_sources  ( i_sources                         ),
        .i_req_cfg      ( i_aplic_confg_req                 ),
        .o_resp_cfg     ( o_aplic_confg_resp                ),
        `ifdef MSI_MODE
        `ifdef AIA_EMBEDDED
        .i_imsic_csr    ( in_imsic_csr                      ),
        .o_imsic_csr    ( out_imsic_csr                     ),         
        .i_imsic_req    ( req_msi                           ),
        .o_imsic_resp   ( resp_msi                          )
        `elsif AIA_DISTRIBUTED
        .o_msi_req      ( req_msi_aplic                     ),
        .i_msi_rsp      ( resp_msi_aplic                    )
        `endif
        `elsif DIRECT_MODE
        .o_eintp_cpu    ( o_eintp_cpu                       )
        `endif
    );

endmodule