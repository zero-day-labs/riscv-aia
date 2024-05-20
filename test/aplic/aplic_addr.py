

APLIC_M_BASE    = 0xc000000
APLIC_S_BASE    = 0xd000000

NR_SRC          = 32
NR_DOMAINS      = 2
NR_HART         = 2
MIN_PRIO        = 6



M_MODE = 0
S_MODE = 1

# Sourcecfg base macro
SOURCECFG_M_BASE        = APLIC_M_BASE + 0x0004
SOURCECFG_S_BASE        = APLIC_S_BASE + 0x0004
DELEGATE_SRC            = 0x400
INACTIVE                = 0
DETACHED                = 1
EDGE1                   = 4
EDGE0                   = 5
LEVEL1                  = 6
LEVEL0                  = 7
sourcecfg_SM = [DELEGATE_SRC, INACTIVE, DETACHED, EDGE1, EDGE0, LEVEL1, LEVEL0]

# Target base macros
TARGET_M_BASE           = APLIC_M_BASE + 0x3004
TARGET_S_BASE           = APLIC_S_BASE + 0x3004
TARGET_OFF              = 0x0004

# Pending base macros
SETIPNUM_M_BASE         = APLIC_M_BASE + 0x1CDC
SETIPNUM_S_BASE         = APLIC_S_BASE + 0x1CDC
CLRIPNUM_M_BASE         = APLIC_M_BASE + 0x1DDC
CLRIPNUM_S_BASE         = APLIC_S_BASE + 0x1DDC
SETIP_M_BASE            = APLIC_M_BASE + 0x1C00
SETIP_S_BASE            = APLIC_S_BASE + 0x1C00
INCLRIP_M_BASE          = APLIC_M_BASE + 0x1D00
INCLRIP_S_BASE          = APLIC_S_BASE + 0x1D00

# Enable base macros
SETIENUM_M_BASE         = APLIC_M_BASE + 0x1EDC
SETIENUM_S_BASE         = APLIC_S_BASE + 0x1EDC
CLRIENUM_M_BASE         = APLIC_M_BASE + 0x1FDC
CLRIENUM_S_BASE         = APLIC_S_BASE + 0x1FDC
SETIE_M_BASE            = APLIC_M_BASE + 0x1E00
SETIE_S_BASE            = APLIC_S_BASE + 0x1E00
CLRIE_M_BASE            = APLIC_M_BASE + 0x1F00
CLRIE_S_BASE            = APLIC_S_BASE + 0x1F00

# IDC macros
IDELIVERY_M_BASE        = APLIC_M_BASE + 0x4000 + 0x00
IDELIVERY_S_BASE        = APLIC_S_BASE + 0x4000 + 0x00
IFORCE_M_BASE           = APLIC_M_BASE + 0x4000 + 0x04
IFORCE_S_BASE           = APLIC_S_BASE + 0x4000 + 0x04
ITHRESHOLD_M_BASE       = APLIC_M_BASE + 0x4000 + 0x08
ITHRESHOLD_S_BASE       = APLIC_S_BASE + 0x4000 + 0x08
CLAIMI_M_BASE           = APLIC_M_BASE + 0x4000 + 0x1C
CLAIMI_S_BASE           = APLIC_S_BASE + 0x4000 + 0x1C

IDELIVERY   = 0x00
IFORCE      = 0x04
ITHRESHOLD  = 0x08
CLAIMI      = 0x1c

def sourcecfg (intp=0, domain=M_MODE):
    if (intp == 0):
        ValueError("Interrupt must be greater than 0")
    
    if (domain == M_MODE):
        return SOURCECFG_M_BASE + (0x4*(intp-1))
    else:
        return SOURCECFG_S_BASE + (0x4*(intp-1))

def target (intp=0, domain=M_MODE):
    if (intp == 0):
        ValueError("Interrupt must be greater than 0")
    
    if (domain == M_MODE):
        return TARGET_M_BASE + (0x4*(intp-1))
    else:
        return TARGET_S_BASE + (0x4*(intp-1))
    
def idc (hart = 0, reg = IDELIVERY, domain=M_MODE):
    if (domain == M_MODE):
        APLIC_BASE = APLIC_M_BASE
    else:
        APLIC_BASE = APLIC_S_BASE

    return reg + 0x4000 + APLIC_BASE + (hart*0x20)