#!/bin/sh
#SBATCH --gres=gpu:A6000:2
#SBATCH --partition=general
#SBATCH --mem=64GB
#SBATCH --time 23:00:00
#SBATCH --job-name=phi_3_5_vision_gpa
#SBATCH --error=/home/ambuja/logs/error/phi_3_5_vision_gpa_final.err
#SBATCH --output=/home/ambuja/logs/output/phi_3_5_vision_gpa_final.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu
#SBATCH --exclude=babel-0-23

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



# MODEL="meta-llama/Llama-3.1-8B-Instruct" 
MODEL="microsoft/Phi-3.5-vision-instruct"
# MODEL="meta-llama/Llama-3.2-11B-Vision"



PORT=8084
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

