#!/bin/sh
#SBATCH --gres=gpu:A6000:1
#SBATCH --partition=general
#SBATCH --mem=32GB
#SBATCH --time 23:00:00
#SBATCH --job-name=llama3.2_1_instruct_gpa
#SBATCH --error=/home/ambuja/error/llama3.2_1_instruct_gpa.err
#SBATCH --output=/home/ambuja/output/llama3.2_1_instruct_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model
source ~/miniconda3/etc/profile.d/conda.sh


export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
source ~/.bashrc

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"




conda activate vllm
python -m pip show transformers
MODEL="meta-llama/Llama-3.2-1B" # This is same as the model ID on HF



PORT=8081
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /scratch/ambuja/model/ \
        
fi
echo $PORT

