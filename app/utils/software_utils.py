import json


def load_software():
    filename = "./config/software2.json"

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
    filename = "./config/software2.json"
    with open(filename, "w", encoding="utf-8") as file:
        json.dump(software, file, ensure_ascii=False, indent=4)