import os
import sys
import time
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from fastapi import WebSocket, Request, WebSocketDisconnect, APIRouter
from fastapi.templating import Jinja2Templates
from concurrent.futures import ThreadPoolExecutor


from utils.ssh_utils import SSHSession, ssh_sessions, close_ssh_session, get_swdict_debian, get_swdict_redhat
from utils.nvd_utils import check_cpe_exist, load_software, save_software, search_nvd_cve
#from ...utils.nvd_utils import check_cpe_exist

hc = APIRouter()

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
async def get_swdict(hostname: str, port: int, username: str, password: str, os_type: str):
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
    result = []

    def proccess_softwware(sw, cpe_false_swname, cpe_false_swname_version, cpe_true):
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
            result.update(search_nvd_cve(cpe_true[swname_version]))

        elif swname not in cpe_false_swname and swname_version not in cpe_false_swname_version:
            result.update(check_cpe_exist(swname, version))
            if result["found_cpe"] == True:
                result.update(search_nvd_cve(result["cpe"]))
        return result

    count = 0
    len_sw_list = len(sw_list)

    while True:
        with ThreadPoolExecutor(max_workers=1) as executor:
            futures = [executor.submit(proccess_softwware, sw, cpe_false_swname, cpe_false_swname_version, cpe_true) for sw in sw_list]
            sw_list = []
            for future in futures:
                swname = future.result()["swname"]
                version = future.result()["version"]
                swname_version = f"{swname}:{version}"
                res = future.result()
                if res["found_cve"] == "error" or res["found_cpe"] == "error":
                    sw_list.append({
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

                    count += 1
        if count == len_sw_list:
            break
    save_software(software)
    return {"result": result}


@hc.get("/nvds/")
async def get_nvd(swname: str):
    return {"result": check_cpe_exist(swname)}

