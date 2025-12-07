#!/bin/bash
set -e
cd $(dirname "$0")/..

./download.sh

./filter.sh edifc_no_osm edifc "meta_ist != '03'"
#./filter.sh edifc_osm edifc "meta_ist = '03'"
./filter.sh edi_min_no_osm edi_min "meta_ist != '03'"

./merge.sh edifc_no_osm pmtiles
#./merge.sh edifc_no_osm fgb
#./merge.sh edifc_osm fgb
./merge.sh edi_min_no_osm pmtiles
#./merge.sh edi_min_no_osm fgb


