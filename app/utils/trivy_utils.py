import asyncio
import os.path
import sys
import json
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))


async def read_json_file(file_path: str):
    try:
        with open(file_path, "r") as file:
            return json.load(file)
    except json.JSONDecodeError as e:
        print(f"JSON 파일 파싱 오류: {e}")
    except Exception as e:
        print(f"파일 읽기 오류: {e}")
    return None


async def check_docker_before(image: str):
    name, version = image.split(":")
    file_path = f"./docker_cves/{name}_{version}.json"
    if not os.path.isfile(file_path):
        try:
            proc = await asyncio.create_subprocess_shell(
                f"timeout 300 bash -c 'trivy image --scanners vuln -f json -o ./docker_cves/{name}_{version}.json {image}'",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            stdout, stderr = await proc.communicate()
            if proc.returncode != 0:
                print(stderr.decode("utf-8"))
                return None
        except Exception as e:
            print(e)
            return None
    return await read_json_file(file_path)


async def check_docker_after(image: str):
    name, version = image.split(":")
    file_path = f"./docker_cves_re/{name}_{version}.json"
    if not os.path.isfile(file_path):
        command = [f"echo 'FROM {image}' > Dockerfile",
                   "echo 'WORKDIR /app' >> Dockerfile"
        ]
        if name == "alpine":
            command.extend([
                "echo 'RUN apk update && apk upgrade && apk add --no-cache zlib-dev' >> Dockerfile"
            ])
        else:
            command.extend([
                "echo 'RUN apt update && apt upgrade -y && \\' >> Dockerfile",
                "echo '    groupadd -g 1000 appuser && \\' >> Dockerfile",
                "echo '    useradd -m -r -u 1001 user -g appuser && \\' >> Dockerfile",
                "echo '    chown -R user:appuser /app && chmod -R 755 /app' >> Dockerfile",
                "echo 'USER user' >> Dockerfile"
            ])
        try:
            for cmd in command:
                await asyncio.create_subprocess_shell(cmd, shell=True)

            build_proc = await asyncio.create_subprocess_shell(
                f"docker build -t {name}_{version} .",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            await build_proc.communicate()
            if build_proc.returncode != 0:
                raise Exception("Docker build failed")

            scan_proc = await asyncio.create_subprocess_shell(
                f"trivy image --scanners vuln -f json -o {file_path} {name}_{version}",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            stdout, stderr = await scan_proc.communicate()
            if scan_proc.returncode != 0:
                print(stderr.decode("utf-8"))
                return None

            if not os.path.isfile(f"./tar_list/{name}_{version}.tar"):
                await asyncio.create_subprocess_shell(f"docker save -o ./tar_list/{name}_{version}.tar {name}_{version}", shell=True)
            await asyncio.create_subprocess_shell(f"docker rmi -f {name}_{version}")
        except Exception as e:
            print(e)
            return None
    return await read_json_file(file_path)


async def prune_docker():
    await asyncio.create_subprocess_shell("docker system prune -f", shell=True)
    await asyncio.create_subprocess_shell("docker buildx prune -f", shell=True)
