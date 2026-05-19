import os
import sys
import win32serviceutil
import win32service
import win32event
import servicemanager
import socket
import threading
import time

# Create a local debug log since SCM hides console output
DEBUG_LOG = r"E:\ppt-narrator-app\service_debug.log"

def debug_print(msg):
    with open(DEBUG_LOG, "a", encoding="utf-8") as f:
        f.write(f"[{time.ctime()}] {msg}\n")

debug_print("Script loaded")

class PPTNarratorService(win32serviceutil.ServiceFramework):
    _svc_name_ = "PPT_Narrator_Service"
    _svc_display_name_ = "PPT Narrator AI 智能生成服务"
    _svc_description_ = "基于 AI 的 PPT 讲稿自动生成系统，提供 Web 访问接口及后台生成功能。"

    def __init__(self, args):
        debug_print("Service __init__ started")
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.stop_event = win32event.CreateEvent(None, 0, 0, None)
        self.running = True
        debug_print("Service __init__ finished")

    def SvcStop(self):
        debug_print("SvcStop signal received")
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        win32event.SetEvent(self.stop_event)
        self.running = False

    def SvcDoRun(self):
        debug_print("SvcDoRun started")
        # 1. Immediate report to avoid 2186 timeout
        self.ReportServiceStatus(win32service.SERVICE_START_PENDING)
        
        # 2. Set directory
        current_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(current_dir)
        sys.path.append(current_dir)
        debug_print(f"CWD set to: {current_dir}")

        # 3. Quick report to RUNNING
        self.ReportServiceStatus(win32service.SERVICE_RUNNING)
        debug_print("Reported SERVICE_RUNNING")

        try:
            # 4. DEFERRED IMPORTS (Do heavy lifting AFTER reporting running)
            debug_print("Starting deferred imports...")
            from waitress import serve
            from app import app, logger
            debug_print("Imports successful")
            
            self.app = app
            self.logger = logger
            self.serve = serve
            
            logger.info("[SERVICE] Service started. Starting main loop...")
            self.main()
        except Exception as e:
            debug_print(f"FATAL ERROR: {str(e)}")
            import traceback
            debug_print(traceback.format_exc())
            self.SvcStop()

    def main(self):
        server_thread = threading.Thread(target=self.run_server)
        server_thread.daemon = True
        server_thread.start()
        debug_print("Server thread started, waiting for stop event...")
        win32event.WaitForSingleObject(self.stop_event, win32event.INFINITE)
        debug_print("Exiting main()")

    def run_server(self):
        try:
            debug_print("Calling serve()...")
            self.serve(self.app, host='0.0.0.0', port=6001)
        except Exception as e:
            debug_print(f"Server crash: {str(e)}")

if __name__ == '__main__':
    debug_print(f"__main__ with args: {sys.argv}")
    if len(sys.argv) == 1:
        debug_print("Starting ServiceCtrlDispatcher")
        servicemanager.Initialize()
        servicemanager.PrepareToHostSingle(PPTNarratorService)
        servicemanager.StartServiceCtrlDispatcher()
    else:
        win32serviceutil.HandleCommandLine(PPTNarratorService)
