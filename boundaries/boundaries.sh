#!/bin/bash
set -e
cd $(dirname "$0")/..

./download.sh

./filter.sh comune_no_osm comune "meta_ist != '03'"
#./filter.sh comune_osm comune "meta_ist = '03'"
#./filter.sh stato_no_osm stato "meta_ist != '03'"
./filter.sh acq_ter_no_osm acq_ter "meta_ist != '03'"

./merge.sh comune_no_osm pmtiles
./merge.sh comune_no_osm fgb
#./merge.sh comune_osm fgb
#./merge.sh stato_no_osm pmtiles
#./merge.sh stato_no_osm fgb
./merge.sh acq_ter_no_osm pmtiles
./merge.sh acq_ter_no_osm fgb


