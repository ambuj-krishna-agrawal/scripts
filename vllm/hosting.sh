#!/bin/sh
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 1-23:55:00
#SBATCH --job-name=a6_llama3_8b_instruct
#SBATCH --error=a6_llama3_8b_instruct.err
#SBATCH --output=a6_llama38b_instruct.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model || { echo "Failed to create /scratch/ambuja/model"; exit 1; }
mkdir -p /home/ambuja/hf_cache || { echo "Failed to create /home/ambuja/hf_cache"; exit 1; }
mkdir -p /home/ambuja/download_test || { echo "Failed to create /home/ambuja/download_test"; exit 1; }

source ~/miniconda3/etc/profile.d/conda.sh || { echo "Failed to source conda"; exit 1; }
conda activate testing_llama || { echo "Failed to activate conda environment"; exit 1; }

export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory

# Ensure bashrc is sourced if needed
source ~/.bashrc || { echo "Failed to source .bashrc"; exit 1; }

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

MODEL="meta-llama/Meta-Llama-3-8B-Instruct" # This is same as the model ID on HF


PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /home/ambuja/download_test/ || { echo "Failed to start vLLM server"; exit 1; }# Either shared model cache on babel or your own directory
fi
echo $PORT

# Print the port in use
echo "vLLM API Server running on port $PORT"