#!/bin/env bash

PROGNAME="autoremove.sh"

if test "$*" = "-?" -o "$*" = "-h" -o "$*" = "-help" -o "$*" = "--help" -o "x$*" = "x"
   then cat <<-ENDHELP                  # print file until ENDHELP
# -------------------------------------------------------------------------------
# ScriptName  : $PROGNAME
# Description :
#
#       This script will update the OS on:
#       A specific server          (-deb server1)
#       All debian based servers   (-deb all)
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
                    echo $mypassword | ssh -T $i.home "sudo -S apt-get autoremove -y"
                    echo ""
                 done
              else
                 read -s -p "Enter sudo password for $2: " mypassword
                 echo ""
                 if ssh $2.home 'test -f "/usr/bin/apt"'; then
                    echo $mypassword | ssh -T $2.home "sudo -S apt-get autoremove -y"
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
        *)
           exit 1
        ;;
   esac
done
exit 0
