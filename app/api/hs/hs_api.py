import os
import sys
import paramiko
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))))

from fastapi import WebSocket, Request, WebSocketDisconnect, APIRouter
from fastapi.templating import Jinja2Templates
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi.responses import JSONResponse
import json

from utils.ssh_utils import SSHSession, ssh_sessions, close_ssh_session, get_swdict_debian, get_swdict_redhat
from utils.nvd_utils import check_cpe_exist, search_nvd_cve
from utils.software_utils import load_software, save_software, update_software_json

hs = APIRouter()
scheduler = AsyncIOScheduler()

templates = Jinja2Templates(directory="templates")


@hs.get("/index")
def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@hs.websocket("/ws/{ip}/{port}/{user}/{passwd}")
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


@hs.get("/centos")
async def read_centos(request: Request):
    return templates.TemplateResponse("centos.html", {"request": request})

@hs.get("/ubuntu")
def read_ubuntu(request: Request):
    return templates.TemplateResponse("ubuntu.html", {"request" : request})

@hs.get("/centoscheck")
def read_centoscheck(request: Request):
    return templates.TemplateResponse("centoscheck.html", {"request": request})

@hs.get("/ubuntucheck")
def read_centoscheck(request: Request):
    return templates.TemplateResponse("ubuntucheck.html", {"request": request})

@hs.get("/ubuntucheck/resolve")
def read_centoscheck(request: Request):
    return templates.TemplateResponse("ubuntucheckresolve.html", {"request": request})

@hs.get("/centoscheck/resolve")
def read_centoscheck(request: Request):
    return templates.TemplateResponse("centoscheckresolve.html", {"request": request})

@hs.get("/dockerimage")
def read_centoscheck(request: Request):
    return templates.TemplateResponse("dockerimage.html", {"request": request})


@hs.get("/report")
def read_centoscheck(request: Request):
    return templates.TemplateResponse("report.html", {"request": request})

@hs.get("/cve_result")
async def get_cve_result():
    try:
        with open('./templates/cve_result.json', 'r') as file:
            data = json.load(file)
            return JSONResponse(content=data)
    except FileNotFoundError:
        return JSONResponse(content={"error": "File not found"}, status_code=404)
    
