#!/bin/bash
set -e

./download.sh "$3"

# scril values appear in formats like 2k, 2000, 1:2000 but also with a padding at the end
# https://gdal.org/en/stable/user/ogr_sql_dialect.html
./filter.sh "${1}_scril_2k" "$2" "meta_ist != '03' and (scril in ('2k','2000') or scril like '1:2000%')" "$3"
./filter.sh "${1}_scril_5k" "$2" "meta_ist != '03' and (scril in ('5k','5000') or scril like '1:5000%')" "$3"
./filter.sh "${1}_scril_10k" "$2" "meta_ist != '03' and (scril in ('10k','10000') or scril like '1:10000%')" "$3"
./filter.sh "${1}_scril_25k" "$2" "meta_ist != '03' and (scril in ('25k','25000') or scril like '1:25000%')" "$3"
./filter.sh "${1}_scril_unk" "$2" "meta_ist != '03' and scril not in ('2k','2000','5k','5000','10k','10000','25k','25000') and scril not like '1:%000%'" "$3"

#./merge.sh "${1}_scril_2k"
#./merge.sh "${1}_scril_5k"
#./merge.sh "${1}_scril_10k"
#./merge.sh "${1}_scril_25k"
#./merge.sh "${1}_scril_unk"
