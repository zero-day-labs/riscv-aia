package imsic_pkg;

import aia_pkg::*;

/********************************************************************
*                   IMSIC generic params & types                    *
********************************************************************/
    localparam M_FILE     = 0;
    localparam S_FILE     = 1;
    localparam VS_FILE    = 2;

    localparam UserNrSourcesImsicW  = (UserNrSourcesImsic == 1) ? 1 : $clog2(UserNrSourcesImsic);
    localparam UserNrHartsImsicW  = (UserNrHartsImsic == 1) ? 1 : $clog2(UserNrHartsImsic);
    localparam UserNrVSInptFilesW   = $clog2(UserNrVSIntpFiles);
    localparam UserNrInptFiles      = UserNrVSIntpFiles+2;
    localparam UserNrInptFilesW     = $clog2(UserNrInptFiles);
    localparam UserNrSFileGroup     = (UserNrHartsImsic * (UserNrVSIntpFiles+1)) - 1;
    localparam UserNrSFileGroupW    = $clog2(UserNrSFileGroup);

    localparam NR_REG = (UserNrSourcesImsic < 32) ? 1 : UserNrSourcesImsic/32;

    typedef logic [UserNrInptFiles-1:0][UserNrSourcesImsicW-1:0] imsic_ipnum_t;
    typedef logic [(UserNrInptFiles*NR_REG)-1:0][31:0]           imsic_bitmap_reg_t;
    typedef logic [UserNrInptFiles-1:0]                          imsic_ipfile_t;
    typedef logic [UserXLEN-1:0]                                 imsic_data_t;
    typedef logic [UserNrVSInptFilesW:0]                         imsic_vgein_t;

    /*****************************************************************
    *         CSR Channel (RISCV Hart <==csr_channel==> IMSIC)       *
    ******************************************************************/
    typedef struct packed {
        logic [1:0]     priv_lvl;
        imsic_vgein_t   vgein;
        logic [31:0]    imsic_addr;
        imsic_data_t    imsic_data;
        logic           imsic_we;
        logic           imsic_claim;
    } csr_channel_to_imsic_t;

    typedef struct packed {
        imsic_data_t    imsic_data;
        imsic_ipnum_t   xtopei;
        imsic_ipfile_t  Xeip_targets;
        logic           imsic_exception;
    } csr_channel_from_imsic_t;

    /*****************************************************************
    *         APLIC Channel (APLIC <==aplic_channel==> IMSIC)        *
    *           (Only applicable With IMSIC in Embedded Mode)        *
    ******************************************************************/
    typedef struct packed {
        logic [UserNrSourcesImsicW-1:0] setipnum;
        logic [UserNrHartsImsic-1:0]    imsic_en;
        logic [UserNrInptFilesW-1:0]    select_file;
    } aplic_imsic_channel_t;


    localparam PRIV_LVL_M = 2'b11;
    localparam PRIV_LVL_HS = 2'b10;
    localparam PRIV_LVL_S = 2'b01;
    localparam PRIV_LVL_U = 2'b00;

    localparam EIDELIVERY_OFF  = 'h70;
    localparam EITHRESHOLD_OFF = 'h72;
    localparam EIP0_OFF        = 'h80;
    localparam EIP63_OFF       = 'hBF;
    localparam EIE0_OFF        = 'hC0;
    localparam EIE63_OFF       = 'hFF;

/********************************************************************
*                           IMSIC Config                            *
********************************************************************/
    typedef struct packed {
        int          XLEN;
        int          NrHarts;
        shortint     NrHartsW;
        int          NrSources;
        shortint     NrSourcesW;
        int          NrVSInptFiles;
        int          NrSourcesPerReg;
        shortint     NrVSInptFilesW;
        int          NrInptFiles;
        shortint     NrInptFilesW;
        logic [31:0] InptFilesMAddr;
        logic [31:0] InptFilesSAddr;
    } imsic_cfg_t;

    /*****************************************************************
    *                 Autofilled Default Configurations              *
    ******************************************************************/
        localparam imsic_cfg_t DefaultImsicCfg = '{
            XLEN:           int'(UserXLEN),
            NrHarts:        int'(UserNrHartsImsic),
            NrHartsW:       shortint'(UserNrHartsImsicW),
            NrSources:      int'(UserNrSourcesImsic),
            NrSourcesW:     shortint'(UserNrSourcesImsicW),
            NrVSInptFiles:  int'(UserNrVSIntpFiles),
            NrVSInptFilesW: shortint'(UserNrVSInptFilesW),
            NrSourcesPerReg:int'(32),
            NrInptFiles:    int'(UserNrInptFiles),
            NrInptFilesW:   shortint'(UserNrInptFilesW),
            InptFilesMAddr: 32'h24000000,
            InptFilesSAddr: 32'h28000000
        };

endpackage