# Log Monitor Script for PPT Narrator System
# -*- coding: utf-8 -*-

$ErrorActionPreference = "SilentlyContinue"

# 设置输出编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$logFile = "E:\ppt-narrator-app\app.log"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PPT讲稿系统 - 实时日志监控" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[提示] 正在实时显示日志..." -ForegroundColor Green
Write-Host "[提示] 按 Ctrl+C 停止监控（不停止服务）" -ForegroundColor Yellow
Write-Host "[提示] 关闭此窗口不会影响服务运行" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 实时监控日志
Get-Content $logFile -Encoding UTF8 -Wait -Tail 50 | ForEach-Object {
    $line = $_

    # 检测生成进度信息
    if ($line -match '\[INFO\].*正在使用.*处理第.*页') {
        Write-Host $line -ForegroundColor Green
    }
    # 检测生成成功信息
    elseif ($line -match '\[INFO\].*主模型.*生成成功') {
        Write-Host $line -ForegroundColor Green
    }
    # 检测切换备用模型
    elseif ($line -match '\[INFO\].*切换到备用模型') {
        Write-Host $line -ForegroundColor Cyan
    }
    # 检测警告信息
    elseif ($line -match '\[WARNING\]') {
        Write-Host $line -ForegroundColor Yellow
    }
    # 检测错误信息
    elseif ($line -match '\[ERROR\]') {
        Write-Host $line -ForegroundColor Red
    }
    # 检测前端监控信息
    elseif ($line -match '\[前端监控\]') {
        if ($line -match '\[ERROR\]') {
            Write-Host $line -ForegroundColor Red -BackgroundColor DarkCyan
        }
        elseif ($line -match '\[PERF\]') {
            Write-Host $line -ForegroundColor Magenta
        }
        elseif ($line -match '\[BIZ\]') {
            Write-Host $line -ForegroundColor Blue -BackgroundColor White
        }
        else {
            Write-Host $line -ForegroundColor Cyan
        }
    }
    # 其他日志
    else {
        Write-Host $line
    }
}
