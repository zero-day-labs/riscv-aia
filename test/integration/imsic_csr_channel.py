from aia_regmap import M_MODE, S_MODE

def imsic_write_reg(dut, imsic=1, addr=0, data=0, priv_lvl=M_MODE, vgein=0):
    dut.i_select_imsic.value = (1 << (imsic-1))
    dut.i_priv_lvl.value = priv_lvl
    dut.i_vgein.value = vgein
    dut.i_imsic_addr.value = addr
    dut.i_imsic_data.value = data
    dut.i_imsic_claim.value = 0
    dut.i_imsic_we.value = 1

def imsic_stop_write(dut):
    dut.i_imsic_we.value = 0

def imsic_write_xtopei(dut, imsic = 1, priv_lvl=M_MODE, vgein=0):
    dut.i_select_imsic.value = (1 << (imsic-1))
    dut.i_priv_lvl.value = priv_lvl
    dut.i_vgein.value = vgein
    dut.i_imsic_addr.value = 0
    dut.i_imsic_data.value = 0
    dut.i_imsic_claim.value = 1
    dut.i_imsic_we.value = 0

def imsic_read_reg(dut, imsic = 1, addr=0, priv_lvl=M_MODE, vgein=0):
    dut.i_select_imsic.value = (1 << (imsic-1))
    dut.i_priv_lvl.value = priv_lvl
    dut.i_vgein.value = vgein
    dut.i_imsic_addr.value = addr
    dut.i_imsic_data.value = 0
    dut.i_imsic_claim.value = 0
    dut.i_imsic_we.value = 0
