#!/bin/bash
set -e
cd $(dirname "$0")/..

./download.sh

./filter.sh forest_no_osm bosco "meta_ist != '03'"
#./filter.sh forest_osm bosco "meta_ist = '03'"

./merge.sh forest_no_osm pmtiles
./merge.sh forest_no_osm fgb


