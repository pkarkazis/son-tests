#!/bin/bash
#printf "\n\n======== POST SON Package to Catalogue ========\n\n\n"
#resp=$(curl -qSfsw '\n%{http_code}' -H 'content-disposition: attachment; filename=sonata_example.son' \
#  -H 'content-type: application/zip' \
#  -F "package=@resources/sonata-demo.son" -X POST http://sp.int3.sonata-nfv.eu:4002/catalogues/son-packages)
#echo $resp

#package=$(echo $resp | grep "uuid")
#echo "UUID: $package"

#code=$(echo "$resp" | tail -n1)
#echo "Code: $code"

printf "\n\n======== GET Package UUID and SON_PACKAGE_UUID from Gatekeeper  ========\n\n\n"
resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/json" -X GET http://sp.int3.sonata-nfv.eu:32001/api/v2/packages) 2>/dev/null
echo $resp

package=$(echo "$resp" | head -n-1)
son_package_uuid=$(echo $package  |  python -mjson.tool | grep -w "son_package_uuid" | awk -F'[=:]' '{print $2}' | sed 's/\"//g' | tr -d ',' | tr -d '[:space:]')
uuid=$(echo $package  |  python -mjson.tool | grep -w "uuid" | awk -F'[=:]' '{print $2}' | sed 's/\"//g' | tr -d ',' | tr -d '[:space:]')
echo "SON_PACKAGE_UUID: $son_package_uuid"
echo "UUID: $uuid"

printf "\n\n======== GET Package from Gatekeeper ========\n\n\n"
#url=$(echo http://sp.int3.sonata-nfv.eu:32001/packages/${uuid})
#echo "URL: $url"
resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/json" -X GET http://sp.int3.sonata-nfv.eu:32001/api/v2/packages/${uuid}) 2>/dev/null
echo $resp

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 200 ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

printf "\n\n======== GET SON Package from Gatekeeper ========\n\n\n"
#url=$(echo http://sp.int3.sonata-nfv.eu:32001/packages/${uuid})
#echo "URL: $url"
#resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/json" -X GET http://sp.int3.sonata-nfv.eu:32001/api/v2/son-packages/${son_package_uuid}/) 2>/dev/null
resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/json" -X GET http://sp.int3.sonata-nfv.eu:32001/api/v2/packages/${uuid}/download) 2>/dev/null
echo $resp

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 200 ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

printf "\n\n======== GET SON Package UUID from Catalogue  ========\n\n\n"
resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/json" -X GET http://sp.int3.sonata-nfv.eu:4002/catalogues/api/v2/son-packages) 2>/dev/null
echo $resp

package=$(echo "$resp" | head -n-1)
son_package_uuid=$(echo $package  |  python -mjson.tool | grep -w "uuid" | awk -F'[=:]' '{print $2}' | sed 's/\"//g' | tr -d ',' | tr -d '[:space:]')
echo "SON_PACKAGE_UUID: $son_package_uuid"

printf "\n\n======== GET SON Package from Catalogue ========\n\n\n"
#url=$(echo http://sp.int3.sonata-nfv.eu:4002/catalogues/son-packages/${uuid})
#echo "URL: $url"
resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/zip" -X GET http://sp.int3.sonata-nfv.eu:4002/catalogues/api/v2/son-packages/${son_package_uuid}) 2>/dev/null
echo $resp

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 200 ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

