#!/bin/bash

#SBATCH --job-name=llama_instruct_cnn
#SBATCH --output=/home/ambuja/output/llama_instruct_cnn.out
#SBATCH --error=/home/ambuja/error/llama_instruct_cnn.err
#SBATCH --nodes=1
#SBATCH --mem=16GB
#SBATCH --time 0-12:55:00
#SBATCH --partition=debug
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu


echo $SLURM_JOB_ID

source ~/.bashrc
conda init bash
conda activate vllm


MAX_TOKENS=200

MODEL_ADDRESS="http://babel-1-31:8081/v1"
MODEL="meta-llama/Meta-Llama-3-8B-Instruct"
MODEL_NAME="Meta-Llama-3-8B-Instruct"

PROMPTS="/home/ambuja/gpa/summarization/data/new_prompts.csv"
OUTPUT="/home/ambuja/gpa/summarization/data/${MODEL_NAME}_total_2_responses.tsv"
 
python query.py \
    --prompts="${PROMPTS}" \
    --output="${OUTPUT}" \
    --model=${MODEL} \
    --base_url=${MODEL_ADDRESS} \
    --max_response_tokens=${MAX_TOKENS} \
    --requests_per_minute=100 \
    --num_responses_per_prompt=1