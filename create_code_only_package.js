const fs = require('fs');
const path = require('path');
const archiver = require('archiver').default || require('archiver');

// ========================================
// PPT Narrator - 纯代码打包脚本（分享版）
// ========================================
const sourceDir = 'E:\\ppt-narrator-app';
const releaseDir = 'E:\\share103\\apply\\PPTNarrator-代码包-分享版';
const dateStamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const zipFileName = `PPTNarrator-纯代码-${dateStamp}.zip`;

console.log('========================================');
console.log('PPT Narrator - 纯代码打包脚本');
console.log('========================================\n');

// 创建发布目录
if (!fs.existsSync(releaseDir)) {
    fs.mkdirSync(releaseDir, { recursive: true });
}

// 创建临时目录
const tempDir = path.join(require('os').tmpdir(), `PPTNarrator_Code_${dateStamp}`);
if (fs.existsSync(tempDir)) {
    fs.rmSync(tempDir, { recursive: true, force: true });
}
fs.mkdirSync(tempDir, { recursive: true });

console.log(`✓ 创建临时目录: ${tempDir}\n`);

// ========================================
// 只包含核心代码文件（不包含运行时数据）
// ========================================
const codeFiles = [
    // Python 核心代码
    'app.py',
    'run.py',
    'main.py',
    'calc_tokens.py',
    'windows_service.py',

    // 配置文件
    '.env.example',
    'pyproject.toml',
    'requirements.txt',
    'server_config.json',

    // Windows 批处理脚本
    'start_service.bat',
    'stop_service.bat',
    'check_status.bat',
    'monitor_logs.bat',
    'service_manager.bat',

    // PowerShell 脚本
    'install_task.ps1',
    'log_monitor.ps1',
    'watchdog.ps1',

    // 文档
    'README.md',
    'SECURITY.md',
    '服务启动说明.md',
    '功能说明书.md',
    '脚本使用说明.md',
    'TWO_STAGE_GENERATION.md',
    'TEST_GUIDE.md',
    'AUTO_FALLBACK_SUMMARY.md'
];

// 包含的目录
const codeDirs = [
    'static',
    'templates'
];

console.log('正在复制核心代码文件...\n');

let copiedCount = 0;

// 复制文件
for (const file of codeFiles) {
    const srcPath = path.join(sourceDir, file);
    const destPath = path.join(tempDir, file);

    if (fs.existsSync(srcPath)) {
        fs.copyFileSync(srcPath, destPath);
        console.log(`  ✓ ${file}`);
        copiedCount++;
    } else {
        console.log(`  ⚠ 跳过（不存在）: ${file}`);
    }
}

// 复制目录（只包含代码，不包含用户数据）
for (const dir of codeDirs) {
    const srcPath = path.join(sourceDir, dir);
    const destPath = path.join(tempDir, dir);

    if (fs.existsSync(srcPath)) {
        copyDirectoryRecursive(srcPath, destPath);
        console.log(`  ✓ ${dir}/`);
        copiedCount++;
    }
}

console.log(`\n✓ 已复制 ${copiedCount} 个项目\n`);

// ========================================
// 递归复制目录（排除 .pyc, __pycache__ 等）
// ========================================
function copyDirectoryRecursive(src, dest) {
    if (!fs.existsSync(dest)) {
        fs.mkdirSync(dest, { recursive: true });
    }

    const entries = fs.readdirSync(src, { withFileTypes: true });

    for (const entry of entries) {
        const srcPath = path.join(src, entry.name);
        const destPath = path.join(dest, entry.name);

        // 跳过缓存和临时文件
        if (entry.name === '__pycache__' ||
            entry.name.endsWith('.pyc') ||
            entry.name === '.DS_Store') {
            continue;
        }

        if (entry.isDirectory()) {
            copyDirectoryRecursive(srcPath, destPath);
        } else {
            fs.copyFileSync(srcPath, destPath);
        }
    }
}

// ========================================
// 清理 server_config.json 中的内网地址
// ========================================
const configPath = path.join(tempDir, 'server_config.json');
if (fs.existsSync(configPath)) {
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

    // 将内网地址替换为示例地址
    if (config.ollama_base_url && config.ollama_base_url.includes('10.255.')) {
        config.ollama_base_url = 'http://YOUR_OLLAMA_SERVER:11434/v1';
    }
    if (config.vllm_base_url && config.vllm_base_url.includes('10.255.')) {
        config.vllm_base_url = 'http://YOUR_VLLM_SERVER:8000/v1';
    }

    fs.writeFileSync(configPath, JSON.stringify(config, null, 4));
    console.log('✓ 已清理 server_config.json 中的内网地址\n');
}

// ========================================
// 创建 README.md
// ========================================
const readmeContent = `# PPT Narrator AI 智能讲稿系统

## 📦 快速开始

### 1. 环境要求
- Python 3.14 或更高版本
- uv 包管理器（推荐）或 pip
- Windows 操作系统

### 2. 安装依赖

**使用 uv（推荐）：**
\`\`\`powershell
pip install uv
uv sync
\`\`\`

**使用 pip：**
\`\`\`powershell
pip install -r requirements.txt
\`\`\`

### 3. 配置环境变量

复制配置模板并填入您的 API 密钥：

\`\`\`powershell
copy .env.example .env
\`\`\`

编辑 \`.env\` 文件，配置以下项：
- \`GEMINI_API_KEY\` - Google Gemini API密钥
- \`DEEPSEEK_API_KEY\` - DeepSeek API密钥
- \`DASHSCOPE_API_KEY\` - 阿里通义千问 API密钥
- \`SECRET_KEY\` - Flask会话密钥（生成: \`python -c "import secrets; print(secrets.token_hex(32))"\`）
- \`ADMIN_PASSWORD_HASH\` - 管理员密码哈希（生成: \`python -c "import bcrypt; print(bcrypt.hashpw(b'你的密码', bcrypt.gensalt()).decode())"\`）

### 4. 启动服务

**开发模式：**
\`\`\`powershell
python run.py
\`\`\`

**生产模式：**
\`\`\`powershell
start_service.bat
\`\`\`

服务将在 http://localhost:6001 启动

### 5. 使用说明

访问 http://localhost:6001，上传PPT文件即可生成智能讲稿。

## 📚 详细文档

- **功能说明书.md** - 完整功能介绍
- **服务启动说明.md** - 详细部署指南
- **脚本使用说明.md** - 管理脚本说明
- **TWO_STAGE_GENERATION.md** - 两阶段生成引擎说明
- **SECURITY.md** - 安全配置说明

## 🔒 安全说明

本代码包已排除以下敏感信息：
- ✗ API 密钥（.env 文件）
- ✗ 日志文件（*.log）
- ✗ 用户上传文件（uploads/）
- ✗ 生成文件（generated/）
- ✗ 加密密钥（*.key）
- ✗ Python缓存（__pycache__, .venv）
- ✗ 内网IP地址（已替换为示例地址）

## ⚠️ 重要提示

**首次运行前请务必：**
1. 复制 \`.env.example\` 为 \`.env\`
2. 填入您的 API 密钥
3. 生成并配置 SECRET_KEY 和 ADMIN_PASSWORD_HASH

**不包含运行时数据：**
- 本代码包不包含 \`uploads/\` 和 \`generated/\` 目录
- 这些目录会在首次运行时自动创建
- 无需手动创建

## 📄 许可证

本项目代码开源，供学习和使用。

---

**版本**: v1.0
**更新日期**: ${new Date().toISOString().slice(0, 10)}
**技术支持**: 基于AI辅助开发，完整文档见配套资源
`;

fs.writeFileSync(path.join(tempDir, 'README.md'), readmeContent, 'utf8');
console.log('✓ 已创建 README.md\n');

// ========================================
// 创建 .gitignore
// ========================================
const gitignoreContent = `# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/

# 环境配置
.env
config_key.key
encrypted_config.key

# 日志
*.log

# 用户数据
uploads/
generated/
query/

# 临时文件
*.tmp
*.bak
nul

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
`;

fs.writeFileSync(path.join(tempDir, '.gitignore'), gitignoreContent, 'utf8');
console.log('✓ 已创建 .gitignore\n');

// ========================================
// 创建ZIP压缩包
// ========================================
console.log('正在创建压缩包...\n');

const outputZip = path.join(releaseDir, zipFileName);
const output = fs.createWriteStream(outputZip);
const archive = archiver('zip', { zlib: { level: 9 } });

output.on('close', () => {
    console.log('========================================');
    console.log('打包完成！');
    console.log('========================================\n');
    console.log(`压缩包位置: ${outputZip}`);
    console.log(`压缩包大小: ${(archive.pointer() / 1024 / 1024).toFixed(2)} MB\n`);

    console.log('包含内容:');
    console.log('  ✓ 核心Python代码（app.py, run.py等）');
    console.log('  ✓ 前端资源（static/, templates/）');
    console.log('  ✓ 配置模板（.env.example, server_config.json）');
    console.log('  ✓ 管理脚本（.bat, .ps1）');
    console.log('  ✓ 完整文档（.md文件）\n');

    console.log('已排除:');
    console.log('  ✗ API密钥（.env）');
    console.log('  ✗ 日志文件（*.log）');
    console.log('  ✗ 用户数据（uploads/, generated/）');
    console.log('  ✗ 密钥文件（*.key）');
    console.log('  ✗ Python缓存（__pycache__, .venv）');
    console.log('  ✗ 内网IP地址（已替换）\n');

    console.log('✓ 纯代码包，可安全分享！ 🎉\n');

    // 清理临时目录
    fs.rmSync(tempDir, { recursive: true, force: true });
    console.log('✓ 临时目录已清理');
});

archive.on('error', (err) => {
    console.error('压缩失败:', err);
    process.exit(1);
});

archive.pipe(output);
archive.directory(tempDir, false);
archive.finalize();
