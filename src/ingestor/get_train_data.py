# This script collects train data and station data from Rautatieliikenne API.

import requests
import json
import os
from datetime import datetime, timedelta
import time
from pathlib import Path
import argparse

# --- Settings ---

SOURCE_URL = "https://rata.digitraffic.fi/api/v1/trains/{date}"  # train data by departure date
STATIONS_URL = "https://rata.digitraffic.fi/api/v1/metadata/stations"  # station info
PROJECT_DIR = Path(__file__).resolve().parent.parent.parent  # project root
OUTPUT_FOLDER = PROJECT_DIR / "data" / "lake" / "staging_data"  # output folder

headers = {'Digitraffic-User': 'Meitsi/Data-alustakurssi'}

# Creating folder for raw data
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# --- Date handling ---

def date_args():
    parser = argparse.ArgumentParser(description="Select dates to fetch train data from.")
    parser.add_argument("--start-date", type=str, help="Start date (YYYY-MM-DD)")
    parser.add_argument("--end-date", type=str, help="End date (YYYY-MM-DD)")

    args = parser.parse_args()

    default_dates = ["2025-10-06", "2025-10-07", "2025-10-08",
                     "2025-10-09", "2025-10-10", "2025-10-11", "2025-10-12"]

    if args.start_date and args.end_date:
        start = datetime.strptime(args.start_date, "%Y-%m-%d")
        end = datetime.strptime(args.end_date, "%Y-%m-%d")
        delta = (end - start).days
        if delta < 0:
            raise ValueError("End date must be after start date")
        return [(start + timedelta(days=i)).strftime("%Y-%m-%d") for i in range(delta + 1)]
    else:
        return default_dates

# --- Collecting train data ---

def collect_train_data(dates):
    for date in dates:
        url = SOURCE_URL.format(date=date)
        print(f"Getting train data for date: {date}")
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        trains = response.json()
        output_file = f"{OUTPUT_FOLDER}/raw_data_{date}.json"
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(trains, f, ensure_ascii=False, indent=2)
        print(f"Train data saved: {output_file} ({len(trains)} rows)")
        time.sleep(1)  # rate limiting

# --- Collecting station data ---

def collect_station_data():
    print("Getting station metadata...")
    response = requests.get(STATIONS_URL, headers=headers)
    response.raise_for_status()
    stations = response.json()
    output_file = OUTPUT_FOLDER / "stations.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(stations, f, ensure_ascii=False, indent=2)
    print(f"Station data saved: {output_file} ({len(stations)} stations)")

# --- Main ---

if __name__ == "__main__":
    
    dates = date_args()
    collect_train_data(dates)
    collect_station_data()  # <-- New: download station names and codes