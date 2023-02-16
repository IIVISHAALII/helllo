#------------------------------------------------------------------------------
# Source Name:    xmlCreatorConformance.tcl
#
# Vesrion:        1.3
#
# Created:        12 Oct 2007
#
# Last modified:  02 Jan 2017
#------------------------------------------------------------------------------
# Registered Procedures#
#
#   1.checkFileExist 
#------------------------------------------------------------------------------
# Revision History
#
#    1.1   03-Jul-2008 Initial script
#    1.2   16-Nov-2010 Modified to print the eta time as "eta_<GroupName>_<TestCaseID>.It helps to update eta time value automatically from test log #          files. Added New line:450 and updated existing line:461
#    1.3   02-Jan-2017 Added fix for setup number and setup file creation issue 
#
#------------------------------------------------------------------------------
#  Copyright (C) 2017 Veryx Technologies

# This script is used to parse the testlog files in the protocol directory 
# and create xml file with general protocol information.

#Environment Settings

puts "Starting the Conformance xml creartion"

array set INFO ""
global INFO

set INFO(basePath) [lindex $argv 0]

puts "Received Arguements : Base Path : $INFO(basePath)"
global testSuiteName
set testSuiteName [lindex [split [lindex $argv 0] "/"] end]
proc initializeEnvironment {} {
	global INFO
        global wFd

        # Create the Directory Config under the protocol folder.Delete it if already exist
        catch {file delete -force ${INFO(basePath)}/Config} err
        if [info exist err] {
        }

	set INFO(headerPath)            "${INFO(basePath)}/Config/Header" 
	set INFO(ladderPath)            "${INFO(basePath)}/Config/Ladder"  
	set INFO(stepsPath)             "${INFO(basePath)}/Config/Steps"  
	set INFO(topologyPath)          "${INFO(basePath)}/Config/Topology" 
	set INFO(testcaseInfoPath)      "${INFO(basePath)}/Config/TestInfo"      
	set INFO(testScriptPath)        "${INFO(basePath)}/Conformance_Test_Suites/Testscript"	


        catch {file mkdir $INFO(headerPath)}
	catch {file mkdir $INFO(ladderPath)}
       	catch {file mkdir $INFO(stepsPath)}
        catch {file mkdir $INFO(topologyPath)}
	catch {file mkdir $INFO(testcaseInfoPath)}
      	set wFd [open "$INFO(basePath)/Config/suite.xml" w]	
  


}

initializeEnvironment

# General Initilization
proc setTestcaseEnvironment {} {
	global INFO
	#Dafault Information of Testcase Inforamation
	set INFO(tcSuiteName)           "NONE"
	set INFO(tcTitle)               "NONE"
	set INFO(tcNAME)                "NONE"
	set INFO(tcVersion)             "NONE"
	set INFO(tcGroup)               "NONE" 
	set INFO(tcGroupAcronym)        "NONE" 
	set INFO(tcSetupNumber)         "NONE"
	set INFO(tcPortNUmbers)         "NONE"
	set INFO(tcPurpose)             "NONE"
	set INFO(tcRefrence)            "NONE"
	set INFO(tcSetupFile)           "NONE"
	set INFO(tcHeaderFile)          "NONE"
	set INFO(tcLadderDiagramFile)   "NONE" 
	set INFO(tcTopologyDiagramFile) "NONE" 
	set INFO(tcStepsDiagramFile)    "NONE" 
	set INFO(fdHeaderFile)   	"NONE"
	set INFO(fdTopologyFile) 	"NONE"
	set INFO(fdLadderFile)   	"NONE"
	set INFO(fdStepFile)     	"NONE"
	set INFO(fdSetupFile)    	"NONE"


	# Code Logic for ladder,setup,topology file name creation
	set tmp [split $INFO(tcFile) "."]
	set tmp [lindex $tmp 0]

	#Change the file name token if required
        #{tmp} will be the name of logfile with out exetension -- {tc_conf_stp_atg_001} 	

        set INFO(tcHeaderFile)          ${tmp}_header.txt  
	set INFO(tcLadderDiagramFile)   ${tmp}_ladder.txt
	set INFO(tcTopologyDiagramFile) ${tmp}_topology.txt
	set INFO(tcStepsDiagramFile)    ${tmp}_steps.txt


}

proc SplitHeaders {} {
	global INFO
	set INFO(fdTestScript)    [open "${INFO(testScriptPath)}/${INFO(tcFile)}" r]
	set INFO(fdHeaderFile)    [open ${INFO(headerPath)}/${INFO(tcHeaderFile)} w]
 	set INFO(fdTopologyFile)  [open $INFO(topologyPath)/${INFO(tcTopologyDiagramFile)} w]
	set INFO(fdLadderFile)	  [open $INFO(ladderPath)/${INFO(tcLadderDiagramFile)} w] 
	set INFO(fdStepFile)      [open $INFO(stepsPath)/${INFO(tcStepsDiagramFile)} w] 

	set hashDelimiterCount 0      
	set line [gets $INFO(fdTestScript)]
	while {![eof $INFO(fdTestScript)]} {
		set line [gets $INFO(fdTestScript)]
	      	if [string match "*Copyright*" $line] {
			break
		}
		if [string match "*########################*" $line] {	 
        		set line [gets $INFO(fdTestScript)]
				incr hashDelimiterCount
         }
	        switch $hashDelimiterCount {
	  		"1" {
				 regsub -all "#" $line "" line
				 puts $INFO(fdHeaderFile) $line 
			    } 
		        "2" {
				 regsub -all "#" $line "" line
				 puts $INFO(fdTopologyFile) $line 
			    } 
			"3" {
				 regsub -all "#" $line "" line
				 puts $INFO(fdLadderFile) $line 
			    } 
			"4" {
				 regsub -all "#" $line "" line
				 puts $INFO(fdStepFile) $line 
		        } 	    
	      }
        }  
	close $INFO(fdTestScript)
	close $INFO(fdHeaderFile)
	close $INFO(fdTopologyFile)
	close $INFO(fdLadderFile)
 	close $INFO(fdStepFile)
}

proc ParseGeneralInformation {} {


	global INFO

    set title_flag 0
	set INFO(fdHeaderFile)    [open ${INFO(headerPath)}/${INFO(tcHeaderFile)} r]
	set val1 "Test Case"	
	set INFO(tcName) "TEST_"
    set infoBuffer ""
    set filters "Case Module Type Version Title Purpose Component Conformance Reference"

    while {[gets $INFO(fdHeaderFile) line] >0} {
		set frmtTxt [string trim $line "#"]
	    set frmtTxt [string trim $frmtTxt ]
        foreach filter $filters {
	    	if {[string match "*$filter*" $line]} {
            	if {[string match "*:*" $line]} {
		           append infoBuffer "@"
        	    }
	         }
		}
	    append infoBuffer "$frmtTxt "
   }
   close $INFO(fdHeaderFile)
   set fullBuffer [string trim [ split $infoBuffer "@"]]
   puts "Full Buffer : $fullBuffer"

  foreach buffer $fullBuffer {
   if {$buffer==""} {
       continue
   }

   set tmpVal [split $buffer ":"]
   set value [lrange $tmpVal 1 end]
   set value [string trim $value "{" ]
   set value [string trim $value "}" ]
   set value [string trim $value]  

   if { [string match "*Case*" $buffer ] && ![string match "*Version*" $buffer] } {
        puts "Case Match"
        set INFO(tcFile_name) $value         
        set tmp [lindex [split $INFO(tcFile_name) "_"] 2]
        puts "Value : $value"
        puts "tmp : $tmp"
        set testCaseNumber [lindex [split $INFO(tcFile_name) "_"] 4]
        puts "Test case ID : $testCaseNumber"
        set INFO(tcSuiteName) [string toupper $tmp]
#       regexp {_([^?][0-9]+)} $INFO(tcFile) match testCaseNumber
        append INFO(tcName) $testCaseNumber
        continue
   }

   if { [string match "*Case*" $buffer ] && [string match "*Version*" $buffer]} {
        set INFO(tcVersion) $value
        continue
   }

   if { [string match "*Title*" $buffer]} {
       set INFO(tcTitle) $value
       #puts "Title -> $INFO(tcTitle)"
       continue
   }

   if { [string match "*Purpose*" $buffer]} {
        set INFO(tcPurpose) $value
       continue
   }

   if { [string match "*Reference*" $buffer]} {
     set INFO(tcReference) $value
     continue
   }

   if { [string match "*Type*" $buffer]} {
     set INFO(tcType) $value
     puts "type---->$INFO(tcType)"
     continue
   }

   if { [string match "*Module*" $buffer]} {
        set grp $value
        set INFO(tcGroup) [lindex $grp end]
        regsub "\\)" $INFO(tcGroup) "" INFO(tcGroup)
        regsub "\\(" $INFO(tcGroup) "" INFO(tcGroup)
        set INFO(tcGroupAcronym) [lrange $grp 0 end-1]
        set tmp [split $INFO(tcGroupAcronym) "/"]
        set len [llength $tmp]
        if {$len==1} {
            set INFO(tcGroupAcronym) [lindex $tmp 0]
        } else {
            set INFO(tcGroupAcronym) [lindex $tmp 1]
        }
        continue
   }

}
}

proc ParseGeneralInformation1 {} {
	global INFO
        set title_flag 0
	set INFO(fdHeaderFile)    [open ${INFO(headerPath)}/${INFO(tcHeaderFile)} r]
	set val1 "Test Case"	
	set INFO(tcName) "TEST_"
        set str ""
        set filters "Case Module Type Version Title Purpose Component Conformance Reference"
        while {[gets $INFO(fdHeaderFile) line] >0} {
        set frmtTxt [string trim $line "#"]
        set frmtTxt [string trim $frmtTxt ]
        foreach filter $filters {
         if {[string match "*$filter*" $line]} {
          if {[string match "*:*" $line]} {
           append str "@"
          }
      }
  }
  append str "$frmtTxt "
}

set str1 [string trim [ split $str "@"]]
puts "$str1"
foreach index $str1 {
                    if { [string trim $index] != "" } {
		if [string match "*Case*" $str1 ] {
                        set INFO(tcFile) [lindex [split $index ":"] 1]
			set tmp [lindex [split $INFO(tcFile) "_"] 2]
			set INFO(tcSuiteName) [string toupper $tmp]		
			regexp {_([^?][0-9]+)} $INFO(tcFile) match testCaseNumber
			append INFO(tcName) $testCaseNumber	
		}
                puts "1------------>$INFO(tcName)"
       		if [string match "*Version*" $str1 ] {
			set INFO(tcVersion) [lindex [split $index ":"] 1]		
                puts "2------------>$INFO(tcVersion)"
		}	
        	 if [string match "*Title*" $str1 ] {
                     set INFO(tcTitle) [lindex [split $index ":"] 1]
                puts "3------------>$INFO(tcTitle)"
		}	

		if [string match "*Module*" $str1 ] {		
			set txt [split $index ":"]
	               	set grp [string trim [lindex $txt 1]]         	
			set INFO(tcGroup) [lindex $grp end]
			regsub "\\)" $INFO(tcGroup) "" INFO(tcGroup)
			regsub "\\(" $INFO(tcGroup) "" INFO(tcGroup)
			set INFO(tcGroupAcronym) [lrange $grp 0 end-1]
			set tmp [split $INFO(tcGroupAcronym) "/"]
			set len [llength $tmp]
			if {$len==1} {
				set INFO(tcGroupAcronym) [lindex $tmp 0]
			} else {
				set INFO(tcGroupAcronym) [lindex $tmp 1]
			}
					
		}
                 if [string match "*Purpose*" $str1] {
                        set INFO(tcPurpose) ""
                        set txt [split $str1 ":"]
                        set INFO(tcPurpose) [string trim [lindex $txt 1]]
                        while { [gets $INFO(fdHeaderFile) line] >= 0 } {
                                if [string match "*:*" $str1] {
                                        if [string match "*Reference*" $str1] {
                                                set INFO(tcReference) ""
                                                set txt [split $str1 ":"]
                                                append INFO(tcReference) [string trim [lindex $txt 1]]
                                                while { [gets $INFO(fdHeaderFile) str1] >= 0 } {
                                                        regsub -all "#" $line "" str1
                                                        if [string match "*:*" $str1] {
                                                                if [string match "*Conformance Type*" $str1] {
                                                                        set txt  [split $str1 ":"]
                                                                        set INFO(tcType) [string trim [lindex $txt 1]]
                                                                }
                                                        } else {
                                                                append INFO(tcReference) " [string trim $str1]"
                                                        }
                                                }
                                        }
                                } else {
                                        append INFO(tcPurpose) " [string trim $str1]"
                                }
                        }
                }
          }
}
	close $INFO(fdHeaderFile)

}

proc ParseStepInformation {} {
}

proc ParseLadderInformation {} {
}

proc ParseStepInformation {} {
}

proc GetSetupNumber {} {
	global INFO
	global protocol

	set protocol [string tolower $INFO(tcSuiteName)]
	puts "protocolprotocol -- $protocol"
#	set INFO(fdSetupFile) [open "${INFO(basePath)}/Conformance_Test_Suites/Testsetup/ts_conf_${protocol}_setup_000.tcl" r]
#puts "Testscript ----> ${INFO(fdSetupFile)}"
	puts "TCFILE -> ${INFO(tcFile)}"
#	set INFO(fdSetupFile) [open "${INFO(testScriptPath)}/${INFO(tcFile)}.tcl" r]
        set INFO(fdSetupFile) [open "${INFO(testScriptPath)}/${INFO(tcFile)}" r]
	puts "Testscript ----> ${INFO(fdSetupFile)}"
	while {![eof $INFO(fdSetupFile)]} {
		set line [gets $INFO(fdSetupFile)]
                #puts "Line --->  $line"
                regexp {.*Testsetup.*: ([0-9]+)} $line match INFO(tcSetupNumber)
                #puts "Setup No. $INFO(tcSetupNumber)"
                if {"$INFO(tcSetupNumber)" != "NONE"} { 
                   break
                   }
        }
	close $INFO(fdSetupFile)
}

proc GetPortNumber {} {
	global INFO
#	set INFO(fdTestScript)    [open "${INFO(testScriptPath)}/${INFO(tcFile)}.tcl" r]	
        set INFO(fdTestScript)    [open "${INFO(testScriptPath)}/${INFO(tcFile)}" r]
	while {![eof $INFO(fdTestScript)]} {
		set txt [gets $INFO(fdTestScript)]
		if { [string match "*On I1*"  $txt] || [string match "*On P1*"  $txt] || [string match "*On T1*" $txt] } {
                	set INFO(tcPortNumbers) 1
                }
                if { [string match "*On I2*"  $txt] || [string match "*On P2*"  $txt] || [string match "*On T2*" $txt] }  {
                    set INFO(tcPortNumbers) 2	
                } 
                if { [string match "*On I3*"  $txt] || [string match "*On P3*"  $txt] || [string match "*On T3*" $txt] } {		    
                     set INFO(tcPortNumbers) 3	
                }
                if { [string match "*On I4*"  $txt] || [string match "*On P4*"  $txt] || [string match "*On T4*" $txt] } {
                    set INFO(tcPortNumbers) 4
                }
                if { [string match "*On I5*"  $txt] || [string match "*On P5*"  $txt] || [string match "*On T5*" $txt] } {
                      set INFO(tcPortNumbers) 5
                }
                if { [string match "*On I6*"  $txt] || [string match "*On P6*"  $txt] || [string match "*On T6*" $txt] } {
                    set INFO(tcPortNumbers) 6
                }
                if { [string match "*On I7*"  $txt] || [string match "*On P7*"  $txt] || [string match "*On T7*" $txt] } {
                     set INFO(tcPortNumbers) 7
                }
                if { [string match "*On I8*"  $txt] || [string match "*On P8*"  $txt] || [string match "*On T8*" $txt] } {
                    set INFO(tcPortNumbers) 8
                }
	}
	close $INFO(fdTestScript)
        set INFO(tcPortNumbers) 2
}


proc CreateTxtFile {} {
	global INFO
	global txtfileCounter
	incr txtfileCounter
	set fd [open txtFile$txtfileCounter w]
	puts $fd "---------------------------"
	puts $fd $INFO(tcName)
	puts $fd "---------------------------"
	puts $fd $INFO(tcSuiteName)
	puts $fd "---------------------------"
	puts $fd $INFO(tcFile)
	puts $fd "---------------------------"
	puts $fd $INFO(tcVersion)
	puts $fd "---------------------------"
	puts $fd $INFO(tcGroup)
	puts $fd "---------------------------"
	puts $fd $INFO(tcGroupAcronym)
	puts $fd "---------------------------"
	puts $fd $INFO(tcType)
	puts $fd "---------------------------"
	puts $fd $INFO(tcPurpose)
	puts $fd "---------------------------"
	puts $fd $INFO(tcReference)
	puts $fd "---------------------------"
	puts $fd $INFO(tcPortNumbers)
	puts $fd "---------------------------"
	puts $fd $INFO(tcSetupNumber)
	puts $fd "---------------------------"
	puts $fd $INFO(tcSetupFile)
	puts $fd "---------------------------"
	close $fd 

}
proc CreateXmlFile {} {
	global INFO
        global wFd
        global testSuiteName
        #set INFO(tcType) "G*" 
	#set fd [open tmpFile.xml w]
          set PktFileName ${INFO(tcFile)}
          set log_instance [lindex [split $PktFileName "."] 0]
          set tc_name_list [split $log_instance "_"]
          set group  [lindex $tc_name_list 3]
          set group_name [lindex [split $group "-"] 0]
          set subgroup_name [lindex [split $group "-"] 1]
          set INFO(tcType) $subgroup_name
        set fd $wFd

	######
	#Xml file generation with the parsed information
	set w1 34

	set line1 "[format "<!--  TestSuite : %-*s-->" $w1 $INFO(tcSuiteName)]"	
	set line2 "[format "<!--  TestGroup : %-*s-->" $w1 $INFO(tcGroup)]"	
	set line3 "[format "<!--  TestCase  : %-*s-->" $w1 $INFO(tcName)]"	
        set test_case_id [lindex $[split ${INFO(tcName)} "_"] 1]
        puts "testcase name----------------->${INFO(tcName)}"
        set INFO(tcName) [lindex [split ${INFO(tcName)} "."] 0]
	puts "setup------------------------------------------>${INFO(tcSetupNumber)}"
        
        puts $fd "\t<testcase>\n"         
        puts $fd "\t    <suite>${INFO(tcSuiteName)}</suite>\n"
	puts $fd "\t    <name>${INFO(tcName)}</name>\n"
	puts $fd "\t    <filename>protocol/${testSuiteName}/Testscript/${INFO(tcFile)}</filename>\n"
	puts $fd "\t    <groupname>${INFO(tcGroup)}</groupname>\n"
	puts $fd "\t    <subgroupname>${INFO(tcType)}</subgroupname>\n" 
	puts $fd "\t    <interface>${INFO(tcPortNumbers)}</interface>\n"
	puts $fd "\t    <version>${INFO(tcVersion)}</version>\n"
	puts $fd "\t    <setup>${INFO(tcSetupNumber)}</setup>\n"
#       puts $fd "\t    <eta>eta_${INFO(tcGroup)}_$test_case_id</eta>\n"	
	puts $fd "\t    <eta>300</eta>\n"	
	puts $fd "\t    <title>${INFO(tcTitle)}</title>\n"
	puts $fd "\t    <purpose>\n"
	puts $fd "\t\t<description language = \"en_US\"> ${INFO(tcPurpose)} </description>\n"
        puts $fd "\t    </purpose>\n"
	puts $fd "\t    <reference>\n"
	puts $fd "\t\t<description language = \"en_US\"> $INFO(tcReference) </description>\n"
	puts $fd "\t    </reference>\n"
	puts $fd "\t</testcase>\n"
}

proc FormatXmlFile {} {
        global wFd
	global INFO
	set rFd [open tmpFile.xml r]
	set tabPos 0
	set lineCount 0
	while {![eof $rFd]} {
		incr lineCount
		set tabLimiter ""		
		set line [gets $rFd]
		if {$lineCount <=6} {
			puts $wFd "$line"	
			continue
		}
		if [string match "*<!-- Testcase General Informaiton -->*" $line] {
			puts $wFd "$line"
			continue
		}
		if [string match "*<!-- T*" $line] {	
			puts $wFd "\t$line"
			continue
		}
		if [string match "*<TestCase*" $line] {
			set tabPos 1
			puts $wFd "$line"
			continue
		}
		if [string match "*</TestCase>*" $line] {
			puts $wFd "$line"
			continue
		}
		if [string match "*<TestcasePurpose>" $line] {
			set tabPos 2
			puts $wFd "\t$line"
			continue
		}		
		if [string match "*</TestcasePurpose>" $line] {
			set tabPos 1
			puts $wFd "\t$line"
			continue
		}		
		if [string match "*<TestcaseReference>" $line] {
			set tabPos 2
			puts $wFd "\t$line"
			continue
		}		
		if [string match "*</TestcaseReference>" $line] {
			set tabPos 1
			puts $wFd "\t$line"
			continue
		}
		if [string match "*<TestcaseTitle>*" $line] {
			puts $wFd "\t$line"
			continue
		}
		for {set i 1} {$i<=$tabPos} {incr i} {
			append tabLimiter "\t"
		}
		puts $wFd ${tabLimiter}$line	
	}
	close $rFd
#	close $wFd
	file delete -force tmpFile.xml

}
proc StartBaseConversion {} {
	setTestcaseEnvironment
	SplitHeaders
	ParseGeneralInformation
	GetSetupNumber
	GetPortNumber
#	CreateTxtFile	
	CreateXmlFile
#	FormatXmlFile
}

proc FormatSetupFile {} {

	global INFO
	global protocol
	set srcDir $INFO(basePath)/Conformance_Test_Suites/Testsetup
    set dstDir $INFO(basePath)/Config/. 
	

	if {[catch {exec cp  -r $srcDir $dstDir } err]} {
		puts "Not able to copy the test setup files : $err "
	} else {
    }

	if {[catch {file delete -force $dstDir/Testsetup/ts_conf_${protocol}_setup_000.tcl} err]} {
		puts "Not able to delete the setup 000  file : $err"
	} else {
	}

# Here fix is added, because the setup files in Config/Testsetup is empty
   if {0} {
  
	foreach f [lsort -dictionary [glob -nocomplain [file join "$INFO(basePath)/Config/Testsetup" *]]] {	

		set srcFile [lindex [split $f /] end]
		set tmpFile tmp_${srcFile}
  	    set fdTestSetup [open $f r]
		set fdTemp [open $INFO(basePath)/Config/Testsetup/$tmpFile w]   
        set hashDelimiterCount 0
		set line [gets $fdTestSetup]
		while {![eof $fdTestSetup]} {

			set line [gets $INFO(fdTestScript)]
	      	if [string match "*Copyright*" $line] {
				break
			}
			if [string match "*########################*" $line] {	 
        		set line [gets $INFO(fdTestScript)]
				incr hashDelimiterCount
	        }

	        switch $hashDelimiterCount {
			    "2" {
					 regsub -all "#" $line "" line
					 puts $fdTemp $line 
			    } 
	        }
        }  

		close $fdTestSetup
		close $fdTemp

		if {[catch {file delete -force $f} err]} {
			puts "Not able to delete the the previous setup file $srcFile"
			puts "Error : $err"
		} else {
			puts "Successfully deleted the previous setupfile $srcFile"
		}	

	if {[catch {file rename -force $INFO(basePath)/Config/Testsetup/$tmpFile $INFO(basePath)/Config/Testsetup/$srcFile} err]} {
			puts "Not able to rename the setupfile $tmpFile"
			puts "Error: $err"			
		} else {
			puts "Successfully renamed the setup file $tmpFile to $srcFile"
		}
				
	}

}
	
}
proc ReadTheScripts {} {
	global txtfileCounter
	global xmlfileCounter
	set txtfileCounter 0
	set xmlfileCounter 0
	global INFO
	foreach f [lsort -dictionary [glob -nocomplain [file join "$INFO(basePath)/Conformance_Test_Suites/Testscript" *]]] {	
		if {[file isfile $f]} {
			if { [regexp {tcl} $f] } {					
				puts "The value of file ::: $f"
				set tmp [split $f "/"]
				set INFO(tcFile) [string trim [lindex $tmp end]]
				puts "Processing the file : $INFO(tcFile)"
				StartBaseConversion 
			}	
		}
	}

}
ReadTheScripts
FormatSetupFile

global wFd
close $wFd
