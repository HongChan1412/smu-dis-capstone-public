import json
import requests
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from config.config import NVD_APIKEY


def check_cpe_exist(swname: str, version: str, software: dict):
    url = "https://services.nvd.nist.gov/rest/json/cpes/2.0"
    params = {"keywordSearch": swname}
    headers = {"apiKey": NVD_APIKEY}

    try:
        response = requests.get(url, params=params, headers=headers)
        response.raise_for_status()  # 200 OK 코드가 아니면 예외를 발생시킴
        data = response.json()
    except requests.exceptions.RequestException as e:
        print(f"데이터를 가져오는 중 오류 발생: {e}")
        return software  # 예외 발생 시 현재의 software 상태를 반환

    found = False
    if data.get("products"):
        for product in data["products"]:
            if f"{swname}:{version}" in product.get("cpe", {}).get("cpeName", ""):
                software["CPE_True"][f"{swname}:{version}"] = product["cpe"]["cpeName"]
                print(f"swname: {swname}, cpe검색이 있고, 버전에 맞는것도 있음")
                found = True
                break  # 일치하는 CPE를 찾으면 루프 종료

    if not found:
        key = "swname" if not data.get("products") else "swname:version"
        value = swname if not data.get("products") else f"{swname}:{version}"
        software["CPE_False"][key].append(value)
        status_message = "cpe검색이 없음" if key == "swname" else "cpe검색은 있는데 버전에 맞는게 없음."
        print(f"swname: {swname}, {status_message}")

    return software, found


def search_nvd_cpe(cpename: str):
    url = "https://services.nvd.nist.gov/rest/json/cves/2.0"
    params = {"cpeName": cpename}
    headers = {"apiKey": NVD_APIKEY}
    print(cpename)

    try:
        response = requests.get(url, params=params, headers=headers)
        response.raise_for_status()  # 200 OK 코드가 아니면 예외를 발생시킴
        data = response.json()
    except requests.exceptions.RequestException as e:
        print(f"데이터를 가져오는 중 오류 발생: {e}")
        return   # 예외 발생 시 현재의 software 상태를 반환

    return data


def load_software():
    filename = "./config/software.json"

    try:
        with open(filename, "r", encoding="utf-8") as file:
            data = json.load(file)
            if not data:
                data = {
                    "CPE_False": {
                        "swname": [],
                        "swname:version": []
                    },
                    "CPE_True": {
                    }
                }
        return data
    except FileNotFoundError:
        return {
            "CPE_False": {
                "swname": [],
                "swname:version": []
            },
            "CPE_True": {
            }
        }
    except json.JSONDecodeError:
        return {
            "CPE_False": {
                "swname": [],
                "swname:version": []
            },
            "CPE_True": {
            }
        }


def save_software(software):
    filename = "./config/software.json"
    with open(filename, "w", encoding="utf-8") as file:
        json.dump(software, file, ensure_ascii=False, indent=4)
