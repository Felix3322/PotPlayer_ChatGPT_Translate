import os
import sys
import ctypes
import threading
import shutil
import requests
import win32com.client
import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog
import webbrowser
import winreg
import hashlib

PLUGIN_VERSION = "1.5.2"

LANGUAGE_STRINGS = {
    "en": {
        "admin_required": "This installer needs to be run with administrator privileges.\nPlease restart as administrator.",
        "select_directory": "Please select the PotPlayer Translate directory.",
        "installation_complete": "Installation completed successfully!",
        "choose_version": "Choose the version to install:",
        "without_context": "Installer without Context Handling",
        "with_context": "Installer with Context Handling",
        "installation_failed": "Installation failed: {}",
        "welcome_message": "Welcome to the PotPlayer ChatGPT Translate Installer (v1.5.2)\n\nPlease follow the steps to install.",
        "new_installer_notice": "This new installer is ready. Press Next to continue.",
        "select_install_dir": "Select the PotPlayer Translate directory:",
        "browse": "Browse",
        "next": "Next",
        "back": "Back",
        "choose_language": "Choose your language:",
        "language_english": "English",
        "language_chinese": "中文",
        "with_context_description": "Advanced context-aware processing (more accurate but higher cost).",
        "without_context_description": "Lightweight version without context (lower cost).",
        "confirm_path": "Detected PotPlayer path:\n{}\nIs this correct?",
        "license_title": "License Agreement",
        "license_agree": "I Agree",
        "license_disagree": "I Disagree",
        "license_reject": "You must agree to the license to continue.",
        "install_progress": "Installation Progress:",
        "cancel": "Cancel",
        "finish": "Finish",
        "author_info": "Author: Felix3322  |  Project: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate",
        "file_exists_3choice": "File {} already exists.\n\nPlease choose:\n- Overwrite & Upgrade\n- Rename\n- Cancel",
        "installation_cancelled": "Installation cancelled by user.",
        "custom_name_prompt": "Please enter the new file name:",
        "custom_name_empty": "Custom name cannot be empty. Installation cancelled.",
        "ask_reg_write": "Detected file exists but not registered for uninstall. Write uninstall info to registry for easier uninstallation?",
        "ask_reg_upgrade": "Detected registry info for this plugin, update registry entry for new version?",
        "ask_reg_new": "No registry uninstall info found. Write uninstall info to registry for easier uninstallation?",
        "config_title": "Verify API Settings",
        "config_model": "Model:",
        "config_api": "API URL:",
        "config_key": "API Key:",
        "verify": "Verify",
        "verifying": "Verifying...",
        "verify_success": "Verification passed.",
        "verify_fail": "Verification failed:\n{}"
    },
    "zh": {
        "admin_required": "此安装器需要以管理员权限运行，请以管理员身份重启。",
        "select_directory": "请选择PotPlayer的Translate目录。",
        "installation_complete": "安装成功！",
        "choose_version": "请选择安装的版本：",
        "without_context": "不带上下文处理的安装包",
        "with_context": "带上下文处理的安装包",
        "installation_failed": "安装失败：{}",
        "welcome_message": "欢迎使用PotPlayer ChatGPT 翻译安装程序 (v1.5.2)\n\n请按照步骤完成安装。",
        "new_installer_notice": "新的安装器已就绪，按“下一步”继续。",
        "select_install_dir": "请选择PotPlayer的Translate目录：",
        "browse": "浏览",
        "next": "下一步",
        "back": "上一步",
        "choose_language": "选择语言：",
        "language_english": "English",
        "language_chinese": "中文",
        "with_context_description": "高级上下文处理（翻译更精准，但成本较高）。",
        "without_context_description": "轻量版（不带上下文处理，成本较低）。",
        "confirm_path": "检测到的PotPlayer路径：\n{}\n是否正确？",
        "license_title": "许可协议",
        "license_agree": "我同意",
        "license_disagree": "我不同意",
        "license_reject": "必须同意许可协议才能继续。",
        "install_progress": "安装进度：",
        "cancel": "取消",
        "finish": "完成",
        "author_info": "作者: Felix3322  |  项目: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate",
        "file_exists_3choice": "文件 {} 已存在。\n\n请选择：\n- 覆盖升级\n- 重命名\n- 取消",
        "installation_cancelled": "用户取消了安装。",
        "custom_name_prompt": "请输入新的文件名:",
        "custom_name_empty": "文件名不能为空，安装已取消",
        "ask_reg_write": "检测到文件已存在但未注册卸载信息，是否写入注册表以便卸载？",
        "ask_reg_upgrade": "检测到已有卸载注册表项，是否更新为新版本？",
        "ask_reg_new": "未发现卸载注册表项，是否写入注册表以便卸载？",
        "config_title": "验证 API 设置",
        "config_model": "模型名称:",
        "config_api": "API 地址:",
        "config_key": "API Key:",
        "verify": "验证",
        "verifying": "正在验证...",
        "verify_success": "验证成功。",
        "verify_fail": "验证失败:\n{}"
    }
}

OFFLINE_FILES = {
    "with_context": [
        ("SubtitleTranslate - ChatGPT.as", "SubtitleTranslate - ChatGPT.as"),
        ("SubtitleTranslate - ChatGPT.ico", "SubtitleTranslate - ChatGPT.ico")
    ],
    "without_context": [
        ("SubtitleTranslate - ChatGPT - Without Context.as", "SubtitleTranslate - ChatGPT - Without Context.as"),
        ("SubtitleTranslate - ChatGPT - Without Context.ico", "SubtitleTranslate - ChatGPT - Without Context.ico")
    ]
}

# ========= 工具函数 =========

def merge_bilingual(key):
    return LANGUAGE_STRINGS["en"][key] + "\n\n" + LANGUAGE_STRINGS["zh"][key]

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False

def restart_as_admin():
    messagebox.showwarning("Admin Required", merge_bilingual("admin_required"))
    params = " ".join([f'"{arg}"' for arg in sys.argv])
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, params, None, 1)
    sys.exit()

def get_path_from_shortcut(shortcut_path):
    try:
        shell = win32com.client.Dispatch("WScript.Shell")
        shortcut = shell.CreateShortcut(shortcut_path)
        return shortcut.TargetPath
    except Exception:
        return None

def scan_shortcuts():
    search_dirs = [
        os.path.join(os.environ.get("USERPROFILE", ""), "Desktop"),
        os.path.join(os.environ.get("APPDATA", ""), "Microsoft", "Windows", "Start Menu", "Programs"),
        r"C:\Users\Public\Desktop",
        r"C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    ]
    for base in search_dirs:
        if os.path.exists(base):
            for root, dirs, files in os.walk(base):
                for file in files:
                    if file.lower().endswith(".lnk") and "potplayer" in file.lower():
                        shortcut_path = os.path.join(root, file)
                        target = get_path_from_shortcut(shortcut_path)
                        if target and os.path.exists(target):
                            translate_dir = os.path.join(os.path.dirname(target), "Extension", "Subtitle", "Translate")
                            if os.path.exists(translate_dir):
                                return translate_dir
    return None

def get_path_from_installation_dir():
    base_dirs = [r"C:\Program Files\DAUM\PotPlayer"]
    for drive in [f"{chr(x)}:\\" for x in range(65, 91) if os.path.exists(f"{chr(x)}:\\")]:
        base_dirs.append(os.path.join(drive, "DAUM", "PotPlayer"))
    for d in base_dirs:
        if os.path.exists(d):
            translate_dir = os.path.join(d, "Extension", "Subtitle", "Translate")
            if os.path.exists(translate_dir):
                return translate_dir
    return None

def scan_drives():
    for drive in [f"{chr(x)}:\\" for x in range(65, 91) if os.path.exists(f"{chr(x)}:\\")]:
        path = os.path.join(drive, "Program Files", "DAUM", "PotPlayer", "Extension", "Subtitle", "Translate")
        if os.path.exists(path):
            return path
    return None

def auto_detect_directory():
    detected = scan_shortcuts()
    if detected:
        return detected
    detected = get_path_from_installation_dir()
    if detected:
        return detected
    return scan_drives()

def read_license():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    license_path = os.path.join(script_dir, "LICENSE")
    if os.path.exists(license_path):
        with open(license_path, "r", encoding="utf-8") as f:
            return f.read()
    return "LICENSE file not found."

def ensure_dir_exists(path):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

def verify_api_settings(model, api_url, api_key):
    api_url = api_url.strip().rstrip('/') or "https://api.openai.com/v1/chat/completions"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    data = {
        "model": model,
        "messages": [
            {"role": "system", "content": "You are a test assistant."},
            {"role": "user", "content": "Hello"}
        ],
        "max_tokens": 1,
        "temperature": 0
    }
    try:
        r = requests.post(api_url, json=data, timeout=10, headers=headers)
        if r.ok and r.json().get("choices"):
            return True, ""
        msg = r.json().get("error", {}).get("message", "Invalid response")
    except Exception as e:
        msg = str(e)
    if "chat/completions" not in api_url:
        corrected = api_url + "/chat/completions"
        try:
            r = requests.post(corrected, json=data, timeout=10, headers=headers)
            if r.ok and r.json().get("choices"):
                return True, f"Warning: Your API base was auto-corrected to: {corrected}"
        except Exception:
            pass
    return False, msg

def reg_key_name(install_dir, context_type):
    id_base = os.path.abspath(install_dir).lower() + "|" + context_type
    id_hash = hashlib.md5(id_base.encode("utf-8")).hexdigest()[:8]
    return f"PotPlayer_ChatGPT_Translate_{id_hash}"

def find_existing_reg_info(install_dir, context_type):
    regname = reg_key_name(install_dir, context_type)
    try:
        reg_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\\" + regname
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path)
        version, _ = winreg.QueryValueEx(key, "DisplayVersion")
        uninstall_str, _ = winreg.QueryValueEx(key, "UninstallString")
        context_type_val, _ = winreg.QueryValueEx(key, "ContextType")
        key.Close()
        return {"key": regname, "version": version, "uninstall": uninstall_str, "context": context_type_val}
    except Exception:
        return None

def register_software(display_name, uninstall_path, install_dir, key_name, version, context_type):
    reg_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\\" + key_name
    key = winreg.CreateKey(winreg.HKEY_LOCAL_MACHINE, reg_path)
    winreg.SetValueEx(key, "DisplayName", 0, winreg.REG_SZ, display_name)
    winreg.SetValueEx(key, "UninstallString", 0, winreg.REG_SZ, uninstall_path)
    winreg.SetValueEx(key, "InstallLocation", 0, winreg.REG_SZ, install_dir)
    winreg.SetValueEx(key, "Publisher", 0, winreg.REG_SZ, "Felix3322")
    winreg.SetValueEx(key, "DisplayIcon", 0, winreg.REG_SZ, uninstall_path)
    winreg.SetValueEx(key, "DisplayVersion", 0, winreg.REG_SZ, version)
    winreg.SetValueEx(key, "ContextType", 0, winreg.REG_SZ, context_type)
    key.Close()

def generate_uninstaller(uninstall_bat_path, files_to_delete, reg_key_name):
    with open(uninstall_bat_path, "w", encoding="utf-8") as f:
        f.write("@echo off\n")
        f.write("REM PotPlayer ChatGPT Translate 卸载脚本\n\n")
        for file in files_to_delete:
            if os.path.isdir(file):
                f.write(f'rmdir /s /q "{file}"\n')
            else:
                f.write(f'del "{file}" /f /q\n')
        f.write('del "%~f0" /f /q\n')
        f.write(f'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{reg_key_name}" /f\n')
        f.write("\nexit\n")

# ========= 自定义三按钮弹窗 =========
def custom_file_exists_dialog(parent, title, msg, btn1, btn2, btn3):
    result = [None]
    win = tk.Toplevel(parent)
    win.title(title)
    win.geometry("400x200")
    win.grab_set()
    tk.Label(win, text=msg, wraplength=380).pack(pady=25)
    frame = tk.Frame(win)
    frame.pack(pady=10)
    def on_select(val):
        result[0] = val
        win.destroy()
    tk.Button(frame, text=btn1, width=14, command=lambda: on_select('overwrite')).pack(side="left", padx=5)
    tk.Button(frame, text=btn2, width=14, command=lambda: on_select('rename')).pack(side="left", padx=5)
    tk.Button(frame, text=btn3, width=14, command=lambda: on_select(None)).pack(side="left", padx=5)
    win.wait_window()
    return result[0]

# ========= 安装线程 =========
class InstallThread(threading.Thread):
    def __init__(self, parent, install_dir, version, script_dir, callback):
        super().__init__()
        self.parent = parent
        self.install_dir = install_dir
        self.version = version  # "with_context"/"without_context"
        self.script_dir = script_dir
        self.callback = callback
        self.files_installed = []

    def run(self):
        lang = self.callback.__self__.language
        s = LANGUAGE_STRINGS[lang]
        context_type = self.version
        key_name = reg_key_name(self.install_dir, context_type)
        display_name = f"PotPlayer ChatGPT Translate v{PLUGIN_VERSION} [{'With context' if context_type=='with_context' else 'Without context'}]"
        reginfo = find_existing_reg_info(self.install_dir, context_type)
        reg_write = False  # 是否要写注册表
        try:
            ensure_dir_exists(self.install_dir)
            for src_file, dest_name in OFFLINE_FILES.get(self.version, []):
                src_path = os.path.join(self.script_dir, src_file)
                dest_path = os.path.join(self.install_dir, dest_name)
                self.callback(f"Copying {src_file} ...")
                if not os.path.exists(src_path):
                    self.callback(f"Error: Missing file {src_file}.")
                    return
                if os.path.exists(dest_path):
                    # === 自定义三按钮弹窗 ===
                    choice = custom_file_exists_dialog(
                        self.parent,
                        "File Exists",
                        s["file_exists_3choice"].format(dest_name),
                        "覆盖升级", "重命名", "取消"
                    )
                    if choice is None:
                        self.callback(merge_bilingual("installation_cancelled"))
                        return
                    elif choice == "overwrite":
                        shutil.copy(src_path, dest_path)
                        self.callback(f"Installed {dest_name} (Overwritten).")
                        self.files_installed.append(dest_path)
                        # 判断是否已有注册表（有则升级，无则询问新建）
                        if reginfo:
                            # 升级，弹窗是否更新注册表
                            if messagebox.askyesno("注册表", s["ask_reg_upgrade"]):
                                reg_write = True
                        else:
                            # 手动/历史文件，询问是否补注册表
                            if messagebox.askyesno("注册表", s["ask_reg_write"]):
                                reg_write = True
                    elif choice == "rename":
                        while True:
                            new_name = simpledialog.askstring("Custom Name", s["custom_name_prompt"])
                            if new_name is None:
                                self.callback(merge_bilingual("installation_cancelled"))
                                return
                            new_name = new_name.strip()
                            if not new_name:
                                messagebox.showerror("Error", s["custom_name_empty"])
                                continue
                            if not os.path.splitext(new_name)[1]:
                                new_name += os.path.splitext(dest_name)[1]
                            new_dest_path = os.path.join(self.install_dir, new_name)
                            if os.path.exists(new_dest_path):
                                messagebox.showerror("Error", s["file_exists_3choice"].format(new_name))
                                continue
                            shutil.copy(src_path, new_dest_path)
                            self.callback(f"Installed {new_name}.")
                            self.files_installed.append(new_dest_path)
                            # 重命名的安装通常没有注册表，问是否写入注册表
                            if messagebox.askyesno("注册表", s["ask_reg_new"]):
                                reg_write = True
                            break
                else:
                    shutil.copy(src_path, dest_path)
                    self.callback(f"Installed {dest_name}.")
                    self.files_installed.append(dest_path)
                    # 纯新增问是否写注册表（未装/新文件）
                    if messagebox.askyesno("注册表", s["ask_reg_new"]):
                        reg_write = True

            # ========== 卸载脚本 & 注册表 ================
            if reg_write:
                tools_dir = os.path.join(self.install_dir, "tools")
                ensure_dir_exists(tools_dir)
                uninstaller_path = os.path.join(tools_dir, f"uninstaller_{key_name}.bat")
                files_to_delete = list(self.files_installed)
                files_to_delete.append(uninstaller_path)
                generate_uninstaller(uninstaller_path, files_to_delete, key_name)
                register_software(
                    display_name=display_name,
                    uninstall_path=uninstaller_path,
                    install_dir=self.install_dir,
                    key_name=key_name,
                    version=PLUGIN_VERSION,
                    context_type=context_type
                )
            self.callback(merge_bilingual("installation_complete"))
            self.callback("DONE")
        except Exception as e:
            self.callback(merge_bilingual("installation_failed").format(str(e)))
            return

# ========= UI =========
class InstallerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.language = "en"
        self.strings = LANGUAGE_STRINGS[self.language]
        self.install_dir = ""
        self.version = ""
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.title("PotPlayer ChatGPT Translate Installer")
        self.geometry("500x450")
        self.resizable(False, False)
        self.frames = {}
        for F in (LanguageFrame, WelcomeFrame, LicenseFrame, DirectoryFrame, VersionFrame, ConfigFrame, ProgressFrame, FinishFrame):
            page_name = F.__name__
            frame = F(parent=self, controller=self)
            self.frames[page_name] = frame
            frame.place(relwidth=1, relheight=1)
        self.show_frame("LanguageFrame")

    def show_frame(self, page_name):
        frame = self.frames[page_name]
        frame.tkraise()
        if hasattr(frame, "on_show"):
            frame.on_show()

    def update_progress(self, msg):
        self.frames["ProgressFrame"].append_text(msg)

    def start_installation(self):
        thread = InstallThread(self, self.install_dir, self.version, self.script_dir, self.install_callback)
        thread.start()

    def install_callback(self, msg):
        self.after(0, lambda: self.update_progress(msg))
        if msg == "DONE":
            self.after(2000, lambda: self.show_frame("FinishFrame"))

class LanguageFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lang_var = tk.StringVar(value="en")
        lbl = tk.Label(self, text=controller.strings["choose_language"], font=("Arial", 12))
        lbl.pack(pady=20)
        rb_en = tk.Radiobutton(self, text=controller.strings["language_english"], variable=self.lang_var, value="en", font=("Arial", 10))
        rb_en.pack(pady=5)
        rb_zh = tk.Radiobutton(self, text=controller.strings["language_chinese"], variable=self.lang_var, value="zh", font=("Arial", 10))
        rb_zh.pack(pady=5)
        btn = tk.Button(self, text=controller.strings["next"], width=12, command=self.select_language)
        btn.pack(pady=20)
    def select_language(self):
        self.controller.language = self.lang_var.get()
        self.controller.strings = LANGUAGE_STRINGS[self.lang_var.get()]
        self.controller.show_frame("WelcomeFrame")

class WelcomeFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 14), wraplength=400)
        self.lbl.pack(pady=40)
        self.btn = tk.Button(self, text="", width=12, command=lambda: controller.show_frame("LicenseFrame"))
        self.btn.pack(pady=20)
        self.author = tk.Label(self, text=controller.strings["author_info"], font=("Arial", 10), fg="blue", cursor="hand2")
        self.author.pack(side="bottom", pady=10)
        self.author.bind("<Button-1>", lambda e: webbrowser.open("https://github.com/Felix3322/PotPlayer_ChatGPT_Translate"))
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["welcome_message"])
        self.btn.config(text=s["next"])
        self.author.config(text=s["author_info"])

class LicenseFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.title_lbl = tk.Label(self, text=self.controller.strings["license_title"], font=("Arial", 14))
        self.title_lbl.pack(pady=10)
        self.text_area = tk.Text(self, height=15, width=60)
        self.text_area.insert(tk.END, read_license())
        self.text_area.config(state="disabled")
        self.text_area.pack(pady=10)
        frm = tk.Frame(self)
        frm.pack(pady=10)
        self.agree_btn = tk.Button(frm, text=self.controller.strings["license_agree"], width=15, command=self.agree)
        self.agree_btn.pack(side="left", padx=5)
        self.disagree_btn = tk.Button(frm, text=self.controller.strings["license_disagree"], width=15, command=self.disagree)
        self.disagree_btn.pack(side="left", padx=5)
    def agree(self):
        self.controller.show_frame("DirectoryFrame")
    def disagree(self):
        messagebox.showwarning("Warning", self.controller.strings["license_reject"])
        self.controller.destroy()

class DirectoryFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        self.dir_var = tk.StringVar()
        self.entry = tk.Entry(self, textvariable=self.dir_var, width=50, state="readonly")
        self.entry.pack(pady=10)
        self.browse_btn = tk.Button(self, text="", width=10, command=self.browse)
        self.browse_btn.pack(pady=5)
        self.err_lbl = tk.Label(self, text="", fg="red")
        self.err_lbl.pack(pady=5)
        frm = tk.Frame(self)
        frm.pack(side="bottom", pady=20)
        self.back_btn = tk.Button(frm, text="", width=10, command=lambda: controller.show_frame("LicenseFrame"))
        self.back_btn.pack(side="left", padx=10)
        self.next_btn = tk.Button(frm, text="", width=10, command=self.next_step)
        self.next_btn.pack(side="right", padx=10)
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["select_install_dir"])
        self.browse_btn.config(text=s["browse"])
        self.back_btn.config(text=s["back"])
        self.next_btn.config(text=s["next"])
        detected = auto_detect_directory()
        if detected:
            if messagebox.askyesno("Confirm", s["confirm_path"].format(detected)):
                self.dir_var.set(detected)
                self.controller.install_dir = detected
                self.controller.show_frame("VersionFrame")
            else:
                self.dir_var.set("")
        else:
            self.dir_var.set("")
    def browse(self):
        d = filedialog.askdirectory()
        if d:
            self.dir_var.set(d)
            self.err_lbl.config(text="")
    def next_step(self):
        if self.dir_var.get():
            self.controller.install_dir = self.dir_var.get()
            self.controller.show_frame("VersionFrame")
        else:
            self.err_lbl.config(text=self.controller.strings["select_directory"])

class VersionFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        self.version_var = tk.StringVar(value="with_context")
        self.rb1 = tk.Radiobutton(self, text="", variable=self.version_var, value="with_context", font=("Arial", 10))
        self.rb1.pack(pady=5)
        self.desc1 = tk.Label(self, text="", font=("Arial", 9), wraplength=450, justify="left")
        self.desc1.pack(pady=2)
        self.rb2 = tk.Radiobutton(self, text="", variable=self.version_var, value="without_context", font=("Arial", 10))
        self.rb2.pack(pady=5)
        self.desc2 = tk.Label(self, text="", font=("Arial", 9), wraplength=450, justify="left")
        self.desc2.pack(pady=2)
        frm = tk.Frame(self)
        frm.pack(side="bottom", pady=20)
        self.back_btn = tk.Button(frm, text="", width=10, command=lambda: controller.show_frame("DirectoryFrame"))
        self.back_btn.pack(side="left", padx=10)
        self.next_btn = tk.Button(frm, text="", width=10, command=self.next_step)
        self.next_btn.pack(side="right", padx=10)

    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["choose_version"])
        self.rb1.config(text=s["with_context"])
        self.desc1.config(text=s["with_context_description"])
        self.rb2.config(text=s["without_context"])
        self.desc2.config(text=s["without_context_description"])
        self.back_btn.config(text=s["back"])
        self.next_btn.config(text=s["next"])

    def next_step(self):
        self.controller.version = self.version_var.get()
        self.controller.show_frame("ConfigFrame")

class ConfigFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        frm = tk.Frame(self)
        frm.pack(pady=5)
        self.lbl_model = tk.Label(frm, text="")
        self.lbl_model.grid(row=0, column=0, sticky="e", padx=5, pady=5)
        self.model_entry = tk.Entry(frm, width=40)
        self.model_entry.grid(row=0, column=1, padx=5, pady=5)
        self.lbl_api = tk.Label(frm, text="")
        self.lbl_api.grid(row=1, column=0, sticky="e", padx=5, pady=5)
        self.api_entry = tk.Entry(frm, width=40)
        self.api_entry.grid(row=1, column=1, padx=5, pady=5)
        self.lbl_key = tk.Label(frm, text="")
        self.lbl_key.grid(row=2, column=0, sticky="e", padx=5, pady=5)
        self.key_entry = tk.Entry(frm, width=40, show="*")
        self.key_entry.grid(row=2, column=1, padx=5, pady=5)
        self.status = tk.Label(self, text="", fg="red", wraplength=400)
        self.status.pack(pady=5)
        btnf = tk.Frame(self)
        btnf.pack(side="bottom", pady=20)
        self.back_btn = tk.Button(btnf, text="", width=10, command=lambda: controller.show_frame("VersionFrame"))
        self.verify_btn = tk.Button(btnf, text="", width=10, command=self.verify)
        self.next_btn = tk.Button(btnf, text="", width=10, command=self.next_step)
        self.back_btn.pack(side="left", padx=5)
        self.verify_btn.pack(side="left", padx=5)
        self.next_btn.pack(side="right", padx=5)

    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["config_title"])
        self.lbl_model.config(text=s["config_model"])
        self.lbl_api.config(text=s["config_api"])
        self.lbl_key.config(text=s["config_key"])
        self.back_btn.config(text=s["back"])
        self.verify_btn.config(text=s["verify"])
        self.next_btn.config(text=s["next"])
        if not self.model_entry.get():
            self.model_entry.insert(0, "gpt-4o")
        if not self.api_entry.get():
            self.api_entry.insert(0, "https://api.openai.com/v1/chat/completions")

    def verify(self):
        s = self.controller.strings
        self.status.config(text=s["verifying"], fg="black")
        self.update()
        ok, msg = verify_api_settings(
            self.model_entry.get().strip(),
            self.api_entry.get().strip(),
            self.key_entry.get().strip(),
        )
        if ok:
            self.status.config(text=msg or s["verify_success"], fg="green")
            return True
        else:
            self.status.config(text=s["verify_fail"].format(msg), fg="red")
            return False

    def next_step(self):
        if self.verify():
            self.controller.show_frame("ProgressFrame")

class ProgressFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        self.txt = tk.Text(self, height=10, width=60, state="disabled")
        self.txt.pack(pady=5)
        frm = tk.Frame(self)
        frm.pack(side="bottom", pady=10)
        self.cancel_btn = tk.Button(frm, text="", width=10, command=self.controller.destroy)
        self.cancel_btn.pack()
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["install_progress"])
        self.cancel_btn.config(text=s["cancel"])
        self.txt.config(state="normal")
        self.txt.delete(1.0, tk.END)
        self.txt.config(state="disabled")
        self.controller.update_progress("Starting installation...\n开始安装...")
        self.controller.start_installation()
    def append_text(self, msg):
        self.txt.config(state="normal")
        self.txt.insert(tk.END, msg+"\n")
        self.txt.see(tk.END)
        self.txt.config(state="disabled")

class FinishFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 14))
        self.lbl.pack(pady=40)
        self.finish_btn = tk.Button(self, text="", width=12, command=controller.destroy)
        self.finish_btn.pack(pady=20)
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["installation_complete"])
        self.finish_btn.config(text=s["finish"])

def main():
    if not is_admin():
        restart_as_admin()

    app = InstallerApp()
    app.mainloop()

if __name__ == "__main__":
    main()
