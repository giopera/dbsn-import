#!/bin/bash
set -e

# Usage: ./download.sh [<nome_regione_o_provincia>]

AREA_NAME="$1"

ZIP_DIR_PATH="$(dirname "$0")/zip"


mkdir -p "$ZIP_DIR_PATH"

while IFS=$'\t' read -r region province file_name wmit_url igm_url igm_date latest ; do
    if [[ "$file_name" == "File" || "$latest" != "yes" ]]; then
        # Skip header line and old files
        #echo "===> $region/$province/$igm_date: SKIPPED"
        continue
    fi

    # ${var,,} makes the value lowercase, used for case insensitive comparison
    if [[ -n "$AREA_NAME" && "${province,,}" != "${AREA_NAME,,}" && "${region,,}" != "${AREA_NAME,,}" && "${file_name:0:2}" != "${AREA_NAME^^}" ]]; then
        #echo "===> $region/$province/$igm_date: SKIPPED"
        continue
    fi

    file_path="$ZIP_DIR_PATH/$file_name"
    if [[ -f "$file_path" ]]; then
        echo "===> $region/$province/$igm_date: Already downloaded in '$file_path'"
    else
        [[ "$wmit_url" == "TODO" ]] && url="$igm_url" || url="$wmit_url"
        echo "===> $region/$province/$igm_date: Downloading from $url"
        curl --fail --output "$file_path" "$url" && \
            echo "===> $region/$province/$igm_date: Download of '$file_path' COMPLETED" || \
            echo "===> $region/$province/$igm_date: Download of '$file_path' FAILED"
    fi
done < ./dbsn.tsv

echo "===> Download in $ZIP_DIR_PATH completed"