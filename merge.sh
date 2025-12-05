#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo "See README.md for usage instructions"
    exit 1
fi

OUT_NAME="$1"
FORMAT="${2:-geojson}" # Default format is geojson

TEMP_DIR_PATH="./data/$OUT_NAME"
GEOJSON_FILE_PATH="./data/$OUT_NAME.geojson"

mkdir -p "./data"

# fgb and parquet do not support --append so they must be first merged in geojson
if [[ "$FORMAT" == "geojson" ||  "$FORMAT" == "fgb" || "$FORMAT" == "parquet" ]]; then
    if [ -f "$GEOJSON_FILE_PATH" ]; then
        echo "=====> Already merged in '$GEOJSON_FILE_PATH'"
    elif which ogr2ogr ; then
        for province_file_path in "$TEMP_DIR_PATH"/*.fgb ; do
            echo "=====> Merging $province_file_path in $GEOJSON_FILE_PATH"
            ogr2ogr -append -f 'GeoJSON' "$GEOJSON_FILE_PATH" "$province_file_path"
        done
        echo "=====> Merge of $GEOJSON_FILE_PATH completed"
    else
        echo "=====> GDAL not found, install it with the instructions in https://gdal.org/download.html"
        exit 1
    fi
fi

if [[ "$FORMAT" == "parquet" ]]; then
    PARQUET_FILE_PATH="./data/$OUT_NAME.parquet"
    if [ -f "$PARQUET_FILE_PATH" ]; then
        echo "=====> Already merged in '$PARQUET_FILE_PATH'"
    else
        echo "=====> Converting $GEOJSON_FILE_PATH in $PARQUET_FILE_PATH"
        ogr2ogr -f 'Parquet' "$PARQUET_FILE_PATH" "$GEOJSON_FILE_PATH"
        echo "=====> Conversion in $PARQUET_FILE_PATH completed"
    fi
fi

if [[ "$FORMAT" == "fgb" ]]; then
    FGB_FILE_PATH="./data/$OUT_NAME.fgb"
    if [ -f "$FGB_FILE_PATH" ]; then
        echo "=====> Already merged in '$FGB_FILE_PATH'"
    else
        echo "=====> Converting $GEOJSON_FILE_PATH in $FGB_FILE_PATH"
        ogr2ogr -f 'FlatGeoBuf' "$FGB_FILE_PATH" "$GEOJSON_FILE_PATH"
        echo "=====> Conversion in $FGB_FILE_PATH completed"
    fi
fi

if [[ "$FORMAT" == "mbtiles" || "$FORMAT" == "pmtiles" ]]; then
    TILES_FILE_PATH="./data/$OUT_NAME.$FORMAT"
    if [ -f "$TILES_FILE_PATH" ]; then
        echo "=====> Already merged in '$TILES_FILE_PATH'"
    elif which tippecanoe ; then
        echo "=====> Converting '$TEMP_DIR_PATH' in $TILES_FILE_PATH"
        # https://github.com/felt/tippecanoe#try-this-first
        tippecanoe -Z7 -zg -o "$TILES_FILE_PATH" -l "$OUT_NAME" --drop-densest-as-needed -x classid -x shape_Length "$TEMP_DIR_PATH"/*.fgb
        echo "=====> Conversion in $TILES_FILE_PATH completed"
    else
        echo "=====> Tippecanoe not found, install it with the instructions in https://github.com/felt/tippecanoe"
        exit 1
    fi
fi
