#!/bin/bash

#SBATCH --job-name=g2_intersentence
#SBATCH --output=/home/shailyjb/intrinsic-bias-metaeval/logs/g2_intersentence.out
#SBATCH --error=/home/shailyjb/intrinsic-bias-metaeval/logs/g2_intersentence.err
#SBATCH --nodes=1
#SBATCH --mem=16GB
#SBATCH --time 0-12:55:00
#SBATCH --partition=cpu
#SBATCH --mail-type=END
#SBATCH --mail-user=shailyjb@andrew.cmu.edu
#SBATCH --exclude=shire-1-6,inst-0-35,shire-1-10


echo $SLURM_JOB_ID

source ~/.bashrc
conda init bash
conda activate pc2


MAX_TOKENS=50

MODEL_ADDRESS="http://babel-4-23:8081/v1"
MODEL="google/gemma-2b-it"
MODEL_NAME="gemma2B_it"

PROMPTS="/home/shailyjb/intrinsic-bias-metaeval/stereoset_data/intersentence_prompts.csv"
OUTPUT="/home/shailyjb/intrinsic-bias-metaeval/stereoset_data/gemma2B_predictions/intersentence_responses.tsv"

python /home/shailyjb/intrinsic-bias-metaeval/stereoset_query.py \
    --prompts="${PROMPTS}" \
    --output="${OUTPUT}" \
    --model=${MODEL} \
    --base_url=${MODEL_ADDRESS} \
    --max_response_tokens=${MAX_TOKENS} \
    --requests_per_minute=100 \
    --num_responses_per_prompt=1