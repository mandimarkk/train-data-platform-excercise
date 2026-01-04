# This script collects train data from Rautatieliikenne API.

import requests
import json
import os
import time
from pathlib import Path

# --- Settings ---

SOURCE_URL = "https://rata.digitraffic.fi/api/v1/trains/{date}" # getting data based on train's departure date
PROJECT_DIR = Path(__file__).resolve().parent.parent.parent # project root directory
OUTPUT_FOLDER = PROJECT_DIR / "data" / "lake" / "staging_data"  # output folder for data files

headers = {'Digitraffic-User': 'Meitsi/Data-alustakurssi'}

# Setting desired dates to collect data from
dates = ["2025-10-06", "2025-10-07", "2025-10-08", "2025-10-09", "2025-10-10", "2025-10-11", "2025-10-12"]

# Creating folder for raw data
os.makedirs(OUTPUT_FOLDER, exist_ok=True) 

def collect_train_data():
    # --- Collecting data --- 

    for date in dates:
        url = SOURCE_URL.format(date=date)
        print(f"Getting data from date: {date}")
        response = requests.get(url, headers=headers)
        response.raise_for_status() # in case of errors
        trains = response.json()
        output_file = f"{OUTPUT_FOLDER}/raw_data_{date}.json" # name files by date
        
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(trains, f, ensure_ascii=False, indent=2) # save data to output file
        
        print(f"Data tallennettu tiedostoon: {output_file} ({len(trains)} riviä)")

        time.sleep(1) # one request per second


if __name__ == "__main__":
    collect_train_data()