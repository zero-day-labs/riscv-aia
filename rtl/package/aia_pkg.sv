package aia_pkg;

    import aplic_domain_pkg::*;

    localparam DOMAIN_IN_DIRECT_MODE = 0;
    localparam DOMAIN_IN_MSI_MODE = 1;

    localparam DOMAIN_IN_M_MODE = 0;
    localparam DOMAIN_IN_S_MODE = 1;

    localparam AIA_DISTRIBUTED = 0;
    localparam AIA_EMBEDDED = 1;

///////////////////////////////////////////////////////////////////
// User must edit the AIA Default Config using this parameters  
///////////////////////////////////////////////////////////////////
    localparam UserAiaType   = AIA_EMBEDDED;
///////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////
// User must edit the APLIC Default Config using this parameters  
///////////////////////////////////////////////////////////////////
//                          !Warning!
// The configuration of domains (quantity, parent rules, and level) 
// provided by the user is not validated!
// Ensure these configurations are done carefully in accordance with
// the specification.
// Note that we will soon be developing an application with a 
// graphical interface to generate AIA IPs, which will automatically
// populate the aia_pkg file.  
///////////////////////////////////////////////////////////////////
    localparam UserNrSources = 256;
    localparam UserNrHarts   = 5;
    localparam UserNrDomains = 1;  
    localparam UserNrDomainsM = 0; 
    localparam UserMinPrio   = 6;
    localparam UserAplicMode = DOMAIN_IN_MSI_MODE;

    localparam domain_cfg_t AplicDomainS_0 = '{
        id: shortint'(1),
        ParentID: int'(0),
        NrChilds: shortint'(0),
        ChildsIdx: '{default: '0},
        LevelMode: DOMAIN_IN_S_MODE,
        Addr: 32'hd000000
    };

    localparam domain_cfg_t [UserNrDomains-1:0] UserDomainsCfg = '{
        // Domains with Highest IDs first
        AplicDomainS_0
    };

///////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////
// User must edit the IMSIC Default Config using this parameters  
///////////////////////////////////////////////////////////////////
    localparam UserXLEN           = 64;
    localparam UserNrSourcesImsic = 256;
    localparam UserNrHartsImsic   = 5;
    localparam UserNrVSIntpFiles  = 1;
///////////////////////////////////////////////////////////////////

endpackage