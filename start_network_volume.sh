#!/usr/bin/env bash

echo "Worker Initiated"

echo "Symlinking files from Network Volume"
ln -s /runpod-volume /workspace
rm -rf /root/.cache
rm -rf /root/.ifnude
rm -rf /root/.insightface
ln -s /runpod-volume/.cache /root/.cache
ln -s /runpod-volume/.ifnude /root/.ifnude
ln -s /runpod-volume/.insightface /root/.insightface

echo "Starting RunPod Handler"
export PYTHONUNBUFFERED=1
source /workspace/runpod-worker-inswapper/venv/bin/activate
cd /workspace/runpod-worker-inswapper
python -u rp_handler.py
