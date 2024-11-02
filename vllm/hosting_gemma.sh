#!/bin/sh
#SBATCH --gres=gpu:A6000:2
#SBATCH --partition=general
#SBATCH --mem=64GB
#SBATCH --time 23:00:00
#SBATCH --job-name=gemma-2-9b-it_gpa
#SBATCH --error=/home/ambuja/error/gemma-2-9b-it_gpa.err
#SBATCH --output=/home/ambuja/output/gemma-2-9b-it_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model
source ~/miniconda3/etc/profile.d/conda.sh


export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
source ~/.bashrc

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"

conda activate vllm

MODEL="google/gemma-2-9b-it" # This is same as the model ID on HF
# MODEL="meta-llama/Meta-Llama-3-8B-Instruct" # This is same as the model ID on HF



PORT=8082
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /home/ambuja/download_test/
        --tensor-parallel-size 2  # Either shared model cache on babel or your own directory
fi
echo $PORT

