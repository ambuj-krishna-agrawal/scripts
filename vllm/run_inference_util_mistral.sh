#!/bin/bash

#SBATCH --job-name=mistral_instruct
#SBATCH --output=/home/ambuja/output/mistral_instruct.out
#SBATCH --error=/home/ambuja/error/mistral_instruct.err
#SBATCH --nodes=1
#SBATCH --mem=16GB
#SBATCH --time 0-6:55:00
#SBATCH --partition=debug
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu


echo $SLURM_JOB_ID

source ~/.bashrc
conda init bash
conda activate vllm


MAX_TOKENS=250

MODEL_ADDRESS="http://babel-2-29:8083/v1"
MODEL="mistralai/Mistral-7B-Instruct-v0.3"
MODEL_NAME="Mistral_7B_Instruct_v0.3"

PROMPTS="/home/ambuja/LLMRouting/data/test_gsm8k_queries.json"
OUTPUT="/home/ambuja/LLMRouting/data/test_gsm8k_${MODEL_NAME}_responses.tsv"
 
python query.py \
    --prompts="${PROMPTS}" \
    --output="${OUTPUT}" \
    --model=${MODEL} \
    --base_url=${MODEL_ADDRESS} \
    --max_response_tokens=${MAX_TOKENS} \
    --requests_per_minute=100 \
    --num_responses_per_prompt=1