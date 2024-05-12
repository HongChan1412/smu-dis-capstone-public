import os
import sys
import os.path
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from fastapi import WebSocket, Request, WebSocketDisconnect, APIRouter
from fastapi.templating import Jinja2Templates
from fastapi.responses import FileResponse
from apscheduler.schedulers.asyncio import AsyncIOScheduler
import json

from utils.ssh_utils import SSHSession, ssh_sessions, close_ssh_session, get_swdict_debian, get_swdict_redhat, run_remote_script, get_docker_image
from utils.nvd_utils import check_cpe_exist, search_nvd_cve
from utils.software_utils import load_software, save_software, update_software_json
from utils.trivy_utils import check_docker_before, check_docker_after, prune_docker
from config.config import SCRIPT_PATH

hc = APIRouter()
scheduler = AsyncIOScheduler()

templates = Jinja2Templates(directory="templates")


@hc.get("/index")
def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


@hc.websocket("/ws/{ip}/{port}/{user}/{passwd}")
async def websocket_connect_endpoint(websocket: WebSocket, ip: str, port: int, user: str, passwd: str):
    await websocket.accept()
    ssh_session = SSHSession()
    await ssh_session.create(ip, port, user, passwd)
    ssh_sessions[str(websocket)] = ssh_session

    try:
        while True:
            data = await websocket.receive_text()
            if data == 'disconnect':
                await close_ssh_session(websocket)
                await websocket.send_text('Disconnected')
                await websocket.close(code=1000)
            else:
                result = await ssh_session.run_command(data)
                if result:
                    await websocket.send_text(result)
    except WebSocketDisconnect:
        await close_ssh_session(websocket)


@hc.get("/swdict/")
async def get_swdict(hostname: str, port: int, username: str, password: str, os_type: str, save: bool = False):
    if os_type == "ubuntu":
        sw_list = await get_swdict_debian(hostname, port, username, password)
    elif os_type == "centos":
        sw_list = await get_swdict_redhat(hostname, port, username, password)
    else:
        return {"error": "Unsupported OS type"}
    software = load_software()

    cpe_false_swname = software["CPE_False"]["swname"]
    cpe_false_swname_version = software["CPE_False"]["swname:version"]
    cpe_true = software["CPE_True"]

    async def proccess_software(sw: dict, cpe_true: dict, cpe_false_swname: list, cpe_false_swname_version: list) -> dict:
        swname = sw["swname"]
        version = sw["version"]
        swname_version = f"{swname}:{version}"
        result = {
            "swname": swname,
            "version": version,
            "cpe": "",
            "cve": "",
            "found_cpe": False,
            "found_cve": False,
            "key": ""
        }
        if swname_version in cpe_true:
            result.update(await search_nvd_cve(cpe_true[swname_version]))

        elif swname not in cpe_false_swname and swname_version not in cpe_false_swname_version:
            result.update(await check_cpe_exist(swname, version))
            if result["found_cpe"] == True:
                result.update(search_nvd_cve(result["cpe"]))
        return result

    results = []
    re_sw_list = []
    for sw in sw_list:
        swname = sw["swname"]
        version = sw["version"]
        swname_version = f"{swname}:{version}"

        res = await proccess_software(sw, cpe_true, cpe_false_swname, cpe_false_swname_version)

        if res["found_cve"] == "error" or res["found_cpe"] == "error":
            re_sw_list.append({
                "swname": swname,
                "version": version
            })
        else:
            if res["found_cve"] == True:
                result = {
                    "package_name": swname,
                    "version": version,
                    "vulnerabilities": [],
                }
                for i in res["cve"]["vulnerabilities"]:
                    cve = {
                        "cve_id": i["cve"]["id"],
                        "description": i["cve"]["descriptions"][0]["value"],
                        "cvssMetricV31": None,
                        "cvssMetricV30": None,
                        "cvssMetricV2": None
                    }
                    if i["cve"]["metrics"].get("cvssMetricV31"):
                        cve["cvssMetricV31"] = i['cve']['metrics']['cvssMetricV31'][0]['cvssData']['baseScore']
                    if i["cve"]["metrics"].get("cvssMetricV30"):
                        cve["cvssMetricV30"] = i['cve']['metrics']['cvssMetricV30'][0]['cvssData']['baseScore']
                    if i["cve"]["metrics"].get("cvssMetricV2"):
                        cve["cvssMetricV2"] = i['cve']['metrics']['cvssMetricV2'][0]['cvssData']['baseScore']
                    result["vulnerabilities"].append(cve)
                results.append(result)

            if res["found_cpe"] == True:
                software["CPE_True"].update({swname_version: res["cpe"]})
            elif res["found_cpe"] == False:
                if res["key"] == "swname":
                    software["CPE_False"]["swname"].append(swname)
                elif res["key"] == "swname:version":
                    software["CPE_False"]["swname:version"].append(swname_version)

    else:
        print(f"re_sw_list: {re_sw_list}")
        sw_list = re_sw_list

    if save:
        save_software(software)
    return {"result": results}


@hc.on_event("startup")
async def update_software():
    scheduler.add_job(update_software_json, 'cron', hour=0, minute=0)
    scheduler.start()


@hc.get("/nvds/")
async def get_nvd(swname: str):
    return {"result": check_cpe_exist(swname)}


@hc.get("/execute_script")
async def execute_script(host: str, port: int, username: str, password: str, os_type: str, script: str, user: str | None = None):
    script_path = SCRIPT_PATH[os_type][script]
    result = await run_remote_script(host, port, username, password, script_path, user)
    if script == "check":
        result = json.loads(result)
        result["foot"] = [content["subtitle"]
            for section in result["body"]
            for content in section["content"]
            if any("취약" in result for result in content["result"])
        ]
    return result


@hc.get("/dockers")
async def get_docker(host: str, port: int, username: str, password: str):
    images = await get_docker_image(host=host, port=port, username=username, password=password)
    images = list(filter(None, images))
    results = {
        "dockerImage": {
        }
    }
    for image in images:
        print(image)

        image_json_before = await check_docker_before(image)
        if image_json_before:
            if not image_json_before.get("Results"):
                continue
            image_json_after = await check_docker_after(image)
            if image_json_after:
                result = {
                    "ImageName": image_json_after["ArtifactName"],
                    "before": len(image_json_before["Results"][0]["Vulnerabilities"]),
                    "after": len(image_json_after["Results"][0].get("Vulnerabilities", [])),
                    "leftcve": []
                }
                for i in range(result["after"]):
                    data = {
                        "Libarary Name": image_json_after["Results"][0]["Vulnerabilities"][i]["PkgName"],
                        "CVE": image_json_after["Results"][0]["Vulnerabilities"][i]["VulnerabilityID"],
                        "Severity": image_json_after["Results"][0]["Vulnerabilities"][i]["Severity"]
                    }
                    result["leftcve"].append(data)
                results["dockerImage"][image] = result
    prune_docker()
    return results


@hc.get("/tars")
async def download_tar(image: str):
    file_path = f"/app/tar_list/{image}.tar"
    return FileResponse(path=file_path, filename=f"{image}.tar", media_type="application/x-tar")
