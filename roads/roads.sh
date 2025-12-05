#!/bin/bash
set -e
cd $(dirname "$0")/..

./download.sh

./filter.sh tr_str_no_osm tr_str "meta_ist != '03'"
./filter.sh el_vms_no_osm el_vms "meta_ist != '03'"

./merge.sh tr_str_no_osm pmtiles
./merge.sh el_vms_no_osm pmtiles
