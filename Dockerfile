FROM python:3.11.1

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt
COPY ./app /app

RUN apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce docker-ce-cli containerd.io

COPY ./app/scripts/docker-login.sh /usr/local/bin/docker-login.sh
RUN chmod +x /usr/local/bin/docker-login.sh

CMD ["/bin/bash", "-c", "/usr/local/bin/docker-login.sh && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"]
