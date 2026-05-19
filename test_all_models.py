import requests
import os
from dotenv import load_dotenv

load_dotenv()

def test_model(name, url, payload, headers=None):
    print(f"Testing {name}...")
    try:
        res = requests.post(url, json=payload, headers=headers, timeout=10)
        if res.status_code == 200:
            print(f"  {name}: SUCCESS")
        else:
            print(f"  {name}: FAILED (Status: {res.status_code}, Response: {res.text[:100]})")
    except Exception as e:
        print(f"  {name}: ERROR ({e})")

# Gemini
gemini_key = os.getenv("GEMINI_API_KEY")
if gemini_key:
    test_model("Gemini", 
               f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={gemini_key}",
               {"contents": [{"parts": [{"text": "test"}]}]})
else:
    print("Gemini: Key missing")

# DeepSeek
ds_key = os.getenv("DEEPSEEK_API_KEY")
if ds_key:
    test_model("DeepSeek",
               "https://api.deepseek.com/v1/chat/completions",
               {"model": "deepseek-chat", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5},
               headers={"Authorization": f"Bearer {ds_key}"})
else:
    print("DeepSeek: Key missing")

# Qwen (DashScope)
qwen_key = os.getenv("DASHSCOPE_API_KEY")
if qwen_key:
     test_model("Qwen",
               "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
               {"model": "qwen-max", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5},
               headers={"Authorization": f"Bearer {qwen_key}"})
else:
    print("Qwen: Key missing")

# Ollama
ollama_url = os.getenv("OLLAMA_BASE_URL", "http://10.255.1.103:11434/v1")
test_model("Ollama",
           f"{ollama_url}/chat/completions",
           {"model": "gemma2", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5})

# vLLM
vllm_url = "http://10.255.1.118:8000/v1"
test_model("vLLM",
           f"{vllm_url}/chat/completions",
           {"model": "gemma-4-moe", "messages": [{"role": "user", "content": "test"}], "max_tokens": 5},
           headers={"Authorization": "Bearer sk-dummy"})
