import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from fastapi import WebSocket, Request, WebSocketDisconnect, APIRouter
from fastapi.templating import Jinja2Templates
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from utils.ssh_utils import SSHSession, ssh_sessions, close_ssh_session, get_swdict_debian, get_swdict_redhat, run_remote_script
from utils.nvd_utils import check_cpe_exist, search_nvd_cve
from utils.software_utils import load_software, save_software, update_software_json
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
    if os_type == "debian":
        sw_list = await get_swdict_debian(hostname, port, username, password)
    elif os_type == "redhat":
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

    result = []
    while True:
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
                    result.append({swname: res["cve"]})
                if res["found_cpe"] == True:
                    software["CPE_True"].update({swname_version: res["cpe"]})
                elif res["found_cpe"] == False:
                    if res["key"] == "swname":
                        software["CPE_False"]["swname"].append(swname)
                    elif res["key"] == "swname:version":
                        software["CPE_False"]["swname:version"].append(swname_version)

        if not re_sw_list:
            break
        else:
            print(f"re_sw_list: {re_sw_list}")
            sw_list = re_sw_list

    print(f"len(result): {len(result)}")
    if save:
        save_software(software)
    return {"result": result}


@hc.on_event("startup")
async def update_software():
    scheduler.add_job(update_software_json, 'cron', hour=0, minute=0)
    scheduler.start()


@hc.get("/nvds/")
async def get_nvd(swname: str):
    return {"result": check_cpe_exist(swname)}


@hc.get("/execute_script")
async def execute_script(host: str, port: int, username: str, password: str, os_type: str, script: str):
    script_path = SCRIPT_PATH[os_type][script]
    result = await run_remote_script(host, port, username, password, script_path)
    return {"result": result}
