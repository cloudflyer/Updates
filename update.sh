#!/bin/env bash

PROGNAME=${0##*/}

if test "$*" = "-?" -o "$*" = "-h" -o "$*" = "-help" -o "$*" = "--help" -o "x$*" = "x"
   then cat <<-ENDHELP                  # print file until ENDHELP
# -------------------------------------------------------------------------------
# ScriptName  : $PROGNAME
# Description :
#
#       This script will update the OS on:
#       A specific server          (-deb server1)
#       All debian based servers   (-deb all)
#       All redhat based servers   (-rpm all)
#       All server                 (-all)
#
# Usage : $PROGNAME [-?][-test]
#
#       Where:
#       -test           Run without changing anything
#       -?|-h           This help
#       -[argument]     ex. -deb server1
#
# -------------------------------------------------------------------------------
ENDHELP
exit 0
fi

# --- HISTORY -------------------------------------------------------------------
# Changes:
#       Version yymmdd Who Changes - latest version first
#       1.0     190605 TGJ Original
#       1.1     200202 TGJ Switched yum to dnf
#       1.2     211112 TGJ Re-added yum support
#
# --- MAIN PROGRAM --------------------------------------------------------------

deb="ubuntu01 ubuntu02"
rpm="centos01"

if [[ $1 == -all ]]; then
   if [ $# -eq 1 ]; then
     read -s -p "Enter Password: " mypassword
     echo ""
     echo "Patching: $deb "
     for i in $deb; do
       echo $i
       echo $mypassword | ssh -T $i.home "DEBIAN_FRONTEND=noninteractive sudo -S sh -c 'apt-get -qq update && apt-show-versions -u && apt-get upgrade -y && if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; fi'"
       echo ""
     done
     echo "Patching: $rpm "
     for i in $rpm; do
       echo $i
       echo $mypassword | ssh -T $i.home "sudo -S -sh -c 'dnf check-update && dnf upgrade -y && needs-restarting  -r ; echo $?'"
       echo ""
     done
   fi
shift
exit 0
fi

while [ $# -gt 1 ]; do
   case "$1" in
        -test)
                echo test
                shift
        ;;
        -deb)
           if [ $# -eq 2 ]; then
              if [ $2 = "all" ]; then
                 read -s -p "Enter Password: " mypassword
                 echo ""
                 for i in $deb; do
                    echo $i
                    echo $mypassword | ssh -T $i.home "DEBIAN_FRONTEND=noninteractive sudo -S sh -c 'apt-get -qq update && apt-show-versions -u && apt-get upgrade -y && if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; fi'"
                    echo ""
                 done
              else
                 read -s -p "Enter Password for $2: " mypassword
                 echo ""
                 if ssh $2.home 'test -f "/usr/bin/apt"'; then
                    echo $mypassword | ssh -T $2.home "DEBIAN_FRONTEND=noninteractive sudo -S sh -c 'apt-get -qq update && apt-show-versions -u && apt-get upgrade -y && if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; fi'"
                    echo ""
                 else
                    echo "Unable to run the apt-command, is this a debian-based server? "
                    exit 1
                 fi
              fi
           else
              echo "You need to enter an argument after '-deb' "
              echo "Ex. -deb server1 "
              exit 1
           fi
        shift
        shift
        ;;
        -rpm)
           if [ $# -eq 2 ]; then
              if [ $2 = "all" ]; then
                 read -s -p "Enter Password: " mypassword
                 echo ""
                 for i in $rpm; do
                    echo $i
                    if ssh $i.home 'test -f "/usr/bin/dnf"'; then
                       echo $mypassword | ssh -T $i.home "sudo -S sh -c 'dnf check-update && dnf update -y && needs-restarting  -r ; echo $?'"
                       echo ""
                    else
                       echo $mypassword | ssh -T $i.home "sudo -S sh -c 'yum check-update && yum update -y && needs-restarting  -r ; echo $?'"
                       echo ""
                    fi
                 done
              else
                 read -s -p "Enter Password for $2: " mypassword
                 echo ""
                 if ssh $2.home 'test -f "/usr/bin/dnf"'; then
                    echo $mypassword | ssh -T $2.home "sudo -S sh -c 'dnf check-update && dnf update -y && needs-restarting -r ; echo $?'"
                    echo ""
                 elif ssh $2.home 'test -f "/usr/bin/yum"'; then
                    echo $mypassword | ssh -T $2.home "sudo -S sh -c 'yum check-update && yum update -y && needs-restarting -r ; echo $?'"
                    echo ""
                 else
                    echo "Unable to run the dnf/yum command, is this a redhat-based server? "
                    exit 1
                 fi
              fi
           else
              echo "You need to enter an argument after '-rpm' "
              echo "Ex. -rpm server1 "
              exit 1
           fi
        shift
        shift
        ;;
        *)
           exit 1
        ;;
   esac
done
exit 0
