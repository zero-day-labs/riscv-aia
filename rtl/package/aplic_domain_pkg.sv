package aplic_domain_pkg;

localparam NrChildsMax  = 2;

/********************************************************************
*                        APLIC Domain Config                        *
********************************************************************/
    typedef struct packed {
        shortint                        id;
        int                             ParentID;
        shortint                        NrChilds;
        logic [NrChildsMax-1:0][9:0]    ChildsIdx;
        logic                           LevelMode;
        logic [31:0]                    Addr;
    } domain_cfg_t;

endpackage