def axi_write_reg(dut, addr, data):
    dut.reg_intf_req_a32_d32_addr.value = addr
    dut.reg_intf_req_a32_d32_wdata.value = data
    dut.reg_intf_req_a32_d32_write.value = 1
    dut.reg_intf_req_a32_d32_wstrb.value = 0
    dut.reg_intf_req_a32_d32_valid.value = 1 

def axi_stop (dut):
    dut.reg_intf_req_a32_d32_valid.value = 0
    
def axi_read_reg(dut, addr):
    dut.reg_intf_req_a32_d32_addr.value = addr
    dut.reg_intf_req_a32_d32_write.value = 0
    dut.reg_intf_req_a32_d32_valid.value = 1 

    return dut.reg_intf_resp_d32_rdata.value 