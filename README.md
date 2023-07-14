# Inswapper | RunPod Serverless Worker

This is the source code for a [RunPod](https://runpod.io?ref=w18gds2n)
worker that uses [inswapper](
https://huggingface.co/deepinsight/inswapper/tree/main) for face
swapping AI tasks.

## Model

The worker uses the [inswapper_128.onnx](
https://huggingface.co/deepinsight/inswapper/resolve/main/inswapper_128.onnx)
model by [InsightFace](https://insightface.ai/).

## Building the Worker

#### Note: This worker requires a RunPod Network Volume with inswapper preinstalled in order to function correctly.

### Option 1: Network Volume

This will store your application on a Runpod Network Volume and
build a light weight Docker image that runs everything
from the Network volume without installing the application
inside the Docker image.

1. [Create a RunPod Account](https://runpod.io?ref=w18gds2n).
2. Create a [RunPod Network Volume](https://www.runpod.io/console/user/storage).
3. Attach the Network Volume to a Secure Cloud [GPU pod](https://www.runpod.io/console/gpu-secure-cloud).
4. Select a light-weight template such as RunPod Pytorch.
5. Deploy the GPU Cloud pod.
6. Once the pod is up, open a Terminal and install the required dependencies:
```bash
cd /workspace
git clone https://github.com/ashleykleynhans/runpod-worker-inswapper.git
cd runpod-worker-inswapper
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
mkdir checkpoints
wget -O ./checkpoints/inswapper_128.onnx https://huggingface.co/deepinsight/inswapper/resolve/main/inswapper_128.onnx
apt update
apt -y install git-lfs
git lfs install
git clone https://huggingface.co/spaces/sczhou/CodeFormer
```
7. Edit the `create_test_json.py` file and ensure that you set `SOURCE_IMAGE` to
   a valid image to upscale (you can upload the image to your pod using
   [runpodctl](https://github.com/runpod/runpodctl/releases)).
8. Create the `test_input.json` file by running the `create_test_json.py` script:
```bash
python3 create_test_json.py
```
9. Run an inference on the `test_input.json` input so that the models can be cached on
   your Network Volume, which will dramatically reduce cold start times for RunPod Serverless:
```bash
python3 -u rp_handler.py
```
10. Sign up for a Docker hub account if you don't already have one.
11. Build the Docker image:
```bash
docker build -t dockerhub-username/runpod-worker-inswapper:1.0.0 -f Dockerfile.Network_Volume .
docker login
docker push dockerhub-username/runpod-worker-inswapper:1.0.0
```

### Option 2: Standalone

This is the simpler option.  No network volume is required.
The entire application will be stored within the Docker image
but will obviously create a more bulky Docker image as a result.

```bash
docker build -t dockerhub-username/runpod-worker-inswapper:1.0.0 -f Dockerfile.Standalone .
docker login
docker push dockerhub-username/runpod-worker-inswapper:1.0.0
```

## Dockerfile

There are 2 different Dockerfile configurations

1. Network_Volume - See Option 1 Above.
2. Standalone - See Option 2 Above (No Network Volume is required for this option).

The worker is built using one of the two Dockerfile configurations
depending on your specific requirements.

## API

The worker provides an API for inference. The API payload looks like this:

```json
{
  "input": {
    "source_image": "base64 encoded source image content",
    "target_image": "base64 encoded target image content",
  }
}
```

## Serverless Handler

The serverless handler (`rp_handler.py`) is a Python script that handles
inference requests.  It defines a function handler(event) that takes an
inference request, runs the inference using the [inswapper](
https://huggingface.co/deepinsight/inswapper/tree/main) model (and
CodeFormer where applicable), and returns the output as a JSON response in
the following format:

```json
{
  "output": {
    "status": "ok",
    "image": "base64 encoded output image"
  }
}
```
