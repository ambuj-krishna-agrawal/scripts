#!/bin/sh
#SBATCH --gres=gpu:A6000:2
#SBATCH --partition=general
#SBATCH --mem=64GB
#SBATCH --time 23:00:00
#SBATCH --job-name=70b_3.1_llama_gpa
#SBATCH --error=/home/ambuja/logs/error/llama3.1_70b_gpa.err
#SBATCH --output=/home/ambuja/logs/output/llama3.1_70b_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model
source ~/miniconda3/etc/profile.d/conda.sh


export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
source ~/.bashrc

conda activate vllm
python -m pip show transformers
python -m pip show vllm

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"



# MODEL="meta-llama/Llama-3.2-1B" # This is same as the model ID on HF
MODEL="meta-llama/Llama-3.1-70B-Instruct"
# MODEL="meta-llama/Llama-3.2-3B-Instruct"

# MODEL="meta-llama/Llama-3.1-8B-Instruct"



PORT=8083
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    export TRUST_REMOTE_CODE=True  
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /home/ambuja/download_test/   
fi
echo $PORT

