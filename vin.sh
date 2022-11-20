#! /bin/bash
set -eou pipefail
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
cat /dev/null > /home/output.log
# Make sure one make is entered as a parameter.
printf "Verifying if expected Make parameter was entered.\n" >> /home/output.log
if [ "$#" -ne 1 ]; then
    printf "Illegal number of parameters.\n" | tee -a /home/output.log
    printf "Please see the README.md for usage instructions.\n" | tee -a /home/output.log
    exit 1
fi
# Convert make to Uppercase for processing
printf "Sanatizing input\n" >> /home/output.log
upper_make_str=$(echo $1 | tr '[:lower:]' '[:upper:]')
echo "Searching to find a vin for a ${upper_make_str}." >> /home/output.log
# Get a random VIN
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
printf "Starting ...\n" | tee -a /home/output.log
{
  for i in {1..30}
  do
    VIN=$(getvin) #get random VIN
    VINDATA=`curl --silent https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/\${VIN}\?format\=json` #Decode VIN
    MAKE_RESULT=`jq -r '.Results[0] | .Make' <<< $VINDATA` #Extract Make from decoded VIN
    echo  "[${i}]. Found vin where  make is ${MAKE_RESULT} and the vin is ${VIN}" >> /home/output.log
    #Check if the Make of vehicle from random vin is the same as the Make we are searching to find.
    if [[ $MAKE_RESULT == $upper_make_str ]]
    then
      printf  "[${i}]. ${GREEN}Found a match for make ${MAKE_RESULT} a vin for this make is ${VIN}.${NC}\n" # If the make is correct then output and exit script.
      exit 0
    fi
  done
  printf "${RED}Unable to find a match after 30 attempts. Try again.${NC}\n"
  exit 1
} 2>&1 | tee -a /home/output.log
