package imsic_protocol_pkg;

    typedef struct packed {
        int AXI_ADDR_WIDTH;
        int AXI_DATA_WIDTH;
        int AXI_ID_WIDTH;
    } protocol_cfg_t;

    localparam protocol_cfg_t DefaultImsicProtocolCfg = '{
        AXI_ADDR_WIDTH: 64,
        AXI_DATA_WIDTH: 64,
        AXI_ID_WIDTH:   4
    };

endpackage