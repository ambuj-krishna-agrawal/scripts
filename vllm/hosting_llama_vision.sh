#!/bin/sh
#SBATCH --gres=gpu:L40S:4
#SBATCH --partition=general
#SBATCH --mem=128GB
#SBATCH --time 23:00:00
#SBATCH --job-name=vision3_2_11b_gpa
#SBATCH --error=/home/ambuja/logs/error/11b_llama_3_2_vision_gpa.err
#SBATCH --output=/home/ambuja/logs/output/11b_llama_3_2_vision_gpa.out
#SBATCH --mail-type=END
#SBATCH --mail-user=ambuja@andrew.cmu.edu

mkdir -p /scratch/ambuja/model
source ~/miniconda3/etc/profile.d/conda.sh


export HF_HOME=/home/ambuja/hf_cache # Ideally it helps to have <DIR> in `/data/..` on Babel to not overcrowd /home/.. directory
export NCCL_DEBUG=INFO
export NCCL_P2P_DISABLE=1
export NCCL_IB_DISABLE=1
export NCCL_IB_HCA=mlx5_0
source ~/.bashrc
conda activate vllm

HUGGINGFACE_TOKEN="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"
huggingface-cli login --token "${HUGGINGFACE_TOKEN}"


MODEL="meta-llama/Llama-3.2-11B-Vision"



PORT=8088
if ss -tulwn | grep -q ":$PORT "; then
    echo "Port $PORT is already in use. Exiting..."
    exit 1
else
    python -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --port $PORT \
        --download-dir /scratch/ambuja/model \
        --gpu-memory-utilization 0.8 \
        --trust-remote-code \
        --tensor-parallel-size 4
fi
echo $PORT

# # --quantization awq \

# #!/bin/sh
# #SBATCH --partition=general
# #SBATCH --gres=gpu:L40S:8
# #SBATCH --mem=500Gb
# #SBATCH --cpus-per-task=40
# #SBATCH -t 2-00:00:00              # time limit:  add - for days (D-HH:MM)
# #SBATCH --job-name=generate_drafts_72B
# #SBATCH --error=/home/lmaben/code-edit-bench/logs/commit_data/drafts/job_outputs/%x__%j.err
# #SBATCH --output=/home/lmaben/code-edit-bench/logs/commit_data/drafts/job_outputs/%x__%j.out
# #SBATCH --mail-type=ALL
# #SBATCH --mail-user=lmaben@andrew.cmu.edu    
# source /data/tir/projects/tir7/user_data/lmaben/miniconda3/etc/profile.d/conda.sh
# conda activate code-edit-bench
# cd /home/lmaben/code-edit-bench

# export HF_DATASETS_CACHE=/data/tir/projects/tir7/user_data/lmaben/hf_cache_dir
# export VLLM_CACHE_DIR=/data/tir/projects/tir7/user_data/lmaben/vllm_cache_dir
# export HF_HOME=/data/tir/projects/tir7/user_data/lmaben/hf_home_dir
# export NCCL_P2P_DISABLE=1

# vllm serve "Qwen/Qwen2.5-72B-Instruct"  --tensor-parallel-size 8 --host 0.0.0.0 --port 8000 &