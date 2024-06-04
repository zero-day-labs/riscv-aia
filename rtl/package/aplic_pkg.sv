package aplic_pkg;

import aia_pkg::*;
import aplic_domain_pkg::*;

/********************************************************************
*                   APLIC generic params & types                    *
********************************************************************/
    localparam SysNrDomains = UserNrDomains + 1; // Root domain is fixed
    localparam SysNrDomainsM = UserNrDomainsM + 1; // Root domain is fixed
    localparam SysNrDomainsW = (SysNrDomains == 1) ? 1 : $clog2(SysNrDomains);
    localparam UserNrHartsW =  ((UserNrHarts == 0)||(UserNrHarts == 1)) ? 1 : $clog2(UserNrHarts);
    localparam UserNrSourcesW =  (UserNrSources == 1) ? 1 : $clog2(UserNrSources);
    localparam UserMinPrioW =  (UserMinPrio == 1) ? 1 : $clog2(UserMinPrio);
    
    typedef logic [SysNrDomainsW-1:0] intp_domain_t;
    typedef intp_domain_t domain_idx_t;
    typedef logic [31:0] inpt_bitmap_t;
    typedef logic [31:0] aia_bitmap_t;
    typedef logic [31:0] intp_by_num_t;

    localparam RootdomainID = 0;

    /****************************************************************
    *                      APLIC Maximum Values                     *
    ****************************************************************/    
    localparam NrSourcesMax = 1024;
    localparam NrHartsMax   = 16384;
    localparam NrDomainsMax = 3;

/********************************************************************
*                           APLIC Config                            *
********************************************************************/
    localparam DOMAIN_IN_DIRECT_MODE = 0;
    localparam DOMAIN_IN_MSI_MODE = 1;
    
    localparam DOMAIN_IN_M_MODE = 0;
    localparam DOMAIN_IN_S_MODE = 1;

    typedef struct packed {
        logic MinPriority;
    } idc_cfg_t;

    typedef struct packed {
        int                             NrSources;
        int                             NrDomains;
        int                             NrDomainsM;
        int                             NrHarts;
        shortint                        NrSourcesW;
        shortint                        NrDomainsW;
        shortint                        NrHartsW;
        logic                           DeliveryMode; // For now we enforce the same delivery mode in all domains
        domain_cfg_t [SysNrDomains-1:0]DomainsCfg; 
    } aplic_cfg_t;

    /*****************************************************************
    *                 Autofilled Default Configurations              *
    ******************************************************************/
        localparam domain_cfg_t AplicRootDomain = '{
            id: shortint'(RootdomainID),
            ParentID: int'(-1),
            NrChilds: shortint'(1),
            ChildsIdx: '{default: '0, 0:1},
            LevelMode: DOMAIN_IN_M_MODE,
            Addr: 32'hc000000
        };

        localparam aplic_cfg_t DefaultAplicCfg = '{ 
            NrDomains: int'(SysNrDomains),
            NrDomainsW: shortint'(SysNrDomainsW),
            NrDomainsM: int'(SysNrDomainsM),
            NrSources: int'(UserNrSources),
            NrSourcesW: shortint'(UserNrSourcesW),
            NrHarts: int'(UserNrHarts),
            NrHartsW: shortint'(UserNrHartsW),
            DeliveryMode: UserAplicMode,
            DomainsCfg: {   // Domains with Highest IDs first  
                            UserDomainsCfg, 
                            AplicRootDomain 
                        }
        };

/********************************************************************
*                           domainfg                                *
********************************************************************/
    localparam DOMAINCFG_OFF = 'h0000;

    typedef struct packed {
        logic ie;
        logic dm;
        logic be;
    } domaincfg_t;

    localparam DOMAINCFG_RO80_OFF = 24; 
    localparam DOMAINCFG_RO80_LEN = 8; 
    localparam [DOMAINCFG_RO80_LEN-1:0] DOMAINCFG_RO80_VAL = 'h80; 
    localparam DOMAINCFG_IE_OFF = 8; 
    localparam DOMAINCFG_DM_OFF = 2; 
    localparam DOMAINCFG_BE_OFF = 0;

/********************************************************************
*                           sourcecfg                               *
********************************************************************/
    localparam SOURCECFG_OFF = 'h0004;

    typedef enum logic[2:0] {
        APLIC_SM_INACTIVE = 0,
        APLIC_SM_DETACHED = 1,
        APLIC_SM_EDGE1 = 4,
        APLIC_SM_EDGE0 = 5,
        APLIC_SM_LEVEL1 = 6,
        APLIC_SM_LEVEL0 = 7
    } sourcecfg_sm_t;

    typedef enum logic {
        SOURCE_NOT_DELEGATED,
        SOURCE_DELEGATED
    } sourcecfg_d_t;

    typedef struct packed {
        logic d;                // delegate
        union packed{
            logic [9:0] ci;     // child index
            struct packed {
                logic [6:0] reserved; // reserved field to make fields of the same size
                sourcecfg_sm_t sm;  // source mode
            }nd; // not delegated field
        }ddf; // delegate dependent field
    } sourcecfg_t;

    localparam SOURCECFG_D_OFF = 10;
    localparam SOURCECFG_SM_OFF = 0;
    localparam SOURCECFG_SM_LEN = 3;
    localparam SOURCECFG_CI_OFF = 2;
    localparam SOURCECFG_CI_LEN = 9;

    localparam SOURCECFG_NOT_DELEGATED = 0;
    localparam SOURCECFG_DELEGATED = 1;

    function bit is_valid_aplic_sourcecfg_sm(input logic[2:0] value);
        case (value)
            APLIC_SM_INACTIVE,
            APLIC_SM_DETACHED,
            APLIC_SM_EDGE1,
            APLIC_SM_EDGE0,
            APLIC_SM_LEVEL1,
            APLIC_SM_LEVEL0: is_valid_aplic_sourcecfg_sm = 1;
            default: is_valid_aplic_sourcecfg_sm = 0;
        endcase
    endfunction

    function automatic bit domain_is_parent(input int parent_candidate, input int parent_idx);
        if (parent_idx == parent_candidate) begin
            domain_is_parent = 1;
        end else begin
            domain_is_parent = 0;
        end
    endfunction

/********************************************************************
*                           mmsiaddrcfg                            *
********************************************************************/
    localparam MMSIADDRCFG_OFF  = 'h0001BC0;
    localparam MMSIADDRCFGH_OFF = 'h0001BC4;
    localparam SMSIADDRCFG_OFF  = 'h0001BC8;
    localparam SMSIADDRCFGH_OFF = 'h0001BCC;

/********************************************************************
*                               setip                               *
********************************************************************/
    typedef inpt_bitmap_t setip_t;
    typedef inpt_bitmap_t clrip_t;
    typedef intp_by_num_t setipnum_t;
    typedef intp_by_num_t clripnum_t;

    localparam SETIP_OFF = 'h0001C00;
    localparam SETIPNUM_OFF = 'h0001CDC;
    localparam INCLRIP_OFF = 'h0001D00;
    localparam CLRIPNUM_OFF = 'h0001DDC;

/********************************************************************
*                               setie                               *
********************************************************************/
    typedef inpt_bitmap_t setie_t;
    typedef inpt_bitmap_t clrie_t;
    typedef intp_by_num_t setienum_t;
    typedef intp_by_num_t clrienum_t;

    localparam SETIe_OFF = 'h0001E00;
    localparam SETIENUM_OFF = 'h0001EDC;
    localparam CLRIE_OFF = 'h0001F00;
    localparam CLRIENUM_OFF = 'h0001FDC;

/********************************************************************
*                             setipnum_l/be                         *
********************************************************************/
    typedef intp_by_num_t setipnum_le_t;
    typedef intp_by_num_t setipnum_be_t;

    localparam SETIPNUM_LE_OFF = 'h0002000;
    localparam SETIPNUM_BE_OFF = 'h0002004;

/********************************************************************
*                             genmsi                                *
********************************************************************/
    typedef logic [13:0] hart_index_t;
    typedef logic [10:0] eiid_t;

    localparam GENMSI_OFF = 'h0003000;

    typedef struct packed {
        hart_index_t hi;
        logic        busy;
        eiid_t       eiid;
    } genmsi_t;

    localparam GENMSI_HI_OFF = 18;
    localparam GENMSI_HI_LEN = 14;
    localparam GENMSI_BUSY_OFF = 12;
    localparam GENMSI_EIID_OFF = 0;
    localparam GENMSI_EIID_LEN = 11;

/********************************************************************
*                             target                                *
********************************************************************/
    localparam TARGET_OFF = 'h0003004;
    localparam TARGERT_DEF_IPRIO = 8'h1;

    typedef logic [7:0] prio_t;

    typedef struct packed{
        eiid_t eiid; // external interrupt id 
        logic [5:0]  gi; // guest index 
    } target_msi_field_t;

    typedef struct packed {
        hart_index_t hi;        // hart index
        union packed{
            target_msi_field_t mf; // msi field
            struct packed {
                logic [8:0] reserved; // reserved field to make fields of the same size
                prio_t iprio;     // interrupt priority // In the future we should change to [UserminPrioW-1:0] 
            }df; // direct field
        }dmdf; // delivery mode (domaincfg) dependent field
    } target_t;

    localparam TARGET_HI_OFF = 18;
    localparam TARGET_HI_LEN = 14;
    localparam TARGET_IPRIO_OFF = 0;
    localparam TARGET_IPRIO_LEN = 8;
    localparam TARGET_GI_OFF = 12;
    localparam TARGET_GI_LEN = 6;
    localparam TARGET_EIID_OFF = 0;
    localparam TARGET_EIID_LEN = 11;
    localparam TARGET_GUEST_IDX_MASK = 32'h3F000;

/********************************************************************
*                             idc                                   *
********************************************************************/
    localparam IDC_IDELIVERY    = 'h00;
    localparam IDC_IFORCE       = 'h04;
    localparam IDC_ITHRESHOLD   = 'h08;
    localparam IDC_TOPI         = 'h18;
    localparam IDC_CLAIMI       = 'h1C;

    typedef logic       idelivery_t;
    typedef logic       iforce_t;
    typedef logic [9:0] iid_t;
    typedef prio_t      ithreshold_t; // In the future we should change to [UserminPrioW-1:0]

    localparam ITRHESHOLD_LEN = 8;
    
    typedef struct packed {
        iid_t       iid; // interrupt identity
        prio_t      prio; // interrupt priority // In the future we should change to [UserminPrioW-1:0] 
    } claimi_t;

    localparam CLAIMI_IID_OFF = 16;
    localparam CLAIMI_IID_LEN = 10;
    localparam CLAIMI_PRIO_OFF = 0;
    localparam CLAIMI_PRIO_LEN = 8; // In the future we should change to = UserminPrioW 

endpackage