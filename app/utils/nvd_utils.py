import sys
import os
import aiohttp
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from config.config import NVD_APIKEY


async def check_cpe_exist(swname: str, version: str) -> dict:
    url = "https://services.nvd.nist.gov/rest/json/cpes/2.0"
    params = {"keywordSearch": swname}
    headers = {"apiKey": NVD_APIKEY}
    result = {
        "found_cpe": False
    }

    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(url, params=params, headers=headers, ssl=False) as response:
                response.raise_for_status()
                data = await response.json()
        except aiohttp.ClientError as e:
            print(f"데이터를 가져오는 중 오류 발생(check_cpe_exist): {e}")
            result["found_cpe"] = "error"
            return result

        if data.get("products"):
            for product in data["products"]:
                if f"{swname}:{version}" in product.get("cpe", {}).get("cpeName", ""):
                    print(f"swname: {swname}, cpe검색이 있고, 버전에 맞는것도 있음")
                    result["found_cpe"] = True
                    result["cpe"] = product["cpe"]["cpeName"]
                    break  # 일치하는 CPE를 찾으면 루프 종료

        if not result["found_cpe"]:
            key = "swname" if not data.get("products") else "swname:version"
            result["key"] = key
            status_message = "cpe검색이 없음" if key == "swname" else "cpe검색은 있는데 버전에 맞는게 없음."
            print(f"swname: {swname}, {status_message}")

        return result


async def search_nvd_cve(cpename: str) -> dict:
    url = "https://services.nvd.nist.gov/rest/json/cves/2.0"
    params = {"cpeName": cpename}
    headers = {"apiKey": NVD_APIKEY}
    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(url, params=params, headers=headers, ssl=False) as response:
                response.raise_for_status()
                data = await response.json()
                if not data.get("vulnerabilities"):
                    return {
                        "cpe": cpename,
                        "found_cve": False
                    }
                print(cpename)
                return {
                    "cpe": cpename,
                    "found_cve": True,
                    "cve": data
                }
        except aiohttp.ClientError as e:
            print(f"데이터를 가져오는 중 오류 발생(search_nvd_cve): {e}")
            return {
                "cpe": cpename,
                "found_cve": "error",
            }


async def search_cpe_swname(swname: str):
    url = "https://services.nvd.nist.gov/rest/json/cpes/2.0"
    params = {"keywordSearch": swname}
    headers = {"apiKey": NVD_APIKEY}

    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(url, params=params, headers=headers, ssl=False) as response:
                response.raise_for_status()
                data = await response.json()
        except aiohttp.ClientError as e:
            print(f"데이터를 가져오는 중 오류 발생(search_cpe_swname): {e}")
            return "error"
        if data.get("products"):
            return True
        return False


async def search_cpe_swname_version(swname_version: str) -> dict:
    url = "https://services.nvd.nist.gov/rest/json/cpes/2.0"
    params = {"keywordSearch": swname_version}
    headers = {"apiKey": NVD_APIKEY}
    result = {
        "found_cpe": False
    }

    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(url, params=params, headers=headers, ssl=False) as response:
                response.raise_for_status()
                data = await response.json()
        except aiohttp.ClientError as e:
            print(f"데이터를 가져오는 중 오류 발생(search_cpe_swname_version): {e}")
            result["found_cpe"] = "error"
            return result

        if data.get("products"):
            for product in data["products"]:
                if swname_version in product.get("cpe", {}).get("cpeName", ""):
                    result["found_cpe"] = True
                    result["cpe"] = product["cpe"]["cpeName"]
                    break
        return result
