import json
import os

def calculate_estimate():
    # 1. Global Analysis phase
    extracted_text_len = 6326
    global_analysis_prompt_base = 500  # Estimated base prompt length
    stage1_input_chars = extracted_text_len + global_analysis_prompt_base
    
    global_json_path = r"E:\ppt-narrator-app\generated\9f6a5095-37c3-4fc3-8b3b-288341d8d4a7\global_analysis.json"
    with open(global_json_path, "r", encoding="utf-8") as f:
        global_json_content = f.read()
    stage1_output_chars = len(global_json_content)
    
    # 2. Stage 2 phase
    script_txt_path = r"E:\ppt-narrator-app\generated\9f6a5095-37c3-4fc3-8b3b-288341d8d4a7\35-6_script.txt"
    with open(script_txt_path, "r", encoding="utf-8") as f:
        script_txt_content = f.read()
    total_stage2_output_chars = len(script_txt_content)
    
    # In stage 2, for each of the 49 slides, the global context and base prompt are sent
    slides_count = 49
    stage2_prompt_base_per_slide = 400 + len(global_json_content) # Base prompt + global context
    total_stage2_input_chars = (stage2_prompt_base_per_slide * slides_count) + extracted_text_len
    
    total_input_chars = stage1_input_chars + total_stage2_input_chars
    total_output_chars = stage1_output_chars + total_stage2_output_chars
    
    # Token estimation: For Chinese + English + JSON mix (like Qwen/Gemma tokenizer)
    # Typically 1 char ~ 0.8 to 1.2 tokens. We'll use 1.0 for simplicity, 
    # but we will output the character count and a token estimate.
    
    print(f"--- 字符数统计 ---")
    print(f"阶段1 (全局分析) 输入字符: {stage1_input_chars:,}")
    print(f"阶段1 (全局分析) 输出字符: {stage1_output_chars:,}")
    print(f"阶段2 (逐页生成) 总输入字符: {total_stage2_input_chars:,} (主要由于全局上下文被重复发送49次)")
    print(f"阶段2 (逐页生成) 总输出字符: {total_stage2_output_chars:,}")
    print(f"总计输入字符数: {total_input_chars:,}")
    print(f"总计输出字符数: {total_output_chars:,}")
    
    # Estimate tokens
    # Using a typical ratio of 1.2 tokens per character for Chinese-heavy prompt in Gemma/vLLM
    ratio = 1.2
    input_tokens = int(total_input_chars * ratio)
    output_tokens = int(total_output_chars * ratio)
    
    print(f"\n--- 预估 Token 消耗 (按 1字符≈1.2 Token 计算) ---")
    print(f"预估 Prompt Tokens: {input_tokens:,}")
    print(f"预估 Completion Tokens: {output_tokens:,}")
    print(f"总预估 Token 消耗: {input_tokens + output_tokens:,}")

if __name__ == "__main__":
    calculate_estimate()
