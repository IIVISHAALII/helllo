#! /usr/bin/tcl
###############################################################################
# Test Case         :   tc_conf_ipv6_arr_002                                  #
# Test Case Version :   1.4                                                   #
# Component Name    :   NET-O2 ATTEST CONFORMANCE TEST SUITE                  #
# Module Name       :   Automatic Tunneling Group (ATG)                       #
#                                                                             #
# Purpose           :   To verify that a 6t04 relay router advertise the 6to4 #
#                       anycast prefix (i.e.192.88.99.0/24), using the IGP of #
#                       their Ipv4 autonomous system, as if it where a        #
#                       connection to an external network.                    #
#                                                                             #
# Reference         :   RFC 3068 Sec 4.2 (pg. 3)                              #
# Conformance Type  :   MUST                                                  #
#                                                                             #
###############################################################################
# Test Setup        :   2                                                     #
#                                                                             #
#                     TEE                                      DUT            #
#  _____           __________                              __________         #
# |     |         |  _____   |                            |          |        #
# | RT1 |.....----|-|     |  |                            |          |        #
# |_____|         | | RT2 |--|----------------------------|          |        #
#                 | |_____|  |           (I1)             |          |        #
#     ------------|---       |                            |          |        #
#    |            |  _|___   |                            |          |        #
#    |  Native    | |     |  |                            |          |        #
#    |  IPv6      | | RT4 |--|----------------------------|   RT3    |        #
#    |  Cloud   /-|-|_____|  |           (I2)             |          |        #
#    |         /  |          |                            |          |        #
#    |        /   |  _____   |                            |          |        #
#    |-------/    | |     |  |                            |          |        #
#     ------------|-| RT5 |--|----------------------------|          |        #
#    |            | |_____|  |           (I3)             |          |        #
#    |            |___|______|                            |__________|        #
#    |  IPv4          |                                                       #
#    |   AS           |                                                       #
#    |(RT2 Local      |                                                       #
#    |  Site)         |                                                       #
#    |----------------|                                                       #
#                                                                             #
#                                                                             #
#                                                                             #
#                                           RT1 : Remote 6to4 router          #
#                                           RT3 : 6to4 relay router           #
#                                     RT2 & RT4 : IPv4 only router            #
#                                                                             #
###############################################################################
# Ladder Diagram    :                                                         #
#             TEE                                                   DUT       #
#              |                                                     |        #
#              |                                                     |        #
#              | Send Continuously RA from RT4 (I2)                  |        #
#              |------>>---------------------------------------------|        #
#              |                                                     |        #
#              |                          <Expiry of MinLS Interval> |        #
#              |                                                     |        #
#              |              OSPF LSU {acast addr of RT3} (RT3,I3)  |        #
#              |---------------------------------------------<<------|        #
#              |                                                     |        #
#                                                                             #
###############################################################################
#                                                                             #
# Procedure         :                                                         #
#                                                                             #
# (Initial Part)                                                              #
#                                                                             #
# Step 1 : Initialization of DUT                                              #
#     i.   Add Interface(I1 & I3) with a IPv4 adddress at DUT.                #
#     ii.  Add Interface(I2) with 6to4 IPv6 address at DUT.                   #
#     iii. Add Interface(loopback) with 6to4 anycast address at DUT.          #
#     iv.  Add 6to4 Tunnel Interface with 6to4 address with tunnel source as  #
#          DUT loopback Interface.                                            #
#     v.   Enable IPv6 and IP forwarding at DUT.                              #
#     vi.  Add a default route for native IPv6 address with output interface  #
#          as Interface (I2) at DUT.                                          #
#                                                                             #
# Step 2 : Initialization of TEE                                              #
#     i.   Initialize the Router RT2 on TEE Interface I1 with IPv4 address.   #
#          (Assuming the simulated host RT1 is reachable through it.)         #
#     ii.  Initialize the Router RT4 on TEE Interface I2 with native IPv6     #
#          address.(Assuming that RT4 lies on a native IPv6 cloud.)           #
#     iii. Initialize the Router RT5 on TEE Interface I3 with IPv4 address.   #
#          (Assuming that RT5 lies on the local network as RT3.)              #
#                                                                             #
# (Part-I)                                                                    #
#                                                                             #
# Step 3 :  Send a Router Advertisement measage from RT4 to RT3 preiodically  #
#           on TEE Interface(I1).                                             #
# Step 4 : Set Ospf parameters on Interface (I3) at DUT.                      #
# Step 5 : Create Ospf process with a Router-id and assign Network to area    #
#          at DUT.                                                            #
# Step 6 : Set Ospf parameters on Interface (I3) at TEE.                      #
# Step 7 : Receive Hello packet with DR = RT3 from interface(I3) of DUT.      #
# Step 8 : Send Hello packets with RT3_ID as Neighbor ID and DR = RT3         #
#          and BDR = RT5 from interface(I3) of TEE.                           #
# Step 9 : Receive Data Description packet with I,M & MS bits set from        #
#          interface(I3) of DUT.                                              #
# Step 10: Send Data Description Packet with  value of DDSN in the received   #
#          DD and with single RT5's Router LSA Header packet from             #
#          interface(I3) of TEE.                                              #
# Step 11: Receive Data Description packet with RT3's Router LSA Header       #
#          from interface(I3) of DUT.                                         #
# Step 12: Send Data Description Packet with value of DDSN in the received    #
#          DD packet from interface(I3) of TEE.                               #
#          Ensure DD Exchange is completed(set exchange_done_flg to TRUE).    #
# Step 13: Send LS request packet with RT5's Router LSA Header from           #
#          interface(I3) of TEE.                                              #
# Step 14:  To verify that DUT advertise the 6to4 anycast prefix, Check that  #
#           DUT sends LS update packet with RT3's router LSA having 6to4      #
#           anycast address on Interface (I3).                                #
#                                                                             #
###############################################################################
# History       Date     Author         Addition/ Alteration                  #
#                                                                             #
#    1.1       Feb/2006  NET-O2         Initial                               #
#    1.2       Apr/2007  NET-O2         ENV Variable name changed             #
#    1.3       Oct/2007  NET-O2         Editorial modification                #
#    1.4       Oct/2007  NET-O2         Ladder Diagram modified and Step 13   #
#                                       modified                              #
#                                                                             #
###############################################################################
#                                                                             #
# Copyright (C) 2007 Net-O2 Technologies(P) Ltd.                              #
###############################################################################

############ GLOBAL VARIABLES ARE DECLARED HERE #################

global env ipv6_env
global ipv6tunn_env
global dut_session_handler
global dut_router_id process_id     
global dut_interface_3 dut_ip_address_3 area_id tee_interface_3 

######### INITIALIZING LOCAL VARIABLES WITH VALUES FROM ENVIRONMENTAL VARIABLES #########

### Initializing DUT Address and SNMP Port ###
set dut_address $env(dut_ADDRESS)
set dut_port    $env(dut_PORT)

### Initializing DUT Interface Locations ###
set dut_interface_1 $env(dut_to_tee_1_LOCATION)
set dut_interface_3 $env(dut_to_tee_3_LOCATION)
set dut_v6_interface_2 $env(dut_to_tee_2_LOCATION)
set dut_tunn_interface_1 $ipv6tunn_env(dut_to_tee_tunn_1_location)
set dut_lbk_interface_1  $ipv6tunn_env(dut_to_tee_lbk_1_location)

### Initializing TEE Interface Locations ###
set tee_interface_1 $env(tee_to_dut_1_LOCATION)
set tee_interface_3 $env(tee_to_dut_3_LOCATION)
set tee_v6_interface_2 $env(tee_to_dut_2_LOCATION)

### Initializing DUT Test Interface IPv6 Address ###
set dut_ip_address_1   $ipv6tunn_env(dut_ipv4_decap_addr)
set dut_ip_address_3   $ipv6tunn_env(dut_ipv4_addr)
set dut_lbk_address_1  $ipv6tunn_env(dut_lbk_address_1)

### Initializing DUT Test Prefix ###
set dut_ip_mask_1         $env(dut_TEST_MASK)
set dut_ip_mask_3         $env(dut_TEST_MASK)
set dut_ip_prefix_len_1   $env(dut_TEST_PREFIX1)
set dut_tunn_prefix_len_1 $ipv6tunn_env(dut_v6_prefix_length_3)

####### Initializing Prefix And Gateway Values For Route ####
set v6_st_rout_addr_1            $ipv6tunn_env(dut_v6_st_rout_prefix_2)
set v6_st_rout_gateway_1         $dut_v6_interface_2
set v6_st_rout_prefix_length_1   $ipv6tunn_env(dut_v6_prefix_length_1)

### Initializing Mask at TEE with DUT Prefix value ###
set tee_ip_mask_1         $dut_ip_mask_1
set tee_ip_mask_3         $dut_ip_mask_3
set tee_ip_prefix_len_1   $dut_ip_prefix_len_1

### Initializing Tunnel Mode  ###
set 6to4_tunnel_mode $ipv6tunn_env(dut_6to4_tunnel_mode)

### Initializing Hello Time Interval ###
set tee_ospf_hello_interval $env(DUT_OSPF_DEFAULT_HELLO_INTERVAL)

### Initializing DD Timeout ###
set dd_timeout [expr ($env(DUT_OSPF_DEFAULT_RETRANSMIT_INTERVAL)*2) +\
                $env(TEE_OSPF_USER_DELAY)]

### Initializing LS Request Timeout ###
set ls_req_timeout [expr ($env(DUT_OSPF_DEFAULT_RETRANSMIT_INTERVAL)*2) +\
                $env(TEE_OSPF_USER_DELAY)]

### Initializing LS Update Timeout ###
set ls_update_timeout [expr ($env(DUT_OSPF_DEFAULT_RETRANSMIT_INTERVAL)*2) +\
                       $env(TEE_OSPF_USER_DELAY)]

### Initializing Waiting Timer value ###
set waiting_timeout [expr $tee_ospf_hello_interval *4 +\
                              $env(TEE_OSPF_USER_DELAY)]

### Initializing Timeout Value for receiving ICMPv6 packet ###
set icmp_timeout $ipv6_env(DUT_IPV6_DEFAULT_ICMPV6_TIMEOUT)

###### END OF LOCAL VARIABLES INITIALIZATION WITH ENVIRONMENTAL VARIABLES ######

### Initializing DUT 6to4 Address & Tunnel IPv6 address  ###

if {![tee_ipv4_addr_to_6to4_addr -ip_address   $dut_ip_address_1 \
                                 -6to4_address dut_tunnel_ip_addr_2] } {

    puts " \n##################################################################"
    puts    "#  Error: Unable to get dut_tunnel_ip_addr_2 from $dut_ip_address_2"
    puts    "##################################################################"

    TC_ABORT -reason "Tunnel Interface Allocation Error"
    return 0

 }

if {![tee_ipv4_addr_to_6to4_subnet_host_addr -ip_address         $dut_ip_address_1 \
                                             -6to4_sub_host_addr dut_v6_address_2] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get dut_v6_address_2 from dut_ip_address_2"
    puts    "################################################################"

    TC_ABORT -reason "First Test Interface IPv6 Allocation Error"
    return 0

 }

puts   "Tunnel IPv6 Address is : $dut_tunnel_ip_addr_2"
puts "\nDUT IPv6 address is    : $dut_v6_address_2"

if {  [lindex [ split  $dut_ip_address_1  ":"] end] == 1  } {

### Initializing TEE IPv4 Address (I1) to a value higher than DUT ###

if {![tee_get_higher_address         -ip_address  $dut_ip_address_1 \
                                     -ret_address tee_ip_address_1] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_ip_address_1 from $dut_ip_address_1 "
    puts    "################################################################"

    TC_ABORT -reason "First Test Interface IPv6 Allocation Error"
    return 0

   }
   } else {

### Initializing TEE IPv4 Address (I1) to a value lower than DUT ###

if {![tee_get_lower_address         -ip_address  $dut_ip_address_1 \
                                    -ret_address tee_ip_address_1] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_ip_address_1 from $dut_ip_address_1 "
    puts    "################################################################"

    TC_ABORT -reason "First Test Interface IPv6 Allocation Error"
    return 0
}
}

puts "\nOn I1, DUT IP address is : $dut_ip_address_1"
puts   "On I1, TEE IP address is : $tee_ip_address_1"

if {  [lindex [ split  $dut_v6_address_2  ":"] end] == 1  } {

### Initializing TEE IPv6 address (I2) to a value higher than DUT ###

if {![tee_ipv6_get_higher_address    -ip_address  $dut_v6_address_2 \
                                     -ret_address tee_v6_address_2] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_v6_address_2 from $dut_v6_address_2 "
    puts    "################################################################"

    TC_ABORT -reason "Second Test Interface IP Allocation Error"
    return 0

   }
   } else {

### Initializing TEE IPv6 address (I2) to a value lower than DUT ###

if {![tee_ipv6_get_lower_address    -ip_address  $dut_v6_address_2 \
                                    -ret_address tee_v6_address_2] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_v6_address_2 from $dut_v6_address_2 "
    puts    "################################################################"

    TC_ABORT -reason "First Test Interface IPv6 Allocation Error"
    return 0
}
}

puts "\nOn I2, DUT IP address is : $dut_v6_address_2"
puts   "On I2, TEE IP address is : $tee_v6_address_2"

if {  [lindex [ split  $dut_ip_address_3  ":"] end] == 1  } {

### Initializing TEE IPv4 Address (I1) to a value higher than DUT ###

if {![tee_get_higher_address         -ip_address  $dut_ip_address_3 \
                                     -ret_address tee_ip_address_3] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_ip_address_3 from $dut_ip_address_3 "
    puts    "################################################################"

    TC_ABORT -reason "Third Test Interface IPv6 Allocation Error"
    return 0

   }
   } else {

### Initializing TEE IPv4 Address (I1) to a value lower than DUT ###

if {![tee_get_lower_address         -ip_address  $dut_ip_address_3 \
                                    -ret_address tee_ip_address_3] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_ip_address_3 from $dut_ip_address_3 "
    puts    "################################################################"

    TC_ABORT -reason "Third Test Interface IPv6 Allocation Error"
    return 0
}
}

puts "\nOn I3, DUT IP address is : $dut_ip_address_3"
puts   "On I3, TEE IP address is : $tee_ip_address_3"


######### LOCAL VARIABLES ARE DEFINED HERE ######################

### DUT Interface and Location List ###
set dut_interface_list           [list $dut_interface_1 $dut_interface_3 ]
set dut_v6_interface_list        [list $dut_v6_interface_2 ]
set dut_tunn_interface_list      [list $dut_tunn_interface_1]
set dut_lbk_interface_list       [list $dut_lbk_interface_1]
set dut_v6_address_list          [list $dut_v6_address_2]
set dut_ip_address_list          [list $dut_ip_address_1  $dut_ip_address_3 ]
set dut_lbk_address_list         [list $dut_lbk_address_1]
set dut_ip_prefix_len_list       [list $dut_ip_prefix_len_1 ]
set dut_tunn_prefix_len_list     [list $dut_tunn_prefix_len_1 ]
set dut_ip_mask_list             [list $dut_ip_mask_1 $dut_ip_mask_3 ]
set dut_tunnel_ip_addr_list      [list $dut_tunnel_ip_addr_2]
set dut_tunnel_source_list       $ipv6tunn_env(dut_tunnel_source_1)

#### Static Route Parameters List ###
set v6_st_rout_addr_list          [list $v6_st_rout_addr_1 ]
set v6_st_rout_gateway_list       [list $v6_st_rout_gateway_1 ]
set v6_st_rout_prefix_length_list [list $v6_st_rout_prefix_length_1 ]

### TEE Interface and IPv6 Address List ###
set tee_interface_list           [list $tee_interface_1 $tee_interface_3 ]
set tee_v6_interface_list        [list $tee_v6_interface_2 ]
set tee_ip_address_list          [list $tee_ip_address_1 $tee_ip_address_3 ]
set tee_v6_address_list          [list $tee_v6_address_2 ]
set tee_ip_prefix_len_list       [list $tee_ip_prefix_len_1 ]
set tee_ip_mask_list             [list $tee_ip_mask_1 $tee_ip_mask_3 ]

### Initializing AllSPFRouters Address ###
set all_spf_routers 224.0.0.5

### Initializing Router ID at DUT ###
set dut_router_id  $dut_ip_address_3

### Initializing Router ID at TEE ###
set tee_router_id  $tee_ip_address_3

### Initializing Area ID ###
set area_id  1.1.1.1

### Initializing Number of Neighbors ###
set no_of_neighbor_2 1

### Initializing Neighbor List ###
set neighbor_list_2 [list $dut_router_id] 

### Initializing Priority at DUT ###
set dut_I1_priority 50

### Initializing Priority at TEE ###
set tee_I1_priority 20

### Initializing AllSPFRouters Address ###
set all_spf_routers 224.0.0.5

### Initializing the Number of times a PDU has to be sent ###
set ONCE    1
set FOREVER 255

### Initializing the Number of Router Links for TEE ###
set no_of_rtr_link 2

### Initializing Router Link Type ### 
set rtr_link_type "3:3"

### Initializing Router Link Type ### 
set rtr_link_1 "$dut_lbk_address_1:$ipv6tunn_env(dut_ipv4_ntw)"

### Initializing Hello Timeout ###
set hello_timeout [expr $tee_ospf_hello_interval *2 + $env(TEE_OSPF_USER_DELAY)]

### Initializing Master/Slave bit ###
set mstr_slv_bit_set   1

### Initializing LS Age ###
set ls_age 10

### Initializing LS Type ###
set ls_type 1

### Initializing LS sequence Number ###
set ls_seq_num  "2147483649"

### Initializing More bit ###
set more_bit_set 1

### Initializing Exchange Done  ###
set ex_done_flg_set 1

## Expected Packet Type ###
set pkt_type_dd "2"

### Initializing Init Bit ###
set init_bit_set 1

### Setting Router Instance  ###
set router_instance 1

### Setting OSpf Parameters  ###
set dead_interval   40
set hello_interval  10
set auth_type       "null"
set process_id      "10"
set area_id         "1.1.1.1"
set ntw_address_1   "$ipv6tunn_env(dut_ipv4_ntw)"
set ntw_address_2   "$ipv6tunn_env(dut_lbk_net_addr)"

### Initializing ICMP Parameters ###
set code                "0"

set tc_def              "To verify that a 6t04 relay router advertise the 6to4\
                         anycast prefix (i.e.192.88.99.0/24), using the IGP of\
                         their Ipv4 autonomous system, as if it where a\
                         connection to an external network.\
                         RFC 3068 Sec 4.2 (pg. 3)"

############## CLEANUP PROCEDURE STARTS HERE ###################

proc cleanup { } {

global env
global dut_session_handler dut_router_id process_id     
global dut_interface_3 dut_ip_address_3 area_id tee_interface_3 

   puts "\n****************************************************************"
   puts   "* Starting Cleanup procedure. Please ignore the ERRORS          "
   puts   "****************************************************************\n"


### Disabling OSPF and Removing Router ID ###
      dut_ospf_disable_ospf_with_router_id \
                                 -session_handler     $dut_session_handler\
                                 -router_id           $dut_router_id \
                                 -process_id          $process_id

### Resetting DUT Interface Parameters ###
      dut_ospf_reset_ospf_if_params \
                                 -session_handler     $dut_session_handler\
                                 -interface           $dut_interface_3 \
                                 -ip_address          $dut_ip_address_3 \
                                 -area_id             $area_id  

### Resetting DUT Interface Parameters ###
      tee_ospf_reset_if_params \
                                 -interface          $tee_interface_3

   puts "\n****************************************************************"
   puts   "*  End of Cleanup procedure                                     "
   puts   "****************************************************************\n"

}

################ END OF CLEANUP PROCEDURE #######################

################# START OF THE TEST CASE ########################

TC_DISPLAY -text $tc_def

### Opening Session with DUT ###

dut_open_session  -ip_address      $dut_address \
                  -port            $dut_port \
                  -session_handler dut_session_handler

if {$dut_session_handler == 0} {

   puts "\n##################################################################"
   puts   "#  Error: Unable to open session with DUT                         "
   puts   "##################################################################"

   TC_ABORT -reason "Unable to open session with DUT"
 return 0
}
   puts "\n******************************************************************"
   puts   "*  Successfully initialized DUT session                           "
   puts   "******************************************************************"

### Opening Session with TEE ###

if {![tee_ipv6_open_session]} {

   puts "\n##################################################################"
   puts   "#  Error: Unable to open session with TEE                         "
   puts   "##################################################################"

   TC_ABORT -reason "Unable to open session with TEE"
   return 0
}
   puts "\n******************************************************************"
   puts   "*  Successfully initialized TEE session                           "
   puts   "******************************************************************"

### (Initial Part) ###

###############################################################################
# Step 1 : Initialization of DUT                                              #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Configuring DUT for Testsetup 2                                "
   puts   "******************************************************************"

        if {![ dut_ipv6_tunn_configure_setup_002 \
                     -session_handler                $dut_session_handler \
                     -v6_interface_list              $dut_v6_interface_list \
                     -v4_interface_list              $dut_interface_list \
                     -tunnel_interface_list          $dut_tunn_interface_list \
                     -lbk_interface_list             $dut_lbk_interface_list \
                     -mode                           $6to4_tunnel_mode \
                     -tunnel_ip_address_list         $dut_tunnel_ip_addr_list \
                     -tunnel_source_list             $dut_tunnel_source_list \
                     -v6_address_list                $dut_v6_address_list \
                     -ip_address_list                $dut_ip_address_list \
                     -lbk_address_list               $dut_lbk_address_list \
                     -v6_prefix_length_list          $dut_ip_prefix_len_list \
                     -tunn_prefix_length_list        $dut_tunn_prefix_len_list \
                     -v6_st_rout_addr_list           $v6_st_rout_addr_list \
                     -v6_st_rout_gateway_list        $v6_st_rout_gateway_list \
                     -v6_st_rout_prefix_length_list  $v6_st_rout_prefix_length_list \
                     -mask_list                      $dut_ip_mask_list ]} {
 
   puts "\n##################################################################"
   puts   "#                           Step 1                                "
   puts   "#  Error: Could not configure DUT for Testsetup 2                 "
   puts   "##################################################################"

   TC_ABORT -reason "Could not configure DUT for Testsetup 2"\
            -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 1                                "
   puts   "*  Successfully configured DUT for Testsetup 2                    "
   puts   "******************************************************************"
 
###############################################################################
# Step 2 : Initialization of TEE                                              #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Configuring TEE for Testsetup 9                                "
   puts   "******************************************************************"

         if {![tee_ipv6_tunn_configure_setup_009 \
                        -dut_interface_list      $dut_interface_list \
                        -dut_v6_interface_list   $dut_v6_interface_list \
                        -tee_interface_list      $tee_interface_list \
                        -tee_v6_interface_list   $tee_v6_interface_list \
                        -dut_ip_address_list     $dut_ip_address_list \
                        -tee_ip_address_list     $tee_ip_address_list \
                        -dut_v6_address_list     $dut_v6_address_list \
                        -tee_v6_address_list     $tee_v6_address_list \
                        -v6_prefix_length_list   $tee_ip_prefix_len_list \
                        -mask_list               $tee_ip_mask_list \
                        -v4_inf_mac_addr_1       mac_address_1 \
                        -v6_inf_mac_addr_1       mac_address_2 \
                        -v4_inf_mac_addr_2       mac_address_3 ]} {

   puts "\n##################################################################"
   puts   "#                           Step 2                                "
   puts   "#  Error: Could not configure TEE for Testsetup 9                 "
   puts   "##################################################################"

   TC_ABORT -reason "Could not configure TEE for Testsetup 9"\
            -tc_def $tc_def
   return 0

}
   puts "\n******************************************************************"
   puts   "*                           Step 2                                "
   puts   "*   Successfully configured TEE for Testsetup 9                   "
   puts   "******************************************************************"

### Part I ###

### Enable Capture On feature for IPv6 packets on TEE interfaces ###
tee_ipv6_enable_pkt_capture                                  

###############################################################################
# Step 3 :  Send a Router Advertisement meaasge from RT4 to RT3 preiodically  #
#           on TEE Interface(I1).                                             #
###############################################################################

for { set i  0 } { $i < 5 } { incr i } {

   puts "\n******************************************************************"
   puts   "*  Sending an IPv6 packet(Router Advertisment) on TEE interface   "
   puts   "*  $tee_v6_interface_2 with the following information             "
   puts   "*  Sourse Ip Addr             -      $tee_v6_address_2            "
   puts   "*  Dest Ip Addr               -      $dut_v6_address_2            "
   puts   "*  Code                       -      $code                        "
   puts   "******************************************************************"
if {![tee_icmpv6_send_router_adv_mesg \
                      -interface                $tee_v6_interface_2 \
                      -dest_mac                 $mac_address_2 \
                      -src_ip_address           $tee_v6_address_2 \
                      -dest_ip_address          $dut_v6_address_2 \
                      -code                     $code ]} {

   puts "\n##################################################################"
   puts   "#                           Step 3                                "
   puts   "#  Error: Unable to send an IPv6 packet(Router Advertisment) on   "
   puts   "#         TEE interface $tee_v6_interface_2 with the specified    "
   puts   "#         parameters                                              "
   puts   "##################################################################"

   TC_CLEAN_AND_ABORT -reason "Unable to send the specified IPv6 packet
                               (Router Advertisment)on the given TEE interface"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 3                                "
   puts   "*  Successfully sent an IPv6 packet(Router Advertisment) on TEE   "
   puts   "*  interface $tee_v6_interface_2 with the specified parameters    "
   puts   "******************************************************************"

 sleep 5

}

###############################################################################
# Step 4 : Set Ospf parameters on Interface (I3) at DUT.                      #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Enabling OSPF Interface  $dut_interface_3                      "
   puts   "*  Interface                $dut_interface_3                      "
   puts   "*  Area ID                  $area_id                              "
   puts   "*  Network IP Address       $dut_ip_address_3                     "
   puts   "*  Dead Interval            $dead_interval                        "
   puts   "*  Hello Interval           $hello_interval                       "
   puts   "*  Auth Type                $auth_type                            "
   puts   "******************************************************************"

if {![dut_ospf_set_ospf_if_params \
                                 -session_handler     $dut_session_handler \
                                 -interface           $dut_interface_3 \
                                 -area_id             $area_id \
                                 -ip_address          $dut_ip_address_3 \
                                 -dead_interval       $dead_interval \
                                 -hello_interval      $hello_interval \
                                 -auth_type           $auth_type ]} {

   puts "\n##################################################################"
   puts   "#                           Step  4                               "
   puts   "#  Error: Could not enable OSPF Interface $dut_interface_3 with   "
   puts   "#         the specified parameters at DUT                         "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Could not enable OSPF interface with the \ 
                               specified parameters at DUT"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step  4                               "
   puts   "*  Successfully enabled OSPF Interface $dut_interface_3 with the  "
   puts   "*  specified parameters at DUT                                    "
   puts   "******************************************************************"

###############################################################################
# Step 5 : Create Ospf process with a Router-id and assign Network to area    #
#          at DUT.                                                            #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Enabling the OSPF Process and Assigning Router ID at DUT       "
   puts   "*  Router ID       $dut_router_id                                 "
   puts   "*  Process ID      $process_id                                    "
   puts   "******************************************************************"

if {![dut_ospf_enable_ospf_with_router_id  \
                                -session_handler $dut_session_handler\
                                -process_id      $process_id\
                                -router_id       $dut_router_id]} {

   puts "\n##################################################################"
   puts   "#                           Step 5                                "
   puts   "#  Error: Could not enable the OSPF process and assign            "
   puts   "#                   OSPF Router ID at DUT                         "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Could not enable the OSPF process and \
                               assign OSPF Router ID at DUT"\
		      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 5                                "
   puts   "*  Successfully enabled the OSPF process and assigned             "
   puts   "*                  OSPF Router ID at DUT                          "                                  
   puts   "******************************************************************"

   puts "\n******************************************************************"
   puts   "*  Creating an OSPF area $area_id at DUT                          "
   puts   "*  Area ID         $area_id                                       "
   puts   "*  Process ID      $process_id                                    "
   puts   "******************************************************************"

if {![dut_ospf_create_area   -session_handler $dut_session_handler\
                             -process_id      $process_id\
			     -area_id         $area_id]} {

   puts "\n##################################################################"
   puts   "#                           Step 5                                "
   puts   "#  Error: Unable to create OSPF area $area_id at DUT              "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Unable to create the specified OSPF area at \
                               DUT"\
		      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 5                                "
   puts   "*  Successfully created OSPF Area $area_id at DUT                 "
   puts   "******************************************************************"

   puts "\n******************************************************************"
   puts   "*  Assigning a network to the given area $area_id on the DUT :    "
   puts   "*  Process ID               $process_id                           "
   puts   "*  Interface                $dut_interface_3                      "
   puts   "*  Network IP Address       $ntw_address_1                        "
   puts   "*  Mask                     $dut_ip_mask_1                        "
   puts   "******************************************************************"

if {![dut_ospf_assign_network_to_area \
                         -session_handler   $dut_session_handler\
                         -area_id           $area_id \
                         -process_id        $process_id\
                         -interface         $dut_interface_3 \
                         -ip_address        $ntw_address_1 \
                         -mask              $dut_ip_mask_1]} {

   puts "\n##################################################################"
   puts   "#                           Step 5                                "
   puts   "#  Error: Unable to assign a network with IP address              "
   puts   "#         $ntw_address_1 and mask $mask to the area               "
   puts   "#         $area_id on the DUT                                     "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Unable to assign the network to a given area \
                               on the DUT"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 5                                "
   puts   "*  Successfully assigned a network with IP address                "
   puts   "*  $ntw_address_1 and mask $dut_ip_mask_1 to the area $area_id    "
   puts   "*  on the DUT                                                     "
   puts   "******************************************************************"

   puts "\n******************************************************************"
   puts   "*  Assigning a network to the given area $area_id on the DUT :    "
   puts   "*  Process ID               $process_id                           "
   puts   "*  Interface                $dut_interface_3                      "
   puts   "*  Network IP Address       $ntw_address_2                        "
   puts   "*  Mask                     $dut_ip_mask_1                        "
   puts   "******************************************************************"

if {![dut_ospf_assign_network_to_area \
                         -session_handler   $dut_session_handler\
                         -area_id           $area_id \
                         -process_id        $process_id\
                         -interface         $dut_interface_3 \
                         -ip_address        $ntw_address_2 \
                         -mask              $dut_ip_mask_1]} {

   puts "\n##################################################################"
   puts   "#                           Step 5                                "
   puts   "#  Error: Unable to assign a network with IP address              "
   puts   "#         $ntw_address_2 and mask $mask to the area               "
   puts   "#         $area_id on the DUT                                     "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Unable to assign the network to a given area \
                               on the DUT"\
   TC_CLEAN_AND_FAIL  -reason "Unable to assign the network to a given area \
                               on the DUT"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 5                                "
   puts   "*  Successfully assigned a network with IP address                "
   puts   "*  $ntw_address_2 and mask $dut_ip_mask_1 to the area $area_id    "
   puts   "*  on the DUT                                                     "
   puts   "******************************************************************"

###############################################################################
# Step 6 : Set Ospf parameters on Interface (I3) at TEE.                      #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Enabling the OSPF TEE interface $tee_interface_3               "
   puts   "*  with the parameter(s) :                                        "
   puts   "*  Network Mask              $tee_ip_mask_1                       "
   puts   "*  Destination Mask          $mac_address_3                       "
   puts   "*  Router ID                 $tee_router_id                       "
   puts   "*  Area ID                   $area_id                             "
   puts   "******************************************************************"

if {![tee_ospf_set_if_params      -interface             $tee_interface_3 \
                                  -mask                  $tee_ip_mask_1 \
                                  -dest_mac              $mac_address_3 \
                                  -router_id             $tee_router_id \
                                  -area_id               $area_id]} {

   puts "\n##################################################################"
   puts   "#                           Step 6                                "
   puts   "#  Error: Unable to set the OSPF parameters on the TEE interface  "
   puts   "#         $tee_interface_3 with router $tee_router_id and the     "
   puts   "#         default parameters                                      "
   puts   "##################################################################"

   TC_CLEAN_AND_ABORT -reason "Unable to set the OSPF parameters on the TEE\
                               interface I  with the specified values"\
		      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 6                                "
   puts   "*  Successfully set the OSPF parameters with the specified values "
   puts   "*  on the TEE interface $tee_interface_3                          "
   puts   "******************************************************************"

###############################################################################
# Step 7 : Receive Hello packet with DR = RT3 from interface(I3) of DUT.      #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Waiting for $waiting_timeout.0 secs to receive the Hello packet"
   puts   "*  on the interface $tee_interface_3                              "
   puts   "*  Designated Router           $dut_ip_address_3                  "
   puts   "******************************************************************"

if {![tee_ospf_recv_hello_pkt  -interface         $tee_interface_3 \
                               -error_reason      error_reason \
                               -timeout           $waiting_timeout]} {

   puts "\n##################################################################"
   puts   "#                           Step 7                                "
   puts   "#  Error : DUT has not sent a Hello packet on                     "
   puts   "#          interface $dut_interface_3 with the expected values    "
   puts   "#  Reason: $error_reason                                          "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "DUT has not sent the expected Hello packet\
                               ($error_reason) on interface I1"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 7                                "
   puts   "*  DUT has sent a Hello packet on interface $dut_interface_3      "
   puts   "*  with the expected values                                       "
   puts   "******************************************************************"

 

###############################################################################
# Step 8 : Send Hello packets with RT3_ID as Neighbor ID and DR = RT3         #
#          and BDR = RT5 from interface(I3) of TEE.                           #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Sending a Hello packet on the TEE interface $tee_interface_3   "
   puts   "*  with Source Address       $tee_ip_address_3                    "
   puts   "*  Destination Address       $all_spf_routers                     "
   puts   "*  Designated Router         $dut_ip_address_3                    "
   puts   "*  Backup Designated Router  $tee_ip_address_3                    "
   puts   "*  Number of Neighbors       $no_of_neighbor_2                    "
   puts   "*  Neighbor List             $neighbor_list_2                     "
   puts   "*  Times                     $FOREVER                             "
   puts   "******************************************************************"

if {![tee_ospf_send_hello_pkt  -interface         $tee_interface_3 \
                               -src_addr          $tee_ip_address_3 \
                               -dest_addr         $all_spf_routers \
                               -dsg_rtr           $dut_ip_address_3 \
                               -bckup_dsg_rtr     $tee_ip_address_3 \
                               -no_of_neighbor    $no_of_neighbor_2 \
                               -neighbor_list     $neighbor_list_2 \
                               -times             $FOREVER]} {

   puts "\n##################################################################"
   puts   "#                           Step 8                                "
   puts   "#  Error: Unable to send a Hello packet with the specified        "
   puts   "#         parameters on the TEE interface $tee_interface_3        "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Unable to send a Hello packet with the given\
                               parameters on the TEE interface I1"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 8                                "
   puts   "*  Successfully sent a Hello packet with the specified parameters "
   puts   "*  on the TEE interface $tee_interface_3                          "
   puts   "******************************************************************"

###############################################################################
# Step 9 : Receive Data Description packet with I,M & MS bits set from        #
#          interface(I3) of DUT.                                              #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Waiting for $dd_timeout.0 secs to receive the DD packet        "
   puts   "*  on the interface $tee_interface_3 with                         "
   puts   "*  Packet Type              $pkt_type_dd                          "
   puts   "*  Init Bit                 $init_bit_set                         "
   puts   "*  More Bit                 $more_bit_set                         "
   puts   "*  Master Slave Bit         $mstr_slv_bit_set                     "
   puts   "******************************************************************"

if {![tee_ospf_recv_dd_lsack_pkt -interface         $tee_interface_3 \
                                 -pkt_type          $pkt_type_dd \
                                 -init_bit          $init_bit_set \
                                 -more_bit          $more_bit_set \
                                 -mstr_slv_bit      $mstr_slv_bit_set \
                                 -recvd_dd_seq_num  recvd_dd_seq_num_1 \
                                 -error_reason      error_reason \
                                 -timeout           $dd_timeout]} {

   puts "\n##################################################################"
   puts   "#                           Step 9                                "
   puts   "#  Error : DUT has not sent a DD packet on the interface          "
   puts   "#          $dut_interface_3 with the expected values              "
   puts   "#  Reason: $error_reason                                          "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "DUT has not sent the expected DD packet\
                               ($error_reason) on interface I1"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 9                                "
   puts   "*  DUT has sent a DD packet on interface $dut_interface_3         "
   puts   "*  with the expected values                                       "
   puts   "******************************************************************"


###############################################################################
# Step 10: Send Data Description Packet with  value of DDSN in the received   #
#          DD and with single RT5's Router LSA Header packet from             #
#          interface(I3) of TEE.                                              #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Sending a Database Description packet on the TEE               "
   puts   "*  TEE interface $tee_interface_3 with :                          "
   puts   "*  Source Address         $tee_ip_address_3                       "
   puts   "*  Destination Address    $dut_ip_address_3                       "
   puts   "*  DD Sequence Number     $recvd_dd_seq_num_1                     "
   puts   "*  LS Age                 $ls_age                                 "
   puts   "*  LS Type                $ls_type                                "
   puts   "*  Link State ID          $tee_router_id                          "
   puts   "*  Advertising Router ID  $tee_router_id                          "
   puts   "*  LS Sequence Number     $ls_seq_num                             "
   puts   "******************************************************************"

if {![tee_ospf_send_dd_pkt         -interface      $tee_interface_3 \
                                   -src_addr       $tee_ip_address_3 \
                                   -dest_addr      $dut_ip_address_3 \
                                   -dd_seq_num     $recvd_dd_seq_num_1 \
                                   -ls_age         $ls_age \
                                   -ls_type        $ls_type \
                                   -link_state_id  $tee_router_id \
                                   -adv_router     $tee_router_id \
                                   -ls_seq_num     $ls_seq_num ]} {

   puts "\n##################################################################"
   puts   "#                           Step 10                               "
   puts   "#  Error: Unable to send a Database Description packet on the     "
   puts   "#  TEE interface $tee_interface_3 with the specified parameters.  "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Unable to send a DD packet on\
                               the TEE interface I1"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 10                               "
   puts   "*  Successfully sent the DD packet on the TEE interface           "
   puts   "*  $tee_interface_3 with the specified parameters.                "
   puts   "******************************************************************"

###############################################################################
# Step 11: Receive Data Description packet with RT3's Router LSA Header       #
#          from interface(I3) of DUT.                                         #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Waiting for $dd_timeout.0 secs to receive the DD packet        "
   puts   "*  on the interface $tee_interface_3 with                         "
   puts   "*  Packet Type                 $pkt_type_dd                       "
   puts   "*  LS Type                     $ls_type                           "
   puts   "*  Link State ID               $dut_router_id                     "
   puts   "*  Advertising Router          $dut_router_id                     "
   puts   "******************************************************************"

if {![tee_ospf_recv_dd_lsack_pkt  -interface         $tee_interface_3 \
                                  -pkt_type          $pkt_type_dd \
                                  -ls_type           $ls_type \
                                  -link_state_id     $dut_router_id \
                                  -adv_router        $dut_router_id \
                                  -recvd_dd_seq_num  recvd_dd_seq_num_2 \
                                  -error_reason      error_reason \
                                  -timeout           $dd_timeout]} {

   puts "\n##################################################################"
   puts   "#                           Step 11                               "
   puts   "#  Error : DUT has not sent a DD packet on interface              "
   puts   "#          $dut_interface_3 with the expected values              "
   puts   "#  Reason: $error_reason                                          "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "DUT has not sent the expected DD packet\
                               ($error_reason) on interface I1"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 11                               "
   puts   "*  DUT has sent a DD packet on interface $dut_interface_3 with    "
   puts   "*  the expected values                                            "
   puts   "******************************************************************"

                                                                            

###############################################################################
# Step 12: Send Data Description Packet with value of DDSN in the received    #
#          DD packet from interface(I3) of TEE.                               #
#          Ensure DD Exchange is completed(set exchange_done_flg to TRUE).    #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Sending a Database Description packet on the TEE interface     "
   puts   "*  $tee_interface_3 with :                                        "
   puts   "*  Source Address       $tee_ip_address_3                         "
   puts   "*  Destination Address  $dut_ip_address_3                         "
   puts   "*  DD Sequence Number   $recvd_dd_seq_num_2                       "
   puts   "******************************************************************"

if {![tee_ospf_send_dd_pkt       -interface      $tee_interface_3 \
                                 -src_addr       $tee_ip_address_3 \
                                 -dest_addr      $dut_ip_address_3 \
                                 -ex_done_flg    $ex_done_flg_set \
                                 -dd_seq_num     $recvd_dd_seq_num_2 ]} {

   puts "\n##################################################################"
   puts   "#                           Step 12                               "
   puts   "#  Error: Unable to send a Database Description packet on the     "
   puts   "#  TEE interface $tee_interface_3 with the specified parameters.  "
   puts   "##################################################################"
   
   TC_CLEAN_AND_ABORT -reason "Unable to send a DD packet on\
                               the TEE interface I1"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 12                               "
   puts   "*  Successfully sent the DD packet on the TEE interface           "
   puts   "*  $tee_interface_3 with the specified parameters.                "
   puts   "******************************************************************"

###############################################################################
# Step 13: Send LS request packet with RT5's Router LSA Header from           #
#          interface(I3) of TEE.                                              #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Sending a LS Request packet on the TEE interface               "
   puts   "*  $tee_interface_3 with :                                        "
   puts   "*  Source Address       $tee_ip_address_3                         "
   puts   "*  Destination Address  $dut_ip_address_3                         "
   puts   "*  LS Type              $ls_type                                  "
   puts   "******************************************************************"

if {![tee_ospf_send_ls_req_pkt  \
                            -interface         $tee_interface_3 \
                            -src_addr          $tee_ip_address_3 \
                            -dest_addr         $dut_ip_address_3 \
                            -ls_type           $ls_type \
                            -link_state_id     $dut_router_id \
                            -adv_router        $dut_router_id \
                            -error_reason      error_reason\
                            -timeout           $ls_req_timeout]} {

   puts "\n##################################################################"
   puts   "#                           Step 13                               "
   puts   "#  Error: Unable to send an LS Request packet on interface        "
   puts   "#          $tee_interface_3 with the expected values              "
   puts   "#  Reason: $error_reason                                          "
   puts   "##################################################################"

   TC_CLEAN_AND_ABORT -reason "TEE has not sent the expected LS Request packet\
                              ($error_reason) on interface I3"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 13                               "
   puts   "*  Successfully sent an LS Request packet on interface            "
   puts   "*  $tee_interface_3 with the expected values                      "
   puts   "******************************************************************"

###############################################################################
# Step 14:  To verify that DUT advertise the 6to4 anycast prefix, Check that  #
#           DUT sends LS update packet with RT3's router LSA having 6to4      #
#           anycast address on Interface (I3).                                #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Waiting for $ls_update_timeout.0 seconds to receive a          "
   puts   "*  Router LS Update packet on interface $tee_interface_3 with :   "
   puts   "*  LS Type                     $ls_type                           "
   puts   "*  Anycast Address             $dut_lbk_address_1                 "
   puts   "*  Network IP Address          $ntw_address_1                     "
   puts "\n******************************************************************"

if {![tee_ospf_recv_router_lsupdate_pkt \
                                  -interface         $tee_interface_3 \
                                  -ls_type           $ls_type \
                                  -adv_router        $dut_router_id \
                                  -no_of_rtr_link    $no_of_rtr_link \
                                  -rtr_link_id       $rtr_link_1 \
                                  -rtr_link_type     $rtr_link_type \
                                  -link_state_id     $dut_router_id \
                                  -timeout           $ls_update_timeout\
                                  -error_reason      error_reason ]} {

   puts "\n##################################################################"
   puts   "#                           Step 14                               "
   puts   "#  Error : DUT has not sent a Router LS Update packet on          "
   puts   "#          interface $dut_interface_3 with the expected values    "
   puts   "#  Reason: $error_reason                                          "
   puts   "##################################################################"
   
   TC_CLEAN_AND_FAIL  -reason "DUT has not sent the expected Router LS Update\
                               packet ($error_reason) on interface I"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 14                               "
   puts   "*  DUT has sent a Router LS Update packet on interface            "
   puts   "*  $dut_interface_3 with the expected values                      "
   puts   "******************************************************************"

   TC_CLEAN_AND_PASS  -reason "DUT has sent the expected Router LS Update\
                               packet ($error_reason) on interface I"\
                      -tc_def $tc_def
   return 1

############################### END OF TESTCASE ##################################
