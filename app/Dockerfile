# The version of the base container must
# match the driver installed on the local system.
# Download the driver from: https://developer.nvidia.com/cuda-downloads

FROM 763104351884.dkr.ecr.us-east-1.amazonaws.com/tensorflow-inference:2.6.0-cpu-py38-ubuntu20.04 as builder

RUN apt-get update
RUN apt-get install python3.8 -y
COPY requirements.txt .
RUN pip install -r requirements.txt

FROM builder as build
COPY . .
WORKDIR ./

ENV MODEL_BUCKET=""
ENV MODEL_KEY=""

CMD ["uvicorn", "main:app","--host","0.0.0.0","--port","8080"]
