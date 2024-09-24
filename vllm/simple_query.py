import requests

# Define the base URL for your vllm server

BASE_URL = "http://babel-x-x:PORT/v1:8081"

# Define the model to use
MODEL = "meta-llama/Meta-Llama-7B-Instruct"

# Define the input prefix
prefix = "Once upon a time in a land far away,"

# Prepare the payload for the request
payload = {
    "model": MODEL,
    "prompt": prefix,
    "max_new_tokens": 50,  # Adjust the number of tokens to generate
    "temperature": 0.7,  # Controls randomness: higher is more random
    "top_p": 0.9,  # Nucleus sampling
}

# Make the POST request to the vllm server
response = requests.post(f"{BASE_URL}/generate", json=payload)

# Check if the request was successful
if response.status_code == 200:
    generated_text = response.json().get("generated_text", "")

    # Write the generated text to a file
    output_file = "generated_output.txt"  # Specify the output file name
    with open(output_file, "w") as file:
        file.write(generated_text)

    print(f"Generated text written to {output_file}.")
else:
    print(f"Error: {response.status_code} - {response.text}")
