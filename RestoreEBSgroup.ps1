# This script is designed to restore an EBS or EBS-group using the 
# value in the snapshots' "Name" tag:
# * If the snapshots' "Name" tags are not set, this script will fail
# * If the name-value passed to the script is not an exact-match for 
#   any snapshots' "Name" tag, this script will fail
#
# Note: this script assumes that you are attaching an EBS to an
#       existing instance, either with the intention to recover 
#       individual files or to act as a full restore of a damaged 
#       or destroyed EBS. The full restore may be made available
#       on a new instance or on the instance that originally
#       generated the EBS snapshot.
#
# Dependencies:
# - Generic: See the top-level README_dependencies.md for script dependencies
# - Specific:
#   * All snapshots - or groups of snapshots - to be restored via this
#     script must have a unique "Name" tag (at least within the scope
#     of an Amazon region). Non-unique "Name" tags will result in
#     collisions during restores
#
# License:
# - This script released under the Apache 2.0 OSS License
#
######################################################################

Commandline arguments parsing
Param (
   [string]$congrp = $(throw "-congrp is required")
)

# Set generic variables
$DateStmp = $(get-date -format "yyyyMMddHHmm")
$LogDir = "C:/TEMP/EBSbackup"
$LogFile = "${LogDir}/backup-$DateStmp.log"
$instMetaRoot = "http://169.254.169.254/latest/"

# Make sure AWS cmdlets are available
Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"


# Capture instance identy "document" data
$docStruct = Invoke-RestMethod -Uri ${instMetaRoot}/dynamic/instance-identity/document/

# Extract info from $docStruct
$instRegion = $docStruct.region
$instId = $docStruct.instanceId