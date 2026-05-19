# PPT Narrator AI (PPT讲稿AI生成系统)

PPT Narrator AI is a powerful web application designed to automatically generate high-quality narrator scripts and presentation notes for PowerPoint (`.pptx`) files. It leverages advanced Large Language Models (LLMs) through a two-stage generation process to ensure accurate, engaging, and professional speaker notes.

## ✨ Features

- **Automated Script Generation:** Upload any `.pptx` file and the AI will analyze the content to generate comprehensive speaker notes for each slide.
- **Two-Stage Generation Architecture:** Uses an advanced two-stage prompt engineering approach (Analysis -> Generation) for higher quality and contextual consistency.
- **Multi-Model Support:** Seamlessly integrates with multiple LLM providers:
  - Local Models (Ollama /vllm gemma 4)
  - Google Gemini
  - glm -4v
  - Alibaba Qwen
- **Real-time Monitoring:** Includes a dedicated PowerShell-based color-coded log monitoring console to track background tasks, API performance, and frontend interactions.
- **Robust Background Service:** Runs reliably as a background service managed by Windows batch scripts.
- **Modern Package Management:** Uses `uv` for lightning-fast Python dependency management.

## 🚀 Installation & Setup

1. **Prerequisites:**
   - [Python 3.11+](https://www.python.org/)
   - [uv](https://github.com/astral-sh/uv) (Extremely fast Python package installer)

2. **Clone the repository:**
   ```bash
   git clone https://github.com/elibwudi/pptna.git
   cd pptna
   ```

3. **Configure Environment:**
   Copy the example environment file and fill in your API keys:
   ```bash
   copy .env.example .env
   ```
   *(Note: Add your Gemini, DeepSeek, or Qwen API keys in the `.env` file. Local Ollama instances work out of the box).*

4. **Start the Service:**
   Simply double-click the `start_service.bat` script in the root directory. 
   The script will:
   - Automatically install and sync all dependencies using `uv`.
   - Start the Waitress/Flask backend on `http://localhost:6001`.
   - Open a real-time log monitoring window.

5. **Access the App:**
   Open your browser and navigate to: `http://localhost:6001`

## 🛠️ Management Scripts

- `start_service.bat`: Starts the background service and opens the monitor.
- `stop_service.bat`: Safely terminates the background service.
- `monitor_logs.bat`: Opens the real-time logging dashboard manually.
- `check_status.bat`: Checks if the service is currently running.

## 🛡️ Privacy & Security

This repository is strictly code-only. All API keys, encrypted configurations, uploaded user presentations, and AI-generated content are excluded via `.gitignore` to ensure data privacy.

## 📄 License

MIT License
