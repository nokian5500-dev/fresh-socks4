#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please Run as Root"
 exit
fi
trap 'rm -drf $temp_dir' EXIT 
temp_dir=$(mktemp -d)|| exit 1
echo "our temp file directory is $temp_dir"
checkedsocks=$(mktemp -p $temp_dir)
dirtysocks=$(mktemp -p $temp_dir)
laundrybag=$(mktemp -p $temp_dir)
cleansocks=$(mktemp -p $temp_dir)
#	Grab a fresh Socks4 proxy list from TheSpeedX's Github
curl 'https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks4.txt' -o $laundrybag --silent ; 
sed -i -e 1,2d $laundrybag #Cutting out Comment
#	Grab 100 Hosts from the laundrybag and save them to dirtysocks
shuf -n 100 $laundrybag | sed -e ':a' -e 'N' -e '$!ba' -e 's/:/%3A/g' -e 's/\n/%0A/g' > $dirtysocks #Format dirtysocks for the hidemy.name/api to check
#	Passing out data to hidemy.name/api
curl -d "data=$(cat $dirtysocks)" -X POST 'https://hidemy.name/api/checker.php?out=js&action=list_new&tasks=socks4&parser=lines' --silent | sed -e 's/^.*:/ /g' -e 's|[}]||g' | tr -d " " | tee $checkedsocks
sleep 1.8m
##	Grab file of responsive proxies from Hideme.name/api
wget -O $cleansocks "https://hidemy.name/api/checker.php?out=plain&action=export&working&groups=$(cat $checkedsocks)"
##	Format proxies for ProxyChains.conf 
sed -i -e 's/^/socks4 /' -e 's/:/ /' $cleansocks
## W4rn1ng this is a personal configuration for MY BOX 
sed -i 116q /etc/proxychains4.conf 
cat $cleansocks >> /etc/proxychains4.conf\