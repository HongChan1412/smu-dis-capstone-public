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
