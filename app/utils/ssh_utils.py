from typing import Dict
from fastapi import WebSocketDisconnect, WebSocket
import logging
import asyncssh


logging.basicConfig(level=logging.ERROR)


class SSHSession:
    def __init__(self):
        self.conn = None

    async def create(self, ip: str, port: int, user: str, passwd: str):
        try:
            self.conn = await asyncssh.connect(ip, port=port, username=user, password=passwd, known_hosts=None)
        except Exception as e:
            error_message = f"Failed to create SSH connection: {e}"
            logging.error(error_message)
            raise WebSocketDisconnect(code=1000, detail=error_message)

        if not self.conn:
            self.conn = None

    async def run_command(self, command: str):
        if not self.conn:
            raise Exception('SSH session not connected')
        result = await self.conn.run(command)
        return result.stdout

    async def close(self):
        if self.conn:
            try:
                await self.conn.close()
            except Exception as e:
                logging.error(f"Error closing SSH connection: {e}")
            finally:
                self.conn = None
        else:
            logging.info("SSH connection is already closed.")


async def close_ssh_session(websocket: WebSocket):
    ssh_session = ssh_sessions.get(str(websocket))
    if ssh_session:
        await ssh_session.close()
        del ssh_sessions[str(websocket)]


ssh_sessions: Dict[str, SSHSession] = {}


async def get_swdict_debian(hostname: str, port: int, username: str, password: str) -> list:
    command = "dpkg -l | awk '/^ii/ { gsub(/^[0-9]:/, \"\", $3); gsub(/-.*/, \"\", $3); gsub(/[a-zA-Z]+.*/, \"\", $3); gsub(/:.*/, \"\", $2); printf \"%s:%s\\n\", $2, $3 }'"
    try:
        async with asyncssh.connect(hostname, port=port, username=username, password=password, known_hosts=None) as conn:
            result = await conn.run(command, check=True)
            software_list = result.stdout.split("\n")
            software_dict = [{"swname": item.split(":")[0], "version": item.split(":")[1]} for item in software_list if item]

            return software_dict
    except (asyncssh.Error, Exception) as e:
        return str(e)


async def get_swdict_redhat(hostname: str, port: int, username: str, password: str) -> list:
    command = "rpm -qa --queryformat '%{NAME}:%{VERSION}\\n' | sort"
    try:
        async with asyncssh.connect(hostname, port=port, username=username, password=password, known_hosts=None) as conn:
            result = await conn.run(command, check=True)
            software_list = result.stdout.split("\n")
            software_dict = [{"swname": item.split(":")[0], "version": item.split(":")[1]} for item in software_list if item]

            return software_dict
    except (asyncssh.Error, Exception) as e:
        return str(e)


async def get_docker_image(host: str, port: int, username: str, password: str):
    command = "sudo docker images --format \"{{.Repository}}:{{.Tag}}\""
    try:
        async with asyncssh.connect(host, port=port, username=username, password=password, known_hosts=None) as conn:
            result = await conn.run(command, check=True)
            result = result.stdout.strip().split("\n")

            return result
    except (asyncssh.Error, Exception) as e:
        return str(e)


async def run_remote_script(host: str, port: int, username: str, password: str, script_path: str, user: str | None = None):
    with open(script_path, "r", encoding="utf-8") as file:
        if user:
            script_content = file.read().format(**{"USERNAME": user})
        else:
            script_content = file.read()
    try:
        async with asyncssh.connect(host, port=port, username=username, password=password, known_hosts=None) as conn:
            if script_path == "./scripts/common/restore_sudoers.sh":
                script_content = f"sudo bash -c '{script_content}'"
            result = await conn.run(script_content, check=True)
            print(result.stdout, end='')
            return result.stdout
    except (OSError, asyncssh.Error) as e:
        print(f"SSH connection failed: {e}")
        return None

