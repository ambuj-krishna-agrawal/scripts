#!/bin/sh
#SBATCH --gres=gpu:A6000:4
#SBATCH --partition=general
#SBATCH --mem=128GB
#SBATCH --time 23:00:00
#SBATCH --job-name=7b_qwen_vision_awq_gpa
#SBATCH --error=/home/ambuja/logs/error/7b_qwen_vision_awq_gpa.err
#SBATCH --output=/home/ambuja/logs/output/7b_qwen_vision_awq_gpa.out
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



# MODEL="meta-llama/Llama-3.1-8B-Instruct" 
# MODEL="microsoft/Phi-3.5-vision-instruct"
MODEL="Qwen/Qwen2-VL-7B-Instruct-AWQ"



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
        --quantization awq \
        --tensor-parallel-size 4
fi
echo $PORT