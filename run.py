import os
import sys

# 处理 pythonw.exe 的标准输出问题，在导入任何模块前重定向，防止日志或 print 导致 [Errno 22]
if sys.executable.endswith("pythonw.exe"):
    try:
        # 尝试重定向到 devnull
        sys.stdout = open(os.devnull, "w")
        sys.stderr = open(os.devnull, "w")
    except Exception:
        # 极端情况下如果连 devnull 都无法打开（极少见），则设为 None
        sys.stdout = None
        sys.stderr = None

from waitress import serve
from app import app, logger # 从我们的app.py文件中导入名为app的Flask实例和logger
import ctypes

def disable_quick_edit():
    """
    禁用 Windows 控制台的“快速编辑模式” (Quick Edit Mode)。
    该模式下，鼠标点击控制台会导致程序挂起 (假死)，直到按下回车键。
    """
    if sys.platform != "win32":
        return

    try:
        kernel32 = ctypes.windll.kernel32
        hStdIn = kernel32.GetStdHandle(-10) # STD_INPUT_HANDLE
        mode = ctypes.c_ulong()
        if not kernel32.GetConsoleMode(hStdIn, ctypes.byref(mode)):
            return
            
        # ENABLE_QUICK_EDIT_MODE = 0x0040
        # ENABLE_INSERT_MODE = 0x0020
        # ENABLE_MOUSE_INPUT = 0x0010
        # ENABLE_EXTENDED_FLAGS = 0x0080
        
        # 移除快速编辑模式和插入模式
        new_mode = mode.value
        new_mode &= ~0x0040 # 禁用快速编辑
        new_mode &= ~0x0020 # 禁用插入模式
        # new_mode |= 0x0080  # 确保扩展标志被设置 (通常需要)

        kernel32.SetConsoleMode(hStdIn, new_mode)
        logger.info("[OK] System: Disabled Windows console quick edit mode.")
    except Exception as e:
        logger.warning(f"[WARNING] System: Failed to disable quick edit mode: {e}")

if __name__ == '__main__':
    disable_quick_edit()
    logger.info("--- 正在启动生产级Waitress服务器 ---")
    logger.info("--- 服务器运行在 http://0.0.0.0:6001 ---")
    logger.info("--- 现在可以通过浏览器访问 ---")
    serve(app, host='0.0.0.0', port=6001)