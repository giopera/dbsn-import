#!/bin/bash
set -e
cd $(dirname "$0")/..

./download.sh

./filter.sh townhalls edifc "edifc_uso = '0201'"

./merge.sh townhalls pmtiles
./merge.sh townhalls fgb

cp data/townhalls.fgb townhalls/
