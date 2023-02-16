#! /usr/bin/tcl
###############################################################################
# Test Case         :   tc_conf_ipv6_arr_001                                  #
# Test Case Version :   1.3                                                   #
# Component Name    :   NET-O2 ATTEST CONFORMANCE TEST SUITE                  #
# Module Name       :   Anycast Relay Router Specification Group (ARR)        #
#                                                                             #
# Purpose           :   To verify that a 6to4 relay routers that advertise the#
#                       6to4 anycast prefix will receive packets bound to the #
#                       6to4 anycast address and relay these packets to the   #
#                       IPv6 Internet.                                        #
#                                                                             #
# Reference         :   RFC 3068 Sec 4.2 (pg. 4) para 1                       #
# Conformance Type  :   MUST                                                  #
#                                                                             #
###############################################################################
# Test Setup        :   9                                                     #
#  _____                                                                      #
# |     |                                                                     #
# | HT1 |                                                                     #
# |_____|          TEE                                      DUT               #
#    |          __________                              __________            #
#  __|__       |  _____   |                            |          |           #
# |     |....--|-|     |  |                            |          |           #
# | RT1 |      | | RT2 |--|----------------------------|          |           #
# |_____|      | |_____|  |           (I1)             |          |           #
#              |          |                            |          |           #
#              |  _____   |                            |          |           #
#              | |     |  |    (to the local 6to4 site)|          |           #
#              | | RT4 |--|----------------------------|   RT3    |           #
#              | |_____|  |           (I2)             |          |           #
#  ------------|---       |                            |          |           #
# |            |  _|___   |                            |          |           #
# |  Native    | |     |  |                            |          |           #
# |  IPv6      | | RT5 |--|----------------------------|          |           #
# |  Cloud     | |_____|  |           (I3)             |          |           #
# |            |___|______|                            |__________|           #
# |                |                                                          #
# |----------------|                        RT1 : 6to4 router                 #
#                                           RT2 : IPv4 router                 #
#                                           RT3 : 6to4 relay router           #
#                                           RT4 : local IPv6 router           #
#                                           RT5 : IPv6 router                 #
#                                                                             #
###############################################################################
# Ladder Diagram    :                                                         #
#                   TEE                                             DUT       #
#                    |                                               |        #
#                    |                                               |        #
#                    | IPv4 Tn pkt{Src = RT1's IPv4 addr,Dtn = 6to4  |        #
#                    | acast addr}{IPv6 dgm, Src = HT1's 6to4 addr,  |        #
#                    | Dtn = RT5's IPv6 addr} (I1)                   |        #
#                    |------>>---------------------------------------|        #
#                    |                                               |        #
#                    |         IPv6 pkt{Src = HT1's 6to4 addr, Dtn = |        #
#                    |         RT5's IPv6 addr} (I3)                 |        #
#                    |--------------------------------<<-------------|        #
#                    |                                               |        #
#                                                                             #
###############################################################################
#                                                                             #
# Procedure         :                                                         #
#                                                                             #
# (Initial Part)                                                              #
#                                                                             #
# Step 1 : Initialization of DUT                                              #
#     i.   Add Interface(I1) with IPv4 address at DUT.                        #
#     ii.  Add Interface(I2) with 6to4 address at the DUT.                    #
#    iii.  Add Interface(I3) with native IPv6 address at DUT.                 #
#     iv.  Add Interface(loopback) with 6to4 anycast address at DUT.          #
#     v.   Add 6to4 Tunnel Interface with 6to4 address with tunnel source as  #
#          DUT loopback Interface.                                            #
#     v.   Enable IPv6 and IP forwarding at DUT.                              #
#     vi.  Add default static route for the IPv6 destination address with     #
#          output interface as the DUT interface I3.                          #
#                                                                             #
# Step 2 : Initialization of TEE                                              #
#     i.   Initialize the Router RT2 on TEE Interface I1 with IPv4 address.   #
#          (Assuming the simulated host HT1 is reachable through RT1.)        #
#     ii.  Initialize the Router RT5 on TEE Interface I3 with native IPv6     #
#          address.(Assuming that RT3 lies on a native IPv6 cloud.)           #
#                                                                             #
# (Part-I)                                                                    #
#                                                                             #
# Step 3 :  Send a IPv4 tunnel packet with source address as RT1's IPv4       #
#           address and Destination as 6to4 anycast address and having IPv6   #
#           datagram with source address as HT1's 6to4 address and            #
#           Destination as a native IPv6 address on TEE Interface(I1).        #
# Step 4 :  To verify that DUT relays the received 6to4 bounded packet to the #
#           IPv6 Internet, Check that DUT sends IPv6 datagram with Source as  #
#           HT1's 6to4 address and destination as a native IPv6 address on TEE#
#           address on Interface (I3).                                        #
#                                                                             #
###############################################################################
# History       Date     Author         Addition/ Alteration                  #
#                                                                             #
#    1.1       Feb/2006  NET-O2         Initial                               #
#    1.2       Apr/2007  NET-O2         ENV Variable name changed             #
#    1.3       Oct/2007  NET-O2         Editorial modification                #
#                                                                             #
###############################################################################
#                                                                             #
# Copyright (C) 2007 Net-O2 Technologies(P) Ltd.                              #
###############################################################################

############ GLOBAL VARIABLES ARE DECLARED HERE #################

global env ipv6_env
global  ipv6tunn_env
global dut_session_handler

######### INITIALIZING LOCAL VARIABLES WITH VALUES FROM ENVIRONMENTAL VARIABLES #########

### Initializing DUT Address and SNMP Port ###
set dut_address $env(dut_ADDRESS)
set dut_port    $env(dut_PORT)

### Initializing DUT Interface Locations ###
set dut_interface_1 $env(dut_to_tee_1_LOCATION)
set dut_v6_interface_3 $env(dut_to_tee_3_LOCATION)
set dut_6to4_interface_2 $env(dut_to_tee_2_LOCATION)
set dut_tunn_interface_1 $ipv6tunn_env(dut_to_tee_tunn_1_location)
set dut_lbk_interface_1  $ipv6tunn_env(dut_to_tee_lbk_1_location)

### Initializing TEE Interface Locations ###
set tee_interface_1 $env(tee_to_dut_1_LOCATION)
set tee_v6_interface_3 $env(tee_to_dut_3_LOCATION)

### Initializing DUT Test Interface IPv6 Address ###
set dut_ip_address_1   $ipv6tunn_env(dut_ipv4_decap_addr)
set dut_v6_address_3   $env(dut_TEST_ADDRESS3)
set dut_lbk_address_1  $ipv6tunn_env(dut_lbk_address_1)

### Initializing DUT Test Prefix ###
set dut_ip_mask_1         $env(dut_TEST_MASK)
set dut_ip_prefix_len_1   $env(dut_TEST_PREFIX1)
set dut_6to4_prefix_len_1 $ipv6tunn_env(dut_v6_prefix_length_3)
set dut_tunn_prefix_len_1 $ipv6tunn_env(dut_v6_prefix_length_3)

####### Initializing Prefix And Gateway Values For Route ####
set v6_st_rout_addr_1            $ipv6tunn_env(dut_v6_st_rout_prefix_2)
set v6_st_rout_gateway_1         $env(dut_to_tee_3_LOCATION)
set v6_st_rout_prefix_length_1   $ipv6tunn_env(dut_v6_prefix_length_1)

### Initializing Mask at TEE with DUT Prefix value ###
set tee_ip_mask_1         $dut_ip_mask_1
set tee_ip_prefix_len_1   $dut_ip_prefix_len_1

### Initializing Tunnel Mode  ###
set 6to4_tunnel_mode $ipv6tunn_env(dut_6to4_tunnel_mode)

### Initializing Timeout Value for receiving ICMPv6 packet ###
set icmp_timeout $ipv6_env(DUT_IPV6_DEFAULT_ICMPV6_TIMEOUT)

###### END OF LOCAL VARIABLES INITIALIZATION WITH ENVIRONMENTAL VARIABLES ######

### Initializing DUT 6to4 Address & Tunnel IPv6 address  ###

if {![tee_ipv4_addr_to_6to4_addr -ip_address   $dut_ip_address_1 \
                                 -6to4_address dut_tunnel_ip_addr_2] } {

    puts " \n##################################################################"
    puts    "#  Error: Unable to get dut_tunnel_ip_addr_2 from dut_ip_address_2"
    puts    "##################################################################"

    TC_ABORT -reason "Tunnel Interface Allocation Error"
    return 0

 }

if {![tee_ipv4_addr_to_6to4_subnet_host_addr -ip_address         $dut_ip_address_1 \
                                             -6to4_sub_host_addr dut_6to4_address_2] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get dut_6to4_address_2 from dut_ip_address_2"
    puts    "################################################################"

    TC_ABORT -reason "First Test Interface IPv6 Allocation Error"
    return 0

 }

puts "\nDUT 6to4 address is    : $dut_6to4_address_2"
puts   "Tunnel IPv6 Address is : $dut_tunnel_ip_addr_2"

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

if {  [lindex [ split  $dut_v6_address_3  ":"] end] == 1  } {

### Initializing TEE IPv6 address (I2) to a value higher than DUT ###

if {![tee_ipv6_get_higher_address    -ip_address  $dut_v6_address_3 \
                                     -ret_address tee_v6_address_3] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_v6_address_3 from $dut_v6_address_3 "
    puts    "################################################################"

    TC_ABORT -reason "Second Test Interface IP Allocation Error"
    return 0

   }
   } else {

### Initializing TEE IPv6 address (I2) to a value lower than DUT ###

if {![tee_ipv6_get_lower_address    -ip_address  $dut_v6_address_3 \
                                    -ret_address tee_v6_address_3] } {

    puts " \n################################################################"
    puts    "#  Error: Unable to get tee_v6_address_3 from $dut_v6_address_3 "
    puts    "################################################################"

    TC_ABORT -reason "First Test Interface IPv6 Allocation Error"
    return 0
}
}

puts "\nOn I3, DUT IP address is : $dut_v6_address_3"
puts   "On I3, TEE IP address is : $tee_v6_address_3"

######### LOCAL VARIABLES ARE DEFINED HERE ######################

### DUT Interface and Location List ###
set dut_interface_list           [list $dut_interface_1 ]
set dut_v6_interface_list        [list $dut_v6_interface_3 ]
set dut_6to4_interface_list      [list $dut_6to4_interface_2 ]
set dut_tunn_interface_list      [list $dut_tunn_interface_1]
set dut_lbk_interface_list       [list $dut_lbk_interface_1]
set dut_v6_address_list          [list $dut_v6_address_3 ]
set dut_6to4_address_list        [list $dut_6to4_address_2 ]
set dut_ip_address_list          [list $dut_ip_address_1]
set dut_lbk_address_list         [list $dut_lbk_address_1]
set dut_ip_prefix_len_list       [list $dut_ip_prefix_len_1 ]
set dut_6to4_prefix_len_list     [list $dut_6to4_prefix_len_1 ]
set dut_tunn_prefix_len_list     [list $dut_tunn_prefix_len_1 ]
set dut_ip_mask_list             [list $dut_ip_mask_1]
set dut_tunnel_ip_addr_list      [list $dut_tunnel_ip_addr_2]
set dut_tunnel_source_list       $ipv6tunn_env(dut_tunnel_source_1)

#### Static Route Parameters List ###
set v6_st_rout_addr_list          [list $v6_st_rout_addr_1 ]
set v6_st_rout_gateway_list       [list $v6_st_rout_gateway_1 ]
set v6_st_rout_prefix_length_list [list $v6_st_rout_prefix_length_1 ]

### TEE Interface and IPv6 Address List ###
set tee_interface_list           [list $tee_interface_1 ]
set tee_v6_interface_list        [list $tee_v6_interface_3 ]
set tee_ip_address_list          [list $tee_ip_address_1]
set tee_v6_address_list          [list $tee_v6_address_3 ]
set tee_ip_prefix_len_list       [list $tee_ip_prefix_len_1 ]
set tee_ip_mask_list             [list $tee_ip_mask_1]

### Initializing ICMP Parameters  ###
set protocol_tun       "41"
set payload_length     "1200"
set payload_length_1   "1208"
set next_hdr_udp       "17"
set rmt_tunn_src_addr  "$ipv6tunn_env(dut_rmt_tunn_src_addr)"
set rmt_v6_address     "2002:c0a8:b0c:1::1"

set tc_def             "To verify that a 6to4 relay routers that advertise the\
                        6to4 anycast prefix will receive packets bound to the\
                        6to4 anycast address and relay these packets to the\
                        IPv6 Internet.\
                        RFC 3068 Sec 4.2 (pg. 4) para 1"

############## CLEANUP PROCEDURE STARTS HERE ###################

proc cleanup { } {

### EMPTY ###

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
   puts   "*  Configuring DUT for Testsetup 9                                "
   puts   "******************************************************************"

        if {![ dut_ipv6_tunn_configure_setup_009 \
                     -session_handler                $dut_session_handler \
                     -v6_interface_list              $dut_v6_interface_list \
                     -6to4_interface_list            $dut_6to4_interface_list \
                     -v4_interface_list              $dut_interface_list \
                     -tunnel_interface_list          $dut_tunn_interface_list \
                     -lbk_interface_list             $dut_lbk_interface_list \
                     -mode                           $6to4_tunnel_mode \
                     -tunnel_ip_address_list         $dut_tunnel_ip_addr_list \
                     -tunnel_source_list             $dut_tunnel_source_list \
                     -v6_address_list                $dut_v6_address_list \
                     -6to4_address_list              $dut_6to4_address_list \
                     -ip_address_list                $dut_ip_address_list \
                     -lbk_address_list               $dut_lbk_address_list \
                     -v6_prefix_length_list          $dut_ip_prefix_len_list \
                     -6to4_prefix_length_list        $dut_6to4_prefix_len_list \
                     -tunn_prefix_length_list        $dut_tunn_prefix_len_list \
                     -v6_st_rout_addr_list           $v6_st_rout_addr_list \
                     -v6_st_rout_gateway_list        $v6_st_rout_gateway_list \
                     -v6_st_rout_prefix_length_list  $v6_st_rout_prefix_length_list \
                     -mask_list                      $dut_ip_mask_list ]} {
 
   puts "\n##################################################################"
   puts   "#                           Step 1                                "
   puts   "#  Error: Could not configure DUT for Testsetup 9                 "
   puts   "##################################################################"

   TC_ABORT -reason "Could not configure DUT for Testsetup 9"\
            -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 1                                "
   puts   "*  Successfully configured DUT for Testsetup 9                    "
   puts   "******************************************************************"
 
###############################################################################
# Step 2 : Initialization of TEE                                              #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Configuring TEE for Testsetup 6                                "
   puts   "******************************************************************"

         if {![tee_ipv6_tunn_configure_setup_006 \
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
                        -v4_inf_mac_addr_1       mac_address_1 ]} {

   puts "\n##################################################################"
   puts   "#                           Step 2                                "
   puts   "#  Error: Could not configure TEE for Testsetup 6                 "
   puts   "##################################################################"

   TC_ABORT -reason "Could not configure TEE for Testsetup 6"\
            -tc_def $tc_def
   return 0

}
   puts "\n******************************************************************"
   puts   "*                           Step 2                                "
   puts   "*   Successfully configured TEE for Testsetup 6                   "
   puts   "******************************************************************"

### Part I ###

### Enable Capture On feature for IPv6 packets on TEE interfaces ###
tee_ipv6_enable_pkt_capture                                  

###############################################################################
# Step 3 :  Send a IPv4 tunnel packet with source address as RT1's IPv4       #
#           address and Destination as 6to4 anycast address and having IPv6   #
#           datagram with source address as HT1's 6to4 address and            #
#           Destination as a native IPv6 address on TEE Interface(I1).        #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Sending an encapsulated IPv6 Packet over TEE interface         "
   puts   "*  $tee_interface_1 with the following information                "
   puts   "*  Interface                - $tee_interface_1                    "
   puts   "*  Destination MAC          - $mac_address_1                      "
   puts   "*  Protocol                 - $protocol_tun                       "
   puts   "*  Source Address           - $rmt_tunn_src_addr                  "
   puts   "*  Destination Address      - $dut_lbk_address_1                  "
   puts   "*  Source IP Address        - $rmt_v6_address                     "
   puts   "*  Destination IP Address   - $tee_v6_address_3                   "
   puts   "******************************************************************"

if {![tee_ipv6_tunn_send_pkt  \
                            -interface         $tee_interface_1 \
                            -dest_mac          $mac_address_1 \
                            -protocol_tun      $protocol_tun \
                            -src_address       $rmt_tunn_src_addr \
                            -dest_address      $dut_lbk_address_1 \
                            -src_ip_address    $rmt_v6_address \
                            -udp_data_length   $payload_length \
                            -dest_ip_address   $tee_v6_address_3 \
                            -next_header       $next_hdr_udp ]} {

   puts "\n##################################################################"
   puts   "#                           Step 3                                "
   puts   "#  Error: Unable to send an encapsulated IPv6 packet on the TEE   "
   puts   "#         interface $tee_interface_1 with the specified parameters"
   puts   "##################################################################"

   TC_CLEAN_AND_ABORT -reason "Unable to send the specified encapsulated IPv6\
                               packet on the given TEE interface"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 3                                "
   puts   "*  Successfully sent an encapsulated IPv6 packet on the TEE       "
   puts   "*  interface $tee_interface_1 with the specified parameters       "
   puts   "******************************************************************"


###############################################################################
# Step 4 :  To verify that DUT relays the received 6to4 bounded packet to the #
#           IPv6 Internet, Check that DUT sends IPv6 datagram with Source as  #
#           HT1's 6to4 address and destination as a native IPv6 address on TEE#
#           address on Interface (I2).                                        #
###############################################################################

   puts "\n******************************************************************"
   puts   "*  Waiting for $icmp_timeout seconds to receive an IPv6 packet    "
   puts   "*  on TEE interface $tee_v6_interface_3 with the following        "
   puts   "*  information                                                    "
   puts   "*  Source IP Address      - $rmt_v6_address                       "
   puts   "*  Destination IP Address - $tee_v6_address_3                     "
   puts   "******************************************************************"

if {![tee_ipv6_recv_pkt    -interface           $tee_v6_interface_3 \
                           -src_ip_address      $rmt_v6_address \
                           -dest_ip_address     $tee_v6_address_3 \
                           -next_header         $next_hdr_udp \
                           -payload_length      $payload_length_1 \
                           -timeout             $icmp_timeout \
                           -error_reason        error_reason ]} {

   puts "\n##################################################################"
   puts   "#                           Step 4                                "
   puts   "#  Error : DUT has not sent an IPv6 Packet on interface           "
   puts   "#          $dut_v6_interface_3 with the expected values           "
   puts   "#  Reason: $error_reason                                          "
   puts   "##################################################################"
   
   TC_CLEAN_AND_FAIL  -reason "DUT has not sent the expected IPv6 packet\
                              on interface $dut_v6_interface_3"\
                      -tc_def $tc_def
   return 0
}
   puts "\n******************************************************************"
   puts   "*                           Step 4                                "
   puts   "*  DUT has sent an IPv6 packet on interface $dut_v6_interface_3   "
   puts   "*  with the expected values                                       "
   puts   "******************************************************************"
 
   TC_CLEAN_AND_PASS  -reason "DUT has sent the expected IPv6 packet\
                              on interface $dut_v6_interface_3"\
                      -tc_def $tc_def
   return 1

############################### END OF TESTCASE ##################################
