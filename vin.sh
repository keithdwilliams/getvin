#! /bin/bash
set -eou pipefail
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit
fi
upper_make_str=$(echo $1 | tr '[:lower:]' '[:upper:]')
echo "${upper_make_str}"
function getvin {
  GETVIN=`curl --silent 'https://randomvin.com/getvin.php?type=real' \
    -H 'authority: randomvin.com' \
    -H 'accept: */*' \
    -H 'accept-language: en,en-US;q=0.9' \
    -H 'cookie: _ga=GA1.2.1848968986.1668118496; _gid=GA1.2.430484294.1668118496; _gat=1' \
    -H 'dnt: 1' \
    -H 'referer: https://randomvin.com/' \
    -H 'sec-ch-ua: "Google Chrome";v="107", "Chromium";v="107", "Not=A?Brand";v="24"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "macOS"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36'`
  echo "${GETVIN}"
}
for i in {1..30}
do
  VIN=$(getvin)
  VINDATA=`curl --silent https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/\${VIN}\?format\=json`
  MAKE_RESULT=`jq -r '.Results[0] | .Make' <<< $VINDATA`
  if [[ $MAKE_RESULT == $upper_make_str ]]
  then
    echo  "The make is ${MAKE_RESULT} and the vin is ${VIN}"
    exit
  fi 
done
echo "Unable to find a match"

