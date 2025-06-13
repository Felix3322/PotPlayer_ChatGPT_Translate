# -*- coding: utf-8 -*-
"""PyQt6 based installer for PotPlayer ChatGPT Translate"""
import os
import sys
import ctypes
import threading
import shutil
import json
import urllib.request
import win32com.client
import webbrowser
import winreg
import hashlib
import re

from PyQt6 import QtWidgets, QtCore

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
        "skip": "Skip",
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
        "skip": "跳过",
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

# ========= Utils =========

def merge_bilingual(key):
    return LANGUAGE_STRINGS["en"][key] + "\n\n" + LANGUAGE_STRINGS["zh"][key]


def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False


def restart_as_admin():
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
        r"C:\\Users\\Public\\Desktop",
        r"C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs"
    ]
    for base in search_dirs:
        if os.path.exists(base):
            for root, _, files in os.walk(base):
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
    base_dirs = [r"C:\\Program Files\\DAUM\\PotPlayer"]
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
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    payload = json.dumps({
        "model": model,
        "messages": [
            {"role": "system", "content": "You are a test assistant."},
            {"role": "user", "content": "Hello"},
        ],
        "max_tokens": 1,
        "temperature": 0,
    }).encode("utf-8")

    def post(url: str):
        req = urllib.request.Request(url, data=payload, headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read().decode("utf-8"))

    try:
        resp_json = post(api_url)
        if resp_json.get("choices"):
            return True, ""
        msg = resp_json.get("error", {}).get("message", "Invalid response")
    except Exception as e:
        msg = str(e)

    if "chat/completions" not in api_url:
        corrected = api_url.rstrip('/') + "/chat/completions"
        try:
            resp_json = post(corrected)
            if resp_json.get("choices"):
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
        f.write("REM PotPlayer ChatGPT Translate uninstall script\n\n")
        for file in files_to_delete:
            if os.path.isdir(file):
                f.write(f'rmdir /s /q "{file}"\n')
            else:
                f.write(f'del "{file}" /f /q\n')
        f.write('del "%~f0" /f /q\n')
        f.write(f'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{reg_key_name}" /f\n')
        f.write("\nexit\n")

def apply_preconfig(file_path, api_key, model, api_base):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = f.read()
        data = re.sub(r'pre_api_key\s*=\s*".*?"', f'pre_api_key = "{api_key}"', data)
        data = re.sub(r'pre_selected_model\s*=\s*".*?"', f'pre_selected_model = "{model}"', data)
        data = re.sub(r'pre_apiUrl\s*=\s*".*?"', f'pre_apiUrl = "{api_base}"', data)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(data)
    except Exception:
        pass

# ========= Dialog Helpers =========

def custom_file_exists_dialog(parent, title, msg, btn1, btn2, btn3):
    box = QtWidgets.QMessageBox(parent)
    box.setWindowTitle(title)
    box.setText(msg)
    overwrite = box.addButton(btn1, QtWidgets.QMessageBox.ButtonRole.AcceptRole)
    rename = box.addButton(btn2, QtWidgets.QMessageBox.ButtonRole.ActionRole)
    cancel = box.addButton(btn3, QtWidgets.QMessageBox.ButtonRole.RejectRole)
    box.exec()
    if box.clickedButton() == overwrite:
        return 'overwrite'
    if box.clickedButton() == rename:
        return 'rename'
    return None

# ========= Installation Thread =========
class InstallThread(QtCore.QThread):
    progress = QtCore.pyqtSignal(str)

    def __init__(self, install_dir, version, script_dir, language, api_key, model, api_base):
        super().__init__()
        self.install_dir = install_dir
        self.version = version
        self.script_dir = script_dir
        self.language = language
        self.api_key = api_key
        self.model = model
        self.api_base = api_base
        self.files_installed = []

    def run(self):
        lang = self.language
        s = LANGUAGE_STRINGS[lang]
        context_type = self.version
        key_name = reg_key_name(self.install_dir, context_type)
        display_name = f"PotPlayer ChatGPT Translate v{PLUGIN_VERSION} [{'With context' if context_type=='with_context' else 'Without context'}]"
        reginfo = find_existing_reg_info(self.install_dir, context_type)
        reg_write = False
        try:
            ensure_dir_exists(self.install_dir)
            for src_file, dest_name in OFFLINE_FILES.get(self.version, []):
                src_path = os.path.join(self.script_dir, src_file)
                dest_path = os.path.join(self.install_dir, dest_name)
                self.progress.emit(f"Copying {src_file} ...")
                if not os.path.exists(src_path):
                    self.progress.emit(f"Error: Missing file {src_file}.")
                    return
                if os.path.exists(dest_path):
                    choice = custom_file_exists_dialog(None, "File Exists", s["file_exists_3choice"].format(dest_name), "Overwrite", "Rename", s["cancel"])
                    if choice is None:
                        self.progress.emit(merge_bilingual("installation_cancelled"))
                        return
                    elif choice == "overwrite":
                        shutil.copy(src_path, dest_path)
                        apply_preconfig(dest_path, self.api_key, self.model, self.api_base)
                        self.progress.emit(f"Installed {dest_name} (Overwritten).")
                        self.files_installed.append(dest_path)
                        if reginfo:
                            box = QtWidgets.QMessageBox
                            if box.question(None, "Registry", s["ask_reg_upgrade"], box.StandardButton.Yes | box.StandardButton.No) == box.StandardButton.Yes:
                                reg_write = True
                        else:
                            if QtWidgets.QMessageBox.question(None, "Registry", s["ask_reg_write"], QtWidgets.QMessageBox.StandardButton.Yes | QtWidgets.QMessageBox.StandardButton.No) == QtWidgets.QMessageBox.StandardButton.Yes:
                                reg_write = True
                    elif choice == "rename":
                        while True:
                            ok, new_name = QtWidgets.QInputDialog.getText(None, "Custom Name", s["custom_name_prompt"])
                            if not ok:
                                self.progress.emit(merge_bilingual("installation_cancelled"))
                                return
                            new_name = new_name.strip()
                            if not new_name:
                                QtWidgets.QMessageBox.warning(None, "Error", s["custom_name_empty"])
                                continue
                            if not os.path.splitext(new_name)[1]:
                                new_name += os.path.splitext(dest_name)[1]
                            new_dest_path = os.path.join(self.install_dir, new_name)
                            if os.path.exists(new_dest_path):
                                QtWidgets.QMessageBox.warning(None, "Error", s["file_exists_3choice"].format(new_name))
                                continue
                            shutil.copy(src_path, new_dest_path)
                            apply_preconfig(new_dest_path, self.api_key, self.model, self.api_base)
                            self.progress.emit(f"Installed {new_name}.")
                            self.files_installed.append(new_dest_path)
                            if QtWidgets.QMessageBox.question(None, "Registry", s["ask_reg_new"], QtWidgets.QMessageBox.StandardButton.Yes | QtWidgets.QMessageBox.StandardButton.No) == QtWidgets.QMessageBox.StandardButton.Yes:
                                reg_write = True
                            break
                else:
                    shutil.copy(src_path, dest_path)
                    apply_preconfig(dest_path, self.api_key, self.model, self.api_base)
                    self.progress.emit(f"Installed {dest_name}.")
                    self.files_installed.append(dest_path)
                    if QtWidgets.QMessageBox.question(None, "Registry", s["ask_reg_new"], QtWidgets.QMessageBox.StandardButton.Yes | QtWidgets.QMessageBox.StandardButton.No) == QtWidgets.QMessageBox.StandardButton.Yes:
                        reg_write = True

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
            self.progress.emit(merge_bilingual("installation_complete"))
            self.progress.emit("DONE")
        except Exception as e:
            self.progress.emit(merge_bilingual("installation_failed").format(str(e)))
            return

# ========= Wizard Pages =========
class LanguagePage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.rb_en = QtWidgets.QRadioButton()
        self.rb_zh = QtWidgets.QRadioButton()
        self.rb_en.setChecked(True)
        layout.addWidget(QtWidgets.QLabel())
        layout.addWidget(self.rb_en)
        layout.addWidget(self.rb_zh)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle(s["choose_language"])
        self.rb_en.setText(s["language_english"])
        self.rb_zh.setText(s["language_chinese"])

    def validatePage(self):
        self.wizard.language = 'zh' if self.rb_zh.isChecked() else 'en'
        self.wizard.strings = LANGUAGE_STRINGS[self.wizard.language]
        return True

class WelcomePage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.label = QtWidgets.QLabel()
        self.label.setWordWrap(True)
        layout.addWidget(self.label)
        self.author = QtWidgets.QLabel()
        self.author.setOpenExternalLinks(True)
        layout.addWidget(self.author)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle("PotPlayer ChatGPT Translate")
        self.label.setText(s["welcome_message"])
        self.author.setText(f"<a href='https://github.com/Felix3322/PotPlayer_ChatGPT_Translate'>{s['author_info']}</a>")

class LicensePage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.text = QtWidgets.QTextEdit()
        self.text.setReadOnly(True)
        layout.addWidget(self.text)
        self.chk = QtWidgets.QCheckBox()
        layout.addWidget(self.chk)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle(s["license_title"])
        self.text.setPlainText(read_license())
        self.chk.setText(s["license_agree"])

    def isComplete(self):
        return self.chk.isChecked()

    def validatePage(self):
        if not self.chk.isChecked():
            QtWidgets.QMessageBox.warning(self, "Warning", self.wizard.strings["license_reject"])
            return False
        return True

class DirectoryPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.lbl = QtWidgets.QLabel()
        layout.addWidget(self.lbl)
        h = QtWidgets.QHBoxLayout()
        self.edit = QtWidgets.QLineEdit()
        h.addWidget(self.edit)
        self.browse = QtWidgets.QPushButton()
        self.browse.clicked.connect(self.on_browse)
        h.addWidget(self.browse)
        layout.addLayout(h)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle(s["select_install_dir"])
        self.lbl.setText("")
        self.browse.setText(s["browse"])
        detected = auto_detect_directory()
        if detected:
            if QtWidgets.QMessageBox.question(self, "Confirm", s["confirm_path"].format(detected), QtWidgets.QMessageBox.StandardButton.Yes | QtWidgets.QMessageBox.StandardButton.No) == QtWidgets.QMessageBox.StandardButton.Yes:
                self.edit.setText(detected)
        self.edit.textChanged.emit(self.edit.text())

    def on_browse(self):
        d = QtWidgets.QFileDialog.getExistingDirectory(self, self.wizard.strings["select_directory"])
        if d:
            self.edit.setText(d)

    def validatePage(self):
        if not self.edit.text():
            QtWidgets.QMessageBox.warning(self, "Error", self.wizard.strings["select_directory"])
            return False
        self.wizard.install_dir = self.edit.text()
        return True

class VersionPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.rb1 = QtWidgets.QRadioButton()
        self.rb2 = QtWidgets.QRadioButton()
        self.desc1 = QtWidgets.QLabel()
        self.desc1.setWordWrap(True)
        self.desc2 = QtWidgets.QLabel()
        self.desc2.setWordWrap(True)
        self.rb1.setChecked(True)
        layout.addWidget(self.rb1)
        layout.addWidget(self.desc1)
        layout.addWidget(self.rb2)
        layout.addWidget(self.desc2)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle(s["choose_version"])
        self.rb1.setText(s["with_context"])
        self.rb2.setText(s["without_context"])
        self.desc1.setText(s["with_context_description"])
        self.desc2.setText(s["without_context_description"])

    def validatePage(self):
        self.wizard.version = 'without_context' if self.rb2.isChecked() else 'with_context'
        return True

class ConfigPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        form = QtWidgets.QFormLayout()
        self.model_edit = QtWidgets.QLineEdit()
        self.api_edit = QtWidgets.QLineEdit()
        self.key_edit = QtWidgets.QLineEdit()
        self.key_edit.setEchoMode(QtWidgets.QLineEdit.EchoMode.Password)
        form.addRow("", self.model_edit)
        form.addRow("", self.api_edit)
        form.addRow("", self.key_edit)
        layout.addLayout(form)
        self.status = QtWidgets.QLabel()
        layout.addWidget(self.status)
        self.verify_btn = QtWidgets.QPushButton()
        self.verify_btn.clicked.connect(self.verify)
        layout_h = QtWidgets.QHBoxLayout()
        layout_h.addWidget(self.verify_btn)
        self.skip_btn = QtWidgets.QPushButton()
        self.skip_btn.clicked.connect(self.on_skip)
        layout_h.addWidget(self.skip_btn)
        layout.addLayout(layout_h)
        self.skip = False
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle(s["config_title"])
        labels = [s["config_model"], s["config_api"], s["config_key"]]
        form = self.layout().itemAt(0)
        form.setWidget(0, QtWidgets.QFormLayout.ItemRole.LabelRole, QtWidgets.QLabel(labels[0]))
        form.setWidget(1, QtWidgets.QFormLayout.ItemRole.LabelRole, QtWidgets.QLabel(labels[1]))
        form.setWidget(2, QtWidgets.QFormLayout.ItemRole.LabelRole, QtWidgets.QLabel(labels[2]))
        self.verify_btn.setText(s["verify"])
        self.skip_btn.setText(s["skip"])
        self.skip = False
        if not self.model_edit.text():
            self.model_edit.setText(self.wizard.model)
        if not self.api_edit.text():
            self.api_edit.setText(self.wizard.api_base)

    def verify(self):
        s = self.wizard.strings
        self.status.setText(s["verifying"])
        QtWidgets.QApplication.processEvents()
        ok, msg = verify_api_settings(
            self.model_edit.text().strip(),
            self.api_edit.text().strip(),
            self.key_edit.text().strip(),
        )
        if ok:
            self.status.setText(msg or s["verify_success"])
            return True
        else:
            self.status.setText(s["verify_fail"].format(msg))
            return False

    def on_skip(self):
        self.skip = True
        self.wizard().next()

    def validatePage(self):
        self.wizard.model = self.model_edit.text().strip() or self.wizard.model
        self.wizard.api_base = self.api_edit.text().strip() or self.wizard.api_base
        self.wizard.api_key = self.key_edit.text().strip()
        if self.skip:
            return True
        return self.verify()

class ProgressPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.text = QtWidgets.QTextEdit()
        self.text.setReadOnly(True)
        layout.addWidget(self.text)
        self.setLayout(layout)
        self.thread = None

    def initializePage(self):
        self.text.clear()
        self.thread = InstallThread(
            self.wizard.install_dir,
            self.wizard.version,
            os.path.dirname(os.path.abspath(__file__)),
            self.wizard.language,
            self.wizard.api_key,
            self.wizard.model,
            self.wizard.api_base,
        )
        self.thread.progress.connect(self.append_text)
        self.thread.start()

    def append_text(self, msg):
        self.text.append(msg)
        if msg == "DONE":
            self.wizard.next()

class FinishPage(QtWidgets.QWizardPage):
    def initializePage(self):
        self.setTitle(self.wizard.strings["installation_complete"])

# ========= Wizard =========
class InstallerWizard(QtWidgets.QWizard):
    def __init__(self):
        super().__init__()
        self.language = 'en'
        self.strings = LANGUAGE_STRINGS[self.language]
        self.install_dir = ''
        self.version = ''
        self.api_key = ''
        self.model = 'gpt-4o'
        self.api_base = 'https://api.openai.com/v1/chat/completions'
        self.setWindowTitle("PotPlayer ChatGPT Translate Installer")
        self.setWizardStyle(QtWidgets.QWizard.WizardStyle.ModernStyle)
        self.addPage(LanguagePage(self))
        self.addPage(WelcomePage(self))
        self.addPage(LicensePage(self))
        self.addPage(DirectoryPage(self))
        self.addPage(VersionPage(self))
        self.addPage(ConfigPage(self))
        self.addPage(ProgressPage(self))
        self.addPage(FinishPage(self))

# ========= main =========

def main():
    app = QtWidgets.QApplication(sys.argv)
    if not is_admin():
        QtWidgets.QMessageBox.warning(None, "Admin Required", merge_bilingual("admin_required"))
        restart_as_admin()
        return
    wizard = InstallerWizard()
    wizard.show()
    sys.exit(app.exec())

if __name__ == '__main__':
    main()
