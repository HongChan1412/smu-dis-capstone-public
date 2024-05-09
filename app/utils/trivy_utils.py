import subprocess
import os.path
import sys
import json
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))


async def check_docker(image: str):
    try:
        result = subprocess.run(f"timeout 300 bash -c 'trivy image --scanners vuln -f json {image}'", shell=True, check=True, capture_output=True, text=True)
        result = json.loads(result.stdout)
        return result
    except Exception as e:
        print(e)
        return None


async def create_dockerfile(image: str):
    iamge_name = image.split(":")
    subprocess.run(f"echo 'FROM {image}' > Dockerfile", shell=True, check=True, capture_output=True, text=True)
    if iamge_name[0] == "alpine":
        subprocess.run("echo 'WORKDIR /app' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
        subprocess.run("echo 'RUN apk update && apk upgrade && apk add --no-cache zlib-dev' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
    else:
        subprocess.run("echo 'WORKDIR /app' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
        subprocess.run("echo 'RUN apt update && apt upgrade -y && \\' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
        subprocess.run("echo '    groupadd -g 1000 appuser && \\' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
        subprocess.run("echo '    useradd -m -r -u 1001 user -g appuser && \\' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
        subprocess.run("echo '    chown -R user:appuser /app && chmod -R 755 /app' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
        subprocess.run("echo 'USER user' >> Dockerfile", shell=True, check=True, capture_output=True, text=True)
    try:
        subprocess.run(f"docker build -t {iamge_name[0]}_{iamge_name[1]} .", shell=True, check=True, capture_output=True, text=True)
        result = subprocess.run(f"trivy image --scanners vuln -f json {iamge_name[0]}_{iamge_name[1]} ", shell=True, check=True, capture_output=True, text=True)
        result = json.loads(result.stdout)
        subprocess.run(f"docker save -o ./tar_list/{iamge_name[0]}_{iamge_name[1]}.tar {iamge_name[0]}_{iamge_name[1]}", shell=True, check=True, capture_output=True, text=True)
        subprocess.run(f"docker rmi -f {iamge_name[0]}_{iamge_name[1]}", shell=True, check=True, capture_output=True, text=True)
        print(f"{image}의 tar 파일 생성 완료했습니다. --> 전송합니다.")
    except Exception as e:
        return None

    return result

