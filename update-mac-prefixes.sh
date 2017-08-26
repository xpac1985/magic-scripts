#!/bin/sh

### make this a cron job to have nmap and arpwatch MAC prefix databases updated, if they exist

url="http://standards-oui.ieee.org/oui/oui.txt"
nmap="/usr/share/nmap/nmap-mac-prefixes"
arpwatch="/usr/share/arpwatch/ethercodes.dat"

echo "Starting MAC prefix update, downloading from $url"
curl -s $url > /tmp/oui.txt
echo "Download successful, preparing file"
grep '(base 16)' /tmp/oui.txt | sed 's/(base 16)/ /; s/\t/ /g' | tr -s ' ' | sort > /tmp/oui.txt.sort

if ( [ -e "$nmap" ] && [ -f "$nmap" ] )
then
  echo "Moving old nmap MAC database"
  mv -f "$nmap" "$nmap.old"
  cp -f /tmp/oui.txt.sort "$nmap"
  echo "Updated nmap MAC database with `cat \"$nmap\" | wc -l` prefixes"
fi

if ( [ -e "$arpwatch" ] && [ -f "$arpwatch" ] )
then
  echo "Moving old arpwatch MAC database"
  mv -f "$arpwatch" "$arpwatch.old"
  sed -r 's/^(([^0].)|0(.))(([^0].)|0(.))(([^0].)|0(.)) /\2\3:\5\6:\8\9\t/' < /tmp/oui.txt.sort > "$arpwatch"
  echo "Updated arpwatch MAC database with `cat \"$arpwatch\" | wc -l` prefixes"
fi
