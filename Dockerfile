FROM python:3.11.1

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt
COPY ./app /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]