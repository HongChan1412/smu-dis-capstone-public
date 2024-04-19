import json
from utils.nvd_utils import search_cpe_swname, search_cpe_swname_version


async def load_software() -> dict:
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


async def update_software_json():
    software = await load_software()
    cpe_false_swname = software["CPE_False"]["swname"]
    cpe_false_swname_version = software["CPE_False"]["swname:version"]
    print("update_software_json")
    while True:
        re_cpe_false_swname = []
        for swname in cpe_false_swname:
            print(swname)
            res = await search_cpe_swname(swname)
            if res == "error":
                re_cpe_false_swname.append(swname)
            else:
                if res:
                    print(f"change_swname: {swname}")
                    software["CPE_False"]["swname"].remove(swname)

        if not re_cpe_false_swname:
            break
        else:
            print(f"re_cpe_false_swname: {re_cpe_false_swname}")
            cpe_false_swname = re_cpe_false_swname

    while True:
        re_cpe_false_swname_version = []
        for swname_version in cpe_false_swname_version:
            print(swname_version)
            res = await search_cpe_swname_version(swname_version)
            if res["found_cpe"] == "error":
                re_cpe_false_swname_version.append(swname)
            else:
                if res["found_cpe"]:
                    print(f"change_swname_version: {swname_version}")
                    software["CPE_True"].update({swname_version: res["cpe"]})
                    software["CPE_False"]["swname:version"].remove(swname_version)

        if not re_cpe_false_swname_version:
            break
        else:
            print(f"re_cpe_false_swname_version: {re_cpe_false_swname_version}")
            cpe_false_swname_version = re_cpe_false_swname_version

    save_software(software)
    print("save_software")
