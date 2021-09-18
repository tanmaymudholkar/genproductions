#!/bin/bash

set -e

MCM_ID=${1}
IDENTIFIER=${2}
XSEC_SCRAM_ARCH=${3}
PATH_XSEC_CMSSW=${4}
PATH_XSEC_SCRIPTS=${5}

echo "Called with MCM_ID: ${MCM_ID}, IDENTIFIER=${IDENTIFIER}, XSEC_SCRAM_ARCH=${XSEC_SCRAM_ARCH}, PATH_XSEC_CMSSW=${PATH_XSEC_CMSSW}, PATH_XSEC_SCRIPTS=${PATH_XSEC_SCRIPTS}"

export X509_USER_PROXY=${HOME}/private/x509up_u$(id -u)
export KRB5CCNAME=DIR:/afs/cern.ch/user/t/tmudholk/private/krbCacheCollection

cern-get-sso-cookie -u https://cms-pdmv-dev.cern.ch/mcm/ -o ~/private/dev-cookie.txt --krb --reprocess
cern-get-sso-cookie -u https://cms-pdmv.cern.ch/mcm/ -o ~/private/prod-cookie.txt --krb --reprocess
source /afs/cern.ch/cms/PPD/PdmV/tools/McM/getCookie.sh

export SCRAM_ARCH=${XSEC_SCRAM_ARCH}
cd ${PATH_XSEC_CMSSW}
source /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scramv1 runtime -sh`
cd ${PATH_XSEC_SCRIPTS}

rm -f datasets_${IDENTIFIER}_mcm.txt && touch datasets_${IDENTIFIER}_mcm.txt
echo ${MCM_ID} >> datasets_${IDENTIFIER}_mcm.txt

./calculateXSectionAndFilterEfficiency.sh -f datasets_${IDENTIFIER}_mcm.txt -m -n 1000000
rm -f datasets_${IDENTIFIER}_mcm.txt
