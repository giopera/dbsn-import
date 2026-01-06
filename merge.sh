#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo "See README.md for usage instructions"
    exit 1
fi

OUT_NAME="$1"
FORMAT="${2:-geojson}" # Default format is geojson

TEMP_DIR_PATH="./data/$OUT_NAME/dbsn"
GEOJSON_FILE_PATH="./data/$OUT_NAME/$OUT_NAME.geojson"
FGB_FILE_PATH="./data/$OUT_NAME/$OUT_NAME.fgb"

mkdir -p "./data"

# fgb and parquet do not support --append so they must be first merged in geojson
if [[ "$FORMAT" == "geojson" ||  "$FORMAT" == "fgb" || "$FORMAT" == "parquet" ]]; then
    if [ -f "$FGB_FILE_PATH" ]; then
        echo "=====> Already merged in '$FGB_FILE_PATH'"
    elif which gdal ; then
        echo "=====> Merging '$TEMP_DIR_PATH' in $FGB_FILE_PATH with gdal cli"
        gdal vector concat --mode=single -f 'FlatGeoBuf' "$TEMP_DIR_PATH"/*.fgb "$FGB_FILE_PATH"
        echo "=====> Merge in $FGB_FILE_PATH completed"
    elif which ogrmerge ; then
        echo "=====> Merging '$TEMP_DIR_PATH' in $FGB_FILE_PATH with ogrmerge"
        ogrmerge -single -f 'FlatGeoBuf' -o "$FGB_FILE_PATH" "$TEMP_DIR_PATH"/*.fgb
        echo "=====> Merge in $FGB_FILE_PATH completed"
    elif which ogr2ogr ; then
        echo "=====> Merging '$TEMP_DIR_PATH' in $GEOJSON_FILE_PATH with ogr2ogr"
        if [ ! -f "$GEOJSON_FILE_PATH" ]; then
            for province_file_path in "$TEMP_DIR_PATH"/*.fgb ; do
                echo "=====> Merging $province_file_path in $GEOJSON_FILE_PATH"
                ogr2ogr -append -f 'GeoJSON' "$GEOJSON_FILE_PATH" "$province_file_path"
            done
        fi
        echo "=====> Merge in $GEOJSON_FILE_PATH completed, converting in $FGB_FILE_PATH"
        ogr2ogr -f 'FlatGeoBuf' "$FGB_FILE_PATH" "$GEOJSON_FILE_PATH"
        echo "=====> Conversion in $FGB_FILE_PATH completed"
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
        echo "=====> Converting $FGB_FILE_PATH in $PARQUET_FILE_PATH"
        ogr2ogr -f 'Parquet' "$PARQUET_FILE_PATH" "$FGB_FILE_PATH"
        echo "=====> Conversion in $PARQUET_FILE_PATH completed"
    fi
fi

if [[ "$FORMAT" == "geojson" ]]; then
    if [ -f "$GEOJSON_FILE_PATH" ]; then
        echo "=====> Already merged in '$GEOJSON_FILE_PATH'"
    else
        echo "=====> Converting $FGB_FILE_PATH in $GEOJSON_FILE_PATH"
        ogr2ogr -f 'FlatGeoBuf' "$GEOJSON_FILE_PATH" "$FGB_FILE_PATH"
        echo "=====> Conversion in $GEOJSON_FILE_PATH completed"
    fi
fi

if [[ "$FORMAT" == "mbtiles" || "$FORMAT" == "pmtiles" ]]; then
    TILES_FILE_PATH="./data/$OUT_NAME.$FORMAT"
    if [ -f "$TILES_FILE_PATH" ]; then
        echo "=====> Already merged in '$TILES_FILE_PATH'"
    elif which tippecanoe ; then
        echo "=====> Merging '$TEMP_DIR_PATH' in $TILES_FILE_PATH"
        # https://github.com/felt/tippecanoe#try-this-first
        tippecanoe -Z7 -zg -o "$TILES_FILE_PATH" -l "$OUT_NAME" --drop-densest-as-needed -x classid -x shape_Length "$TEMP_DIR_PATH"/*.fgb
        echo "=====> Merge in $TILES_FILE_PATH completed"
    else
        echo "=====> Tippecanoe not found, install it with the instructions in https://github.com/felt/tippecanoe"
        exit 1
    fi
fi
