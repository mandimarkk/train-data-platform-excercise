#!/bin/bash

set -e

# Check that the first argument exists. If not, print usage:
if [ $# -lt 2 ]; then
    echo "Usage: $0 <start_date> <end_date>"
    echo "Example: $0 2026-01-01 2026-01-05"
    exit 1
fi

# Run ingestor script
uv run python src/ingestor/get_train_data.py \
    --start-date "$1" \
    --end-date "$2"

# Run the dbt commands
cd dbt_warehouse
uv run dbt run
uv run dbt docs generate
cd ..

# # Copy the duckdb database file to Evidence's sources directory
SOURCE_FILE=data/warehouse/warehouse.duckdb
DEST_FILE=bi/workspace/sources/warehouse/warehouse.duckdb
mkdir -p bi/workspace/sources/warehouse/
cp $SOURCE_FILE $DEST_FILE

