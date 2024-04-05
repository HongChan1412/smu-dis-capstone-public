import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from fastapi import WebSocket, Request, WebSocketDisconnect, APIRouter
from fastapi.templating import Jinja2Templates

from utils.ssh_utils import SSHSession, ssh_sessions, close_ssh_session, get_swdict_debian, get_swdict_redhat
from utils.nvd_utils import check_cpe_exist, load_software, save_software, search_nvd_cpe
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

    for sw in sw_list:
        swname = sw["swname"]
        version = sw["version"]
        swname_version = f"{swname}:{version}"

        if swname_version in cpe_true:
            cpename = software["CPE_True"][swname_version]
            result.append({swname: search_nvd_cpe(cpename)})

        elif swname not in cpe_false_swname and swname_version not in cpe_false_swname_version:
            software, is_found = check_cpe_exist(swname, version, software)
            if is_found:
                cpename = software["CPE_True"][swname_version]
                result.append({swname: search_nvd_cpe(cpename)})

    save_software(software)
    return {"result": result}


@hc.get("/nvds/")
async def get_nvd(swname: str):
    return {"result": check_cpe_exist(swname)}

