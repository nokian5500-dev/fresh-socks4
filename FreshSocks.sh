!#/bin/bash

# Creating our files so bash doesn't yell at us 
touch checkedsocks
touch dirtysocks

#This is place holder text 
# Will add something here that begins out tor service
# and update our proxychains config file
# with fresh proxies
		#Grab a fresh proxy list from github For Socks4 Proxies
		curl 'https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks4.txt' -o laundrybag --silent ; 
		echo "$(tail -n +2 laundrybag)" > laundrybag  #Cutting out Comments
	# Grab 100 Hosts from the laundrybag and save them to dirtysocks
	shuf -n 100 laundrybag | tee dirtysocks
	# Format dirtysocks for the hidemy.name/api to check
	sed -i -e ':a' -e 'N' -e '$!ba' -e 's/:/%3A/g' -e 's/\n/%0A/g' dirtysocks

dirtysocks=$(cat dirtysocks)
# Passing out data to hidemy.name/api
curl -d "data=$dirtysocks" -X POST 'https://hidemy.name/api/checker.php?out=js&action=list_new&tasks=socks4&parser=lines' --silent | sed -e 's/^.*:/ /g' -e 's|[}]||g' | tee checkedsocks

checkedsocks=$(cat checkedsocks | tr -d " " ) 	# Removing spaces so the API is happy

sleep 1.8m

# Grab file of responsive proxies from Hideme.name/api
wget -O cleansocks "https://hidemy.name/api/checker.php?out=plain&action=export&working&groups=$checkedsocks"

		#Format proxies for ProxyChains.conf 
		sed -i -e 's/^/SOCKS /' -e 's/:/ /' cleansocks

######################################
# Now comes the hard part of figuring out how to
# Let proxychains come in contact with the data
# Do I want to let this script run as root ? 
# Do I want to let it have write permissions to my /etc/proxychains.conf
# Can I only allow it permissions for that file ? 
#  How do I get the OLD Proxies out of the .conf  ?