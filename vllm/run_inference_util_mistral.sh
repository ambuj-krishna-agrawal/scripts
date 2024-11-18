#!/bin/bash

#SBATCH --job-name=mistral_instruct_cnn
#SBATCH --output=/home/ambuja/output/mistral_instruct_cnn.out
#SBATCH --error=/home/ambuja/error/mistral_instruct_cnn.err
#SBATCH --nodes=1
#SBATCH --mem=16GB
#SBATCH --time 0-12:55:00
#SBATCH --partition=general
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu
#SBATCH --exclude=shire-1-6,inst-0-35,shire-1-10


echo $SLURM_JOB_ID

source ~/.bashrc
conda init bash
conda activate vllm


MAX_TOKENS=200

MODEL_ADDRESS="http://babel-11-17:8083/v1"
MODEL="mistralai/Mistral-7B-Instruct-v0.3"
MODEL_NAME="Mistral-7B-Instruct-v0.3"

PROMPTS="/home/ambuja/gpa/summarization/data/prompts.csv"
OUTPUT="/home/ambuja/gpa/summarization/data/${MODEL_NAME}_responses.tsv"
 
python query.py \
    --prompts="${PROMPTS}" \
    --output="${OUTPUT}" \
    --model=${MODEL} \
    --base_url=${MODEL_ADDRESS} \
    --max_response_tokens=${MAX_TOKENS} \
    --requests_per_minute=100 \
    --num_responses_per_prompt=1