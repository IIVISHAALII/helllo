
################################################################################
# Test Setup          :    ts_conf_ipv6tunn_setup_002                          #
# Test-Setup Version  :    1.2                                                 #
# Component Name      :    NET-O2 ATTEST CONFORMANCE TEST SETUP                #
# Protocol Name       :    IPv6 (INTERNET PROTOCOL Version 6)                  #
#                                                                              #
# Description         :    The following values are to be set at DUT before    #
#                          running the Testcase belonging to this Setup.       #
#                                                                              #
################################################################################
#                                                                              #
# Test Setup & Values :                                                        #
#                                                                              #
#                  TEE                                      DUT                #
#               __________                              __________             #
#  __ __       |  _____   |                            |          |            #
# |     |....--|-|     |  |                            |          |            #
# | RT1 |      | | RT2 |--|----------------------------|          |            #
# |_____|      | |_____|  |           (I1)             |          |            #
#              |          |                            |          |            #
#              |  _____   |                            |          |            #
#              | |     |  |    (to the local 6to4 site)|          |            #
#              | | RT4 |--|----------------------------|   RT3    |            #
#              | |_____|  |           (I2)             |          |            #
#  ------------|---       |                            |          |            #
# |            |  _|___   |                            |          |            #
# |  Native    | |     |  |                            |          |            #
# |  IPv6      | | RT5 |--|----------------------------|          |            #
# |  Cloud     | |_____|  |           (I3)             |          |            #
# |            |___|______|                            |__________|            #
# |                |                                                           #
# |----------------|                        RT1 : 6to4 router                  #
#                                           RT2 : IPv4 router                  #
#                                           RT3 : 6to4 relay router            #
#                                           RT4 : local IPv6 router            #
#                                           RT5 : IPv6 router                  #
#                                                                              #
#                                                                              #
#  Interface Parameters :                                                      #
#  ---------------------------------------------------------------------       #
# | Port Values  |    I1          |        I2           |     I3        |      #
# | -------------|----------------|---------------------|---------------|      #
# | IP Address   |  192.168.7.6   |        ---          |  192.168.8.9  |      #
# | -------------|----------------|---------------------|---------------|      #
# | IPv6 Address |    ---         |  2002:C0A8:706:1::1 |     ---       |      #
# | -------------|----------------|---------------------|---------------|      #
# | Prefix       |    ---         |        64           |     ---       |      #
# |--------------|----------------|---------------------|---------------|      #
# | Mask         | 255.255.255.0  |       ---           | 255.255.255.0 |      #
# |--------------|----------------|---------------------|---------------|      #
#                                                                              #
#                                                                              #
#  Loopback Interface Parameters :                                             #
#  -------------------------------------------                                 #
# | Loopback Port    |        1              |                                 #
# | -----------------|-----------------------|                                 #
# | IP Address       |    192.88.99.1        |                                 #
# | -----------------|-----------------------|                                 #
# | Mask             |    255.255.255.0      |                                 #
# | -----------------|-----------------------|                                 #
#                                                                              #
#  Tunnel Interface Parameters :                                               #
#  -------------------------------------------                                 #
# | Tunnel Port      |        5              |                                 #
# | -----------------|-----------------------|                                 #
# | IPv6 Address     |   2002:C0A8:706::1    |                                 #
# | -----------------|-----------------------|                                 #
# | Prefix           |         64            |                                 #
# | -----------------|-----------------------|                                 #
# | Mode             |    6to4-tunnel        |                                 #
# | -----------------|-----------------------|                                 #
# | Tunnel Source    |     Loopback 2        |                                 #
# | -----------------|-----------------------|                                 #
#                                                                              #
#  Router Parameters :                                                         #
#  ------------------------------------                                        #
# | IPv6 Routing     |    Enabled      |                                       #
# |------------------|-----------------|                                       #
# | IPv6 Forwarding  |    Enabled      |( For Layer 3 Switch )                 #
#  ------------------------------------                                        #
# | IP Routing       |    Enabled      |                                       #
#  ------------------------------------                                        #
#                                                                              #
# Static Route Parameters:                                                     #
#  ---------------------------------------------------------------------       #
# |    Route   |  Destination Prefix  |   Gateway   | Prefix/Mask Length|      #
# | -----------|----------------------|-------------|-------------------|      #
# | IPv6 Route |      ::              |      I2     |         0         |      #
# ----------------------------------------------------------------------       #
#                                                                              #
################################################################################
# ----------------------                                                       #
# Test Setup Procedure :                                                       #
# ----------------------                                                       #
# 1. Enable the DUT interface I1,I3 and assign an IP Address.                  #
#                                                                              #
# 2. Enable the DUT interface I2 and assign an IPv6 Address.                   #
#                                                                              #
# 3. Enable the IPv6 Forwarding on DUT interfaces I2.                          #
#                                                                              #
# 4. Enable the IP & IPv6 Routing on DUT.                                      #
#                                                                              #
# 5. Enable Tunnel Interface with a 6to4 address and assign mode to be used.   #
#                                                                              #
# 6. Assign the Loopback Interface 2 as the Source Adress for the Tunnel       #
#    Interface at DUT.                                                         #
#                                                                              #
# 7. Add static routes for the Default Prefix at the DUT.                      #
#                                                                              #
#                                                                              #
# Note: Remove Ospf parameters from Dut interface after runnig testcase.       #
#                                                                              #
################################################################################
# History       Date     Author         Addition/ Alteration                   #
#                                                                              #
#  1.1        Apr/2006   NET-O2         Initial                                #
#  1.2        Oct/2007   NET-O2         Prefix Length modifed                  #
#                                                                              #
################################################################################
# Copyright (C) 2005 Net-O2 Technologies (P) Ltd.                              #
################################################################################

