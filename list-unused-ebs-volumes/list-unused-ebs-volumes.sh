#!/bin/bash

# Safety feature: exit script if error is returned, or if variables not set.
# Exit if a pipeline results in an error.
set -ue
set -o pipefail

## Create a report of unattached ('Available' state) EBS volumes.
#
# Written by Babu Srinivasan https://www.linkedin.com/in/babu-srinivasan
# Github repository: https://github.com/bvasan/aws-scripts
#
# Credits: 1.CaseyLabs  2.Log function by Alan Franzoni 3. Pre-req check by Colin Johnson
# 
# Check README file in the repository for additional information on the script
#
# This bash script can be used to generate a list of EBS volumes in "Available" status and send the report i
# via email. The script can be # run manually or scheduled via cron. The script uses AWS SES to send email - i
# ensure that the AWS SES is setup correctly in your AWS account (as documented by AWS) to send emails.
# 
# DISCLAIMER: Ensure that you understand how the script works. Author accepts no responsibility for any data loss
#  or any damages. Please note that the script creates/uses AWS resources in the AWS account
#  where this is executed. Author accepts no responsibility for any charges this may incur in the AWS account
#  where the script is executed.
#

## Variables ##
outputfile="available-volumes.html"
outputfile_max_lines="5000"
emailfrom="********" # UPDATE YOUR FROM EMAIL ID here
emailto="**********" # UPDATE YOUR EMAIL ID here 
emailcc="**********" # UPDATE YOUR EMAIL ID here 
emailbody=" "
emailsubject="List of 'Available' EBS Volumes - Weekly report "$(date) 

## Function Declarations ##

# Function: Setup logfile and redirect stdout/stderr.
log_setup() {
    # Check if logfile exists and is writable.
    ( [ -e "$outputfile" ] || touch "$outputfile" ) && [ ! -w "$outputfile" ] && echo "ERROR: Cannot write to $outputfile. Check permissions or sudo access." && exit 1

    tmplog=$(tail -n $outputfile_max_lines $outputfile 2>/dev/null) && echo "${tmplog}" > $outputfile
    exec > >(tee -a $outputfile)
    exec 2>&1
}

# Function: Log an event.
log() {
    echo "$*" 
    emailbody=$emailbody"$*"
}

prerequisite_check() {
    for prerequisite in aws ; do
        hash $prerequisite &> /dev/null
        if [[ $? == 1 ]]; then
            echo "In order to use this script, the executable \"$prerequisite\" must be installed." 1>&2; exit 70
        fi
    done
}


############### Main Program ####################

log_setup
prerequisite_check

log "<br/> "
log "<br/>----Weekly Available volumes report - "$(date +%Y-%m-%d" "%H:%M)" ----"

volume_list=$(aws ec2 describe-volumes --filters Name=status,Values='available' --query Volumes[].VolumeId --output text)
vol_count=$(wc -w <<< "$volume_list")

if [[ $vol_count -gt  0 ]]; then
    log "<br/> "
    log "<br/>There are <b><i>"$vol_count" unused volumes.</i></b> Please review the list and cleanup"
    log "<table style="border:1px width:100%">"
    log " <tr>"
    log "  <th style="width:80%">Volume ID</th>"
    log "  <th style="width:20%">Size</th>"
    log " </tr>"

    txtline=" "
    while read txtline
    do
        txtwords=( $txtline )
        tblrow="<tr> <td>"${txtwords[0]}"</td><td>"${txtwords[1]}"</td></tr>"
        log $tblrow
    done <<< "$(aws ec2 describe-volumes --filters Name=status,Values='available' --query Volumes[].[VolumeId,Size] --output text | awk '{print  $1 "    " $2 "G"}')"
    log "</table>"
else
    log "<br/> "
    log "<br/>There are no unused volumes to review! "
    log "<br/> "
fi
log "<br/>----End of Weekly Report - "$(date +%Y-%m-%d" "%H:%M)" ----<br/>"
aws ses send-email --from """$emailfrom""" --to """$emailto""" --cc """$emailcc""" --subject """$emailsubject""" --html """$emailbody""" 
