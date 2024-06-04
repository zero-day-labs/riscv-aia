# Advanced Interrupt Architecture IP

## License

This work is licensed under a Apache-2.0 License and Solderpad Hardware License v2.1 (Apache-2.0 WITH SHL-2.1). See the [Apache LICENSE](./LICENSE.Apache) and [Solderpad LICENSE](./LICENSE.Solderpad) files for details.

## Table of Contents

- [About this Project](#about-this-project)
- [Repository Structure](#repository-structure)
- [AIA IP Microarchitecture](#aia-ip-microarchitecture)
   - [About IMSIC IP](#about-imsic-ip)
- [Module Parameters](#module-parameters)
- [Demo](#demo)
- [Tools and versions](#tools-and-versions)
- [Roadmap and Contributions](#roadmap-and-contributions)

## About this Project
This repository contains the SystemVerilog RTL implementation of an RISC-V Advanced Interrupt Architecture, compliant with the [RISC-V AIA Specification v1.0](https://github.com/riscv/riscv-aia).

:warning: **Disclaimer**: The IP is in constant development. We functionally validated the RISC-V AIA IP within a CVA6-based SoC with virtualization support. However, the IP is not formally verified. Thus, it is very likely to have bugs.

## **Repository Structure**

- **Documentation ([doc/](./doc/)):**
In the *doc* folder you can find various diagrams and graphical resources illustrating the internal design of the different components comprising the AIA IP.

- **RTL source files ([rtl/](./rtl/)):**
SystemVerilog source files that implement the IP, organized according to hardware blocks defined for the microarchitecture.

- **Required SV utils ([include/](./rtl/utils/)):**
SystemVerilog utils files required to build the IP.

- **Required SV packages ([packages/](./rtl/packages/)):**
SystemVerilog packages used to build the IP.

- **Cocotb tests ([vendor/](./test/)):**
The *test* folder contains the tests developed using cocotb framework to functionally validate part of the RISC-V AIA IPs' functionalities (APLIC IP, IMSIC IP and AIA IP).

- **Standalone components ([vendor/](./vendor/)):**
The *vendor* folder holds SystemVerilog source files of all standalone RTL modules used in the AIA IP.

## **AIA IP Microarchitecture**
The RISC-V AIA IP developed in this project can, through parameterization/defines, have 3 major microarchitectures, which we call:
- **APLIC IP only** 
Implements the APLIC IP in direct mode.

- **Distibuted AIA IP**
The distributed AIA implements the APLIC IP in MSI mode and the IMSICs are expected to be implemented close to the cores.

- **Emebedded AIA IP**
Embedded AIA IP implements IMSIC IP within APLIC IP in MSI mode. This microarchitecture is especially useful for computing platforms such as embedded and mixed criticality systems.

### **About IMSIC IP**
The IMSIC IP developed in this project can take on 3 microarchitectures depending on its configuration. 

- **Vanilla IMSIC IP**
This IP appears when the IMSIC is configured for 1 hart only.

- **IMSIC Island IP**
If the IMSIC is configured to have several harts, the IMSIC groups them together, organizing them in memory as specified by the specification, and exposing only one communication interface to the bus and several configuration interfaces (as many as the number of IMSICs on the island).

- **Embedded IMSIC IP**
This IP only appears when the AIA is configured as embedded. This IMSIC IP is the IMSIC Island with one more communication interface, used by the APLIC to send pending and enabled interrupts.

## **Module Parameters**
In order to create a modular, scalable and customizable AIA IP, we defined a set of design parameters, as detailed in the Table below. The purpose of these parameters is to configure microarchitectural properties of internal AIA structures. The AIA IP configurations all take place in the file `rtl/package/aia_pkg.sv`

**:warning: Note**: The IMSIC IP configurations in `rtl/package/aia_pkg.sv` are for IMSIC Island or Embedded IMSIC microarchitecture (if AIA is configured as Embedded). If you want to use IMSIC Vanilla, you must place it on the SoC, next to the hart, configured following the structure in `rtl/packages/imsic_pkg.sv` but with only 1 hart. In this case, AIA must be configured as Distributed.

| Parameter | Module| Function | Possible values |
| ------------- | ------------- | ------------- | ------------- |
|***UserAplicMode*** | APLIC | Defines the APLIC opertion mode | DOMAIN_IN_DIRECT_MODE, DOMAIN_IN_MSI_MODE |
|***UserAiaType***   | APLIC |Defines the type of AIA IP that will be instantiated. Ignored the *UserAplicMode* is set to DOMAIN_IN_DIRECT_MODE | AIA_DISTRIBUTED, AIA_EMBEDDED |
|***UserNrSources*** | APLIC | Defines the number of interrupt sources to be implemented in the APLIC IP | [1, 1024] |
|***UserNrHarts***   | APLIC | Defines the number of interrupt harts (IDCs structures) to be implemented in the APLIC IP. Ignored the *UserAplicMode* is set to DOMAIN_IN_MSI_MODE  | [1, N] |
|***UserNrDomains*** | APLIC | Defines the number of interrupt domains to implement. Each domain must be configured individually. The APLIC IP already implements internally a machine mode interrupt domain | [1, N] |
|***UserNrDomainsM*** | APLIC | Defines the number of machine-mode interrupt domains based on the individual configuration | [1, N]  |
|***UserMinPrio*** | APLIC | Defines the minimal interrupt priority | [1 - N] |
| ***id*** | APLIC Domain | Defines the APLIC domain ID | [1 - N] | 
| ***ParentID*** | APLIC Domain | Defines the APLIC domain parent ID. Set it to 0 if the parent is the RootDomain | [0 - N] |
| ***ChildIdx*** | APLIC Domain | Defines an array with all the child interrupt domains of this domain | {0, ...} |
| ***LevelMode*** | APLIC Domain | Defines the interrupt domain level | DOMAIN_IN_M_MODE, DOMAIN_IN_S_MODE  |
| ***Addr*** | APLIC Domain | Defines the interrupt domain base address | 32 bit long value  |
| ***UserXLEN*** | IMSIC | Defines the IMSIC XLEN (dependent on the hart) | 32, 64 |
| ***UserNrSourcesImsic*** | IMSIC |  Defines the number of interrupt sources to be implemented in the IMSIC IP | [64, 2048] |
| ***UserNrHartsImsic*** | IMSIC | Defines the number of interrupt harts (number of IMSICs) to be implemented in the IMSIC island IP | [0 - N] |
| ***UserNrVSIntpFiles*** | IMSIC | Defines the number of VS files to be implemented in each IMSIC | [0 - N] |


## Demo
Comming soon

## Tools and Versions
To run the test make sure you are using the right versions of cocotb and verilator. Currently cocotb only supports Verilator 5.006 and later. See cocotb [Simulator Support](https://docs.cocotb.org/en/stable/simulator_support.html) for more information.

| Package/Tool | Version     |
| ------------ | ----------- |
| Cocotb       | 1.8.0       |
| Verilator    | 5.006       |
| perl         | 5.38.2      |
| python3      | 3.12.3      |
| autoconf     | 2.69        |
| g++          | 13.2.1      |
| flex         | 2.6.4       |
| ccache       | 4.9.1       |
| bison        | 3.8.2       |

---

**:warning: NOTE**

To ensure accurate test reproduction, it is crucial to verify the versions of the tools being utilized (verilator and cocotb). Failure to do so may result in inconsistencies and unreliable test results.

---

## **Roadmap and Contributions**

This AIA IP still has plenty room for growth and improvements. We encourage contributions in many ways (but not limited to):

- Improving the current design. Increasing efficiency, modularity, scalability, etc;
- Identifying errors or bugs in the implementation, by means of formal verification, or through the integration of the IP in other systems;
- Adding support for architectural features included in the RISC-V AIA specification, and not included in this design.