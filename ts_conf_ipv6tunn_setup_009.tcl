
################################################################################
# Test Setup          :    ts_conf_ipv6tunn_setup_009                          #
# Test-Setup Version  :    1.1                                                 #
# Component Name      :    NET-O2 ATTEST CONFORMANCE TEST SETUP                #
# Protocol Name       :    IPv6 (INTERNET PROTOCOL Version 6)                  #
#                                                                              #
# Description         :    The following values are to be set at DUT before    #
#                          running the Testcase belonging to this Setup.       #
#                                                                              #
################################################################################
#                                                                              #
# Test Setup & Values :                                                        #
# -------------------                                                          #
#  _____                                                                       #
# |     |                                                                      #
# | HT1 |                                                                      #
# |_____|          TEE                                      DUT                #
#    |          __________                              __________             #
#  __|__       |  _____   |                            |          |            #
# |     |....--|-|     |  |                            |          |            #
# | ND1 |      | | ND2 |--|----------------------------|          |            #
# |_____|      | |_____|  |           (I1)             |          |            #
#              |          |                            |          |            #
#              |  _____   |                            |          |            #
#              | |     |  |    (to the local 6to4 site)|          |            #
#              | | ND4 |--|----------------------------|   ND3    |            #
#              | |_____|  |           (I2)             |          |            #
#  ------------|---       |                            |          |            #
# |            |  _|___   |                            |          |            #
# |  Native    | |     |  |                            |          |            #
# |  IPv6      | | ND5 |--|----------------------------|          |            #
# |  Cloud     | |_____|  |           (I3)             |          |            #
# |            |___|______|                            |__________|            #
# |                |                                                           #
# |----------------|                        ND1 : 6to4 router                  #
#                                           ND2 : IPv4 router                  #
#                                           ND3 : 6to4 relay router            #
#                                           ND4 : local IPv6 router            #
#                                           ND5 : IPv6 router                  #
#                                                                              #
#                                                                              #
#  Interface Parameters :                                                      #
#  -------------------------------------------------- ---------------------    #
# | Port Values |   I1         |         I2          |       I3            |   #
# | ------------|--------------|---------------------|---------------------|   #
# | IP Address  | 192.168.7.6  |         ---         |       ---           |   #
# | ------------|--------------|---------------------|---------------------|   #
# | IPv6 Address|   ---        |  2002:C0A8:706:1::1 |5ffe:ffff:0:f101::3  |   #
# | ------------|--------------|---------------------|---------------------|   #
# | Prefix      |   ---        |         ---         |       64            |   #
# |-------------|--------------|---------------------|---------------------|   #
# | Mask        |255.255.255.0 |         64          |      ---            |   #
# |-------------|--------------|---------------------|---------------------|   #
#                                                                              #
#                                                                              #
#  Loopback Interface Parameters :                                             #
#  -------------------------------------------                                 #
# | Loopback Port    |        2              |                                 #
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
# | Mode             |     6to4-tunnel       |                                 #
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
# | IPv6 Route |      ::              |      I3     |         0         |      #
# ----------------------------------------------------------------------       #
#                                                                              #
################################################################################
# ----------------------                                                       #
# Test Setup Procedure :                                                       #
# ----------------------                                                       #
# 1. Enable the DUT interface I1 and assign an IP Address.                     #
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
################################################################################
# History       Date     Author         Addition/ Alteration                   #
#                                                                              #
#  1.1        Apr/2006   NET-O2         Initial                                #
#                                                                              #
#  1.2        Oct/2007   NET-O2         Interface parameter modified           #
#                                                                              #
################################################################################
# Copyright (C) 2005-2007 Net-O2 Technologies (P) Ltd.                         #
################################################################################

