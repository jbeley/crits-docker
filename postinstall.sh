#!/bin/bash

set -e -u

set -x

CRITS_INSTALL=/data/crits_services.unused
CRITS_SERVICES=/data/crits_services

bash $CRITS_INSTALL/bootstrap
apt-get -qq -yremove yara


for i in \
    carver_service \
    chminfo_service \
    chopshop_service \
    clamd_service \
    crits_scripts \
    cuckoo_service \
    data_miner_service \
    diffie_service \
    entropycalc_service \
    exiftool_service \
    impfuzzy_service \
    machoinfo_service \
    macro_extract_service \
    maliciousmacrobot_service \
    malshare_service \
    metacap_service \
    office_meta_service \
    passivetotal_service \
    pdf2txt_service \
    pdfinfo_service \
    peinfo_service \
    prettythings \
    preview_service \
    pyinstaller_service \
    ratdecoder_service \
    relationships_service \
    rtfmeta_service \
    shodan_service \
    ssdeep_service \
    stix_validator_service \
    taxii_service \
    timeline_service \
    unswf_service \
    upx_service \
    virustotal_download_service \
    virustotal_service \
    whois_service \
    xforce_exchange \
    yara_service \
    zip_meta_service
do
    ln -sf $CRITS_INSTALL/$i $CRITS_SERVICES
    if [ -f $CRITS_SERVICES/$i/requirements.txt ]; then
        pip install -r   $CRITS_SERVICES/$i/requirements.txt
    fi

done

pip install \
    passivetotal==1.0.23 \
    ipwhois