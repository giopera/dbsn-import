#!/bin/bash
set -e

./download.sh

./filter.sh comune_no_osm comune "meta_ist != '03'"
./filter.sh comune_osm comune "meta_ist != '03'"

./merge.sh comune_no_osm pmtiles
./merge.sh comune_no_osm fgb
./merge.sh comune_osm geojson
