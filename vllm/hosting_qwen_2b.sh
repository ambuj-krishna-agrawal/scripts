#!/bin/sh
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=128GB
#SBATCH --time 23:00:00
#SBATCH --job-name=2b_qwen_vision_awq_gpa
#SBATCH --error=/home/ambuja/logs/error/2b_qwen_vision_awq_gpa.err
#SBATCH --output=/home/ambuja/logs/output/2b_qwen_vision_awq_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu
#SBATCH --exclude=babel-4-37

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

MODEL="Qwen/Qwen2-VL-2B-Instruct-AWQ"



PORT=8088
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /scratch/ambuja/model \
        --trust-remote-code \
        --quantization awq
fi
echo $PORT