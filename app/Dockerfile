# The version of the base container must
# match the driver installed on the local system.
# Download the driver from: https://developer.nvidia.com/cuda-downloads

FROM ubuntu:20.04 as builder

RUN apt-get update
RUN apt-get install python3.8 python3-pip -y
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install -r requirements.txt

FROM builder as build
COPY . .
WORKDIR ./

CMD ["uvicorn", "main:app","--host","0.0.0.0","--port","8080"]
