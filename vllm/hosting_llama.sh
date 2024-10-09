#!/bin/sh
#SBATCH --gres=gpu:A6000:2
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 23:00:00
#SBATCH --job-name=llama3_8b_instruct_gpa
#SBATCH --error=/home/ambuja/error/llama3_8b_instruct_gpa.err
#SBATCH --output=/home/ambuja/output/llama3_8b_instruct_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model
source ~/miniconda3/etc/profile.d/conda.sh


export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
source ~/.bashrc

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

conda activate vllm

MODEL="meta-llama/Meta-Llama-3-8B-Instruct" # This is same as the model ID on HF



PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /home/ambuja/download_test/ # Either shared model cache on babel or your own directory
fi
echo $PORT

