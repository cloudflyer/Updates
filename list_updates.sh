#!/bin/env bash
deb="ubuntu01 ubuntu02"
rpm="centos01"

sp='/-\|'
sc=0
spin() {
    printf "\b${sp:sc++:1}"
    ((sc==${#sp})) && sc=0
    sleep 0.1
}
endspin() {
    printf '\r%s\n' "$*"
    sleep 0.1
}

read -s -p "Enter Password: " mypassword
echo ""
for i in $deb; do
  spin
  echo $mypassword | ssh -T $i.home "DEBIAN_FRONTEND=noninteractive sudo -S apt-get -qq update >/dev/null 2>&1 & disown"
done
sleep 3
endspin
for i in $deb; do
  echo $i
  ssh -T $i.home "DEBIAN_FRONTEND=noninteractive apt-show-versions -u"
  echo ""
done
for i in $rpm; do
  echo $i
  ssh $i.home "dnf check-update || yum check-update"
  echo ""
done
exit 0
