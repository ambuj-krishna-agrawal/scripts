#!/bin/sh
#SBATCH --gres=gpu:A6000:2
#SBATCH --partition=general
#SBATCH --mem=64GB
#SBATCH --time 23:00:00
#SBATCH --job-name=70b_3.3_llama_gpa
#SBATCH --error=/home/ambuja/logs/error/llama3.3_70b_instruct_gpa.err
#SBATCH --output=/home/ambuja/logs/output/llama3.3_70b_instruct_gpa.out
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
MODEL="ibnzterrell/Meta-Llama-3.3-70B-Instruct-AWQ-INT4"



PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    export TRUST_REMOTE_CODE=True 
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /scratch/ambuja/model \
        --quantization awq \
        --tensor-parallel-size 2 # Either shared model cache on babel or your own directory
fi
echo $PORT

