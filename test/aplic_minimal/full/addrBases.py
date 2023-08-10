# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

class CaddrBases():
    def domainBase(idcBase):
        return idcBase + 0x0000

    def sourcecfgBase(idcBase):
        return idcBase + 0x0004

    def mmsiaddrcfgBase(idcBase):
        return idcBase + 0x1BC0

    def mmsiaddrcfghBase(idcBase):
        return idcBase + 0x1BC4

    def smsiaddrcfgBase(idcBase):
        return idcBase + 0x1BC8

    def smsiaddrcfghBase(idcBase):
        return idcBase + 0x1BCC

    def setipBase(idcBase):
        return idcBase + 0x1C00

    def setipnumBase(idcBase):
        return idcBase + 0x1CDC

    def in_clripBase(idcBase):
        return idcBase + 0x1D00

    def clripnumBase(idcBase):
        return idcBase + 0x1DDC

    def setieBase(idcBase):
        return idcBase + 0x1E00

    def setienumBase(idcBase):
        return idcBase + 0x1EDC

    def clrieBase(idcBase):
        return idcBase + 0x1F00

    def clrienumBase(idcBase):
        return idcBase + 0x1FDC

    def setipnum_leBase(idcBase):
        return idcBase + 0x2000

    def setipnum_beBase(idcBase):
        return idcBase + 0x2004

    def genmsiBase(idcBase):
        return idcBase + 0x3000

    def targetBase(idcBase):
        return idcBase + 0x3004


    def ideliveryBase(idcBase):
        return idcBase + 0x4000 + 0x00

    def iforceBase(idcBase):
        return idcBase + 0x4000 + 0x04

    def ithresholdBase(idcBase):
        return idcBase + 0x4000 + 0x08

    def topiBase(idcBase):
        return idcBase + 0x4000 + 0x18

    def claimiBase(idcBase):
        return idcBase + 0x4000 + 0x1C