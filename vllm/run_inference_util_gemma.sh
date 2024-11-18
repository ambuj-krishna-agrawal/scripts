#!/bin/bash

#SBATCH --job-name=gemma_instruct_cnn
#SBATCH --output=/home/ambuja/output/gemma_instruct_cnn.out
#SBATCH --error=/home/ambuja/error/gemma_instruct_cnn.err
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


MAX_TOKENS=300

MODEL_ADDRESS="http://babel-0-31:8082/v1"
MODEL="google/gemma-2-9b-it"
MODEL_NAME="gemma-2-9b-it"

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