#!/bin/env bash

PROGNAME="update.sh"

if test "$*" = "-?" -o "$*" = "-h" -o "$*" = "-help" -o "$*" = "--help" -o "x$*" = "x"
   then cat <<-ENDHELP                  # print file until ENDHELP
# -------------------------------------------------------------------------------
# ScriptName  : $PROGNAME
# Description :
#
#       This script will update the OS on:
#       A specific server          (-deb server1)
#       All debian based servers   (-deb all)
#       All redhat based servers   (-dnf all)
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
#       1.0     YYMMDD XXX Original
#
# --- MAIN PROGRAM --------------------------------------------------------------

deb="ubuntu01 ubuntu02"
dnf="centos01"

if [[ $1 == -all ]]; then
   if [ $# -eq 1 ]; then
     read -s -p "Enter sudo password: " mypassword
     echo ""
     echo "Patching: $deb "
     for i in $deb; do
       echo $i
       echo $mypassword | ssh -T $i.home "sudo -S apt-get -qq update"
       #echo $mypassword | ssh -T $i.home "sudo -S apt list --upgradable"
       echo $mypassword | ssh -T $i.home "sudo -S apt-show-versions -u"
       echo $mypassword | ssh -T $i.home "sudo -S apt-get upgrade -y"
       echo $mypassword | ssh -T $i.home "if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; fi"
       echo ""
     done
     echo "Patching: $dnf "
     for i in $dnf; do
       echo $i
       echo $mypassword | ssh -T $i.home "sudo -S dnf check-update"
       echo $mypassword | ssh -T $i.home "sudo -S dnf update -y"
       echo $mypassword | ssh -T $i.home "sudo -S needs-restarting  -r ; echo $?"
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
                 read -s -p "Enter sudo password: " mypassword
                 echo ""
                 for i in $deb; do
                    echo $i
                    echo $mypassword | ssh -T $i.home "sudo -S apt-get -qq update"
                    #echo $mypassword | ssh -T $i.home "sudo -S apt list --upgradable"
                    echo $mypassword | ssh -T $i.home "sudo -S apt-show-versions -u"
                    echo $mypassword | ssh -T $i.home "sudo -S apt-get upgrade -y"
                    echo $mypassword | ssh -T $i.home "if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; fi"
                    echo ""
                 done
              else
                 read -s -p "Enter sudo password for $2: " mypassword
                 echo ""
                 if ssh $2.home 'test -f "/usr/bin/apt"'; then
                    echo $mypassword | ssh -T $2.home "sudo -S apt-get -qq update"
                    #echo $mypassword | ssh -T $2.home "sudo -S apt list --upgradable"
                    echo $mypassword | ssh -T $2.home "sudo -S apt-show-versions -u"
                    echo $mypassword | ssh -T $2.home "sudo -S apt-get upgrade -y"
                    echo $mypassword | ssh -T $2.home "if [ -f /var/run/reboot-required ]; then cat /var/run/reboot-required; fi"
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
        -dnf)
           if [ $# -eq 2 ]; then
              if [ $2 = "all" ]; then
                 read -s -p "Enter sudo password: " mypassword
                 echo ""
                 for i in $dnf; do
                    echo $i
                    echo $mypassword | ssh -T $i.home "sudo -S dnf check-update"
                    echo $mypassword | ssh -T $i.home "sudo -S dnf update -y"
                    echo $mypassword | ssh -T $i.home "sudo -S needs-restarting  -r ; echo $?"
                    echo ""
                 done
              else
                 read -s -p "Enter sudo password for $2: " mypassword
                 echo ""
                 if ssh $2.home 'test -f "/usr/bin/dnf"'; then
                    echo $mypassword | ssh -T $2.home "sudo -S dnf check-update"
                    echo $mypassword | ssh -T $2.home "sudo -S dnf update -y"
                    echo $mypassword | ssh -T $2.home "sudo -S needs-restarting  -r ; echo $?"
                    echo ""
                 else
                    echo "Unable to run the dnf-command, is this a redhat-based server? "
                    exit 1
                 fi
              fi
           else
              echo "You need to enter an argument after '-dnf' "
              echo "Ex. -dnf server1 "
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
