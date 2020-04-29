#!/bin/env bash
deb="ubuntu01 ubuntu02"
dnf="centos01"

read -s -p "Enter sudo password: " mypassword
echo ""
for i in $deb; do
  echo $i
  echo $mypassword | ssh -T $i.home "sudo -S apt-get -qq update"
  #ssh $i.home "apt list --upgradable"
  ssh -T $i.home "apt-show-versions -u"
  echo ""
done
for i in $dnf; do
  echo $i
  ssh $i.home "dnf check-update"
  echo ""
done
exit 0
