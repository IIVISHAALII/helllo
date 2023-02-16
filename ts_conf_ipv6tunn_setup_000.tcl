################################################################################
# Test Setup          :    ts_conf_ipv6tunn_setup_000.tcl                      #
# Test-Setup Version  :    1.2                                                 #
# Component Name      :    NET-O2 ATTEST CONFORMANCE TEST SETUP                #
# Protocol Name       :    IPv6 (INTERNET PROTOCOL Version 6)                  #
#                                                                              #
# Description         :    This file contains the mapping of testcases to their#
#                          respective Testsetup.                               #
#                                                                              #
################################################################################
# History       Date     Author         Addition/ Alteration                   #
#                                                                              #
#  1.1        Apr/2005   NET-O2         Initial                                #
#                                                                              #
################################################################################
# Copyright (C) 2005 Net-O2 Technologies (P) Ltd.                              #
################################################################################


proc tee_set_ipv6tunn_setup_groups_from_file {} {

global setup_group

        set path Protocol/Ipv6_T/Conformance_Test_Suites/Testsetup

### Test Setup 1 ### 

set setup_group(tc_conf_ipv6_ctm_013) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_015) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_032) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_034) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_035) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_036) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_037) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_038) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_039) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_040) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_041) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_042) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_043) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ctm_044) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ndg_005) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_ndg_006) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_trs_013) $path/ts_conf_ipv6tunn_setup_001.tcl
set setup_group(tc_conf_ipv6_trs_016) $path/ts_conf_ipv6tunn_setup_001.tcl

### Test Setup 2 ### 

set setup_group(tc_conf_ipv6_arr_002) $path/ts_conf_ipv6tunn_setup_002.tcl
set setup_group(tc_conf_ipv6_arr_004) $path/ts_conf_ipv6tunn_setup_002.tcl
set setup_group(tc_conf_ipv6_arr_009) $path/ts_conf_ipv6tunn_setup_002.tcl

### Test Setup 3 ### 

set setup_group(tc_conf_ipv6_ctm_002) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_003) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_004) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_005) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_006) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_007) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_008) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_009) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_010) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_011) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_012) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_014) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_016) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_017) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_018) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_019) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_020) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_021) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_022) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_023) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_024) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_025) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_026) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_027) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_028) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_029) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_ctm_030) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_trs_001) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_trs_002) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_trs_005) $path/ts_conf_ipv6tunn_setup_003.tcl
set setup_group(tc_conf_ipv6_trs_015) $path/ts_conf_ipv6tunn_setup_003.tcl

### Test Setup 4 ### 

set setup_group(tc_conf_ipv6_ctg_003) $path/ts_conf_ipv6tunn_setup_004.tcl
set setup_group(tc_conf_ipv6_ctg_004) $path/ts_conf_ipv6tunn_setup_004.tcl
set setup_group(tc_conf_ipv6_ctm_046) $path/ts_conf_ipv6tunn_setup_004.tcl
set setup_group(tc_conf_ipv6_ctm_056) $path/ts_conf_ipv6tunn_setup_004.tcl

### Test Setup 5 ### 

set setup_group(tc_conf_ipv6_ctg_001) $path/ts_conf_ipv6tunn_setup_005.tcl
set setup_group(tc_conf_ipv6_ctm_047) $path/ts_conf_ipv6tunn_setup_005.tcl
set setup_group(tc_conf_ipv6_ctm_048) $path/ts_conf_ipv6tunn_setup_005.tcl
set setup_group(tc_conf_ipv6_ctm_049) $path/ts_conf_ipv6tunn_setup_005.tcl
set setup_group(tc_conf_ipv6_ndg_003) $path/ts_conf_ipv6tunn_setup_005.tcl
set setup_group(tc_conf_ipv6_ndg_004) $path/ts_conf_ipv6tunn_setup_005.tcl

### Test Setup 6 ### 

set setup_group(tc_conf_ipv6_atg_001) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_002) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_005) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_006) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_007) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_008) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_009) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_010) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_011) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_012) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_013) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_014) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_atg_015) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_veg_001) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_veg_003) $path/ts_conf_ipv6tunn_setup_006.tcl
set setup_group(tc_conf_ipv6_veg_004) $path/ts_conf_ipv6tunn_setup_006.tcl

### Test Setup 7 ### 

set setup_group(tc_conf_ipv6_dsg_001) $path/ts_conf_ipv6tunn_setup_007.tcl
set setup_group(tc_conf_ipv6_dsg_002) $path/ts_conf_ipv6tunn_setup_007.tcl
set setup_group(tc_conf_ipv6_dsg_003) $path/ts_conf_ipv6tunn_setup_007.tcl

### Test Setup 8 ### 

set setup_group(tc_conf_ipv6_ctm_045) $path/ts_conf_ipv6tunn_setup_008.tcl

### Test Setup 9 ### 

set setup_group(tc_conf_ipv6_arr_001) $path/ts_conf_ipv6tunn_setup_009.tcl
set setup_group(tc_conf_ipv6_arr_003) $path/ts_conf_ipv6tunn_setup_009.tcl

### Test Setup 10 ### 

set setup_group(tc_conf_ipv6_ndg_001) $path/ts_conf_ipv6tunn_setup_010.tcl
set setup_group(tc_conf_ipv6_ndg_002) $path/ts_conf_ipv6tunn_setup_010.tcl
set setup_group(tc_conf_ipv6_ctm_057) $path/ts_conf_ipv6tunn_setup_010.tcl

### Test Setup 11 ### 

set setup_group(tc_conf_ipv6_atg_016) $path/ts_conf_ipv6tunn_setup_011.tcl


}
