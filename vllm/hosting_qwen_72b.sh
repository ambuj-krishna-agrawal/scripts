#!/bin/sh
#SBATCH --gres=gpu:A6000:4
#SBATCH --partition=general
#SBATCH --mem=64GB
#SBATCH --time 23:00:00
#SBATCH --job-name=72b_qwen_vision_awq_gpa
#SBATCH --error=/home/ambuja/logs/error/72b_qwen_vision_awq_gpa.err
#SBATCH --output=/home/ambuja/logs/output/72b_qwen_vision_awq_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model
source ~/miniconda3/etc/profile.d/conda.sh


export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
export NCCL_DEBUG=INFO
export NCCL_P2P_DISABLE=1
export NCCL_IB_DISABLE=1
export NCCL_IB_HCA=mlx5_0
source ~/.bashrc
conda activate vllm_clean

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

MODEL="Qwen/Qwen2-VL-72B-Instruct-AWQ"



PORT=8082
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /scratch/ambuja/model \
        --trust-remote-code \
        --quantization awq \
        --tensor-parallel-size 4
fi
echo $PORT