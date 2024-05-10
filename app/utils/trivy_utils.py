import asyncio
import os.path
import sys
import json
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))


async def check_docker(image: str):
    try:
        proc = await asyncio.create_subprocess_shell(
            f"timeout 300 bash -c 'trivy image --scanners vuln -f json {image}'",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await proc.communicate()
        if proc.returncode == 0:
            result = json.loads(stdout.decode("utf-8"))
            return result
        else:
            print(stderr)
            return None
    except Exception as e:
        print(e)
        return None


async def create_dockerfile(image: str):
    iamge_name = image.split(":")
    file = os.path.isfile(f'./tar_list/{iamge_name[0]}_{iamge_name[1]}.tar')
    command = [f"echo 'FROM {image}' > Dockerfile",
               "echo 'WORKDIR /app' >> Dockerfile"
    ]
    if iamge_name[0] == "alpine":
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
            f"docker build -t {iamge_name[0]}_{iamge_name[1]} .",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        await build_proc.communicate()
        if build_proc.returncode != 0:
            raise Exception("Docker build failed")

        scan_proc = await asyncio.create_subprocess_shell(
            f"trivy image --scanners vuln -f json {iamge_name[0]}_{iamge_name[1]} ",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await scan_proc.communicate()
        if scan_proc.returncode == 0:
            result = json.loads(stdout.decode("utf-8"))
        else:
            raise Exception(stderr)

    except Exception as e:
        print(e)
        return None

    if file == False:
        await asyncio.create_subprocess_shell(
            f"docker save -o ./tar_list/{iamge_name[0]}_{iamge_name[1]}.tar {iamge_name[0]}_{iamge_name[1]}", shell=True)
    await asyncio.create_subprocess_shell(f"docker rmi -f {iamge_name[0]}_{iamge_name[1]}")

    return result


async def prune_docker():
    await asyncio.create_subprocess_shell("docker system prune -f", shell=True)
    await asyncio.create_subprocess_shell("docker buildx prune -f", shell=True)
