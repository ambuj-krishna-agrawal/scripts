#!/bin/bash

#SBATCH --job-name=llama3.1_gsm8k
#SBATCH --output=/home/ambuja/output/llama3.1_gsm8k.out
#SBATCH --error=/home/ambuja/error/llama3.1_gsm8k.err
#SBATCH --nodes=1
#SBATCH --mem=16GB
#SBATCH --time 0-6:55:00
#SBATCH --partition=debug
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu


echo $SLURM_JOB_ID

source ~/.bashrc
conda init bash
source ~/anaconda3/etc/profile.d/conda.sh
conda activate vllm
python -m pip show transformers

MAX_TOKENS=200

MODEL_ADDRESS="http://babel-0-31:8081/v1"
MODEL="meta-llama/Llama-3.2-1B"
MODEL_NAME="metallama_3.2_1b"

PROMPTS="/home/ambuja/LLMRouting/data/train_gsm8k_queries_llama3.1.json"
OUTPUT="/home/ambuja/LLMRouting/data/train_gsm8k_${MODEL_NAME}_responses.tsv"
 
python query.py \
    --prompts="${PROMPTS}" \
    --output="${OUTPUT}" \
    --model=${MODEL} \
    --base_url=${MODEL_ADDRESS} \
    --max_response_tokens=${MAX_TOKENS} \
    --requests_per_minute=100 \
    --num_responses_per_prompt=1