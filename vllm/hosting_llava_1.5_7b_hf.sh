#!/bin/sh
#SBATCH --gres=gpu:L40S:2
#SBATCH --partition=general
#SBATCH --mem=128GB
#SBATCH --time 23:00:00
#SBATCH --job-name=13b_llava_1_5
#SBATCH --error=/home/ambuja/logs/error/13b_llava_1_5_gpa.err
#SBATCH --output=/home/ambuja/logs/output/13b_llava_1_5_gpa.out
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
conda activate vllm

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"



MODEL="TheBloke/llava-v1.5-13B-AWQ"



PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /scratch/ambuja/model \
        --trust-remote-code \
        --tensor-parallel-size 2
fi
echo $PORT