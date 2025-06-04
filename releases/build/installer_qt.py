import os
import sys
import ctypes
import threading
import shutil
import win32com.client
import webbrowser
import winreg
import hashlib
import urllib.request
import json
from PyQt6 import QtWidgets, QtCore

PLUGIN_VERSION = "1.5.2"

LANGUAGE_STRINGS = {
    "en": {
        "select_directory": "Please select the PotPlayer Translate directory.",
        "installation_complete": "Installation completed successfully!",
        "choose_version": "Choose the version to install:",
        "without_context": "Installer without Context Handling",
        "with_context": "Installer with Context Handling",
        "installation_failed": "Installation failed: {}",
        "select_install_dir": "Select the PotPlayer Translate directory:",
        "browse": "Browse",
        "next": "Next",
        "back": "Back",
        "install_progress": "Installation Progress:",
        "cancel": "Cancel",
        "finish": "Finish",
        "skip": "Skip",
    },
    "zh": {
        "select_directory": "请选择PotPlayer的Translate目录。",
        "installation_complete": "安装成功！",
        "choose_version": "请选择安装的版本：",
        "without_context": "不带上下文处理的安装包",
        "with_context": "带上下文处理的安装包",
        "installation_failed": "安装失败：{}",
        "select_install_dir": "请选择PotPlayer的Translate目录：",
        "browse": "浏览",
        "next": "下一步",
        "back": "上一步",
        "install_progress": "安装进度：",
        "cancel": "取消",
        "finish": "完成",
        "skip": "跳过",
    }
}

COMMON_MODELS = {
    "openai": {
        "name_en": "OpenAI GPT-4.1-nano",
        "name_zh": "OpenAI GPT-4.1-nano",
        "model": "gpt-4.1-nano",
        "base": "https://api.openai.com/v1/chat/completions",
        "recharge": "https://platform.openai.com/account/billing",
    },
    "deepseek": {
        "name_en": "Deepseek",
        "name_zh": "深度寻",
        "model": "deepseek-chat",
        "base": "https://api.deepseek.com/v1/chat/completions",
        "recharge": "https://deepseek.com/pricing",
    },
    "tongyi": {
        "name_en": "Tongyi Qianwen",
        "name_zh": "通义千问",
        "model": "qwen-plus",
        "base": "https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions",
        "recharge": "https://dashscope.console.aliyun.com/",
    },
    "siliconflow": {
        "name_en": "SiliconFlow",
        "name_zh": "硅流",
        "model": "siliconflow-chat",
        "base": "https://api.siliconflow.cn/v1/chat/completions",
        "recharge": "https://siliconflow.cn/#/dashboard",
    },
    "ernie": {
        "name_en": "ERNIE Bot",
        "name_zh": "文心一言",
        "model": "ernie-4.0-turbo-8k",
        "base": "https://qianfan.baidubce.com/v2/chat/completions",
        "recharge": "https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application",
    },
    "gemini": {
        "name_en": "Gemini",
        "name_zh": "双子座",
        "model": "gemini-2.0-flash",
        "base": "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
        "recharge": "https://ai.google.dev/",
    },
    "chatglm": {
        "name_en": "ChatGLM",
        "name_zh": "ChatGLM",
        "model": "chatglm-6b",
        "base": "https://api.chatglm.cn/v1/chat/completions",
        "recharge": "https://open.bigmodel.cn/",
    },
    "llama": {
        "name_en": "LLaMA",
        "name_zh": "LLaMA",
        "model": "llama-13b",
        "base": "https://api.llama.ai/v1/chat/completions",
        "recharge": "https://llama.ai/",
    },
    "codellama": {
        "name_en": "Code LLaMA",
        "name_zh": "代码LLaMA",
        "model": "code-llama-34b",
        "base": "https://api.llama.ai/v1/code/completions",
        "recharge": "https://llama.ai/",
    },
    "local": {
        "name_en": "Local Deployment",
        "name_zh": "本地部署",
        "model": "model-name",
        "base": "http://127.0.0.1:11434/v1/chat/completions",
        "recharge": "",
    },
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

# Utilities

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False

def restart_as_admin():
    QtWidgets.QMessageBox.warning(None, "Admin", "{}".format(LANGUAGE_STRINGS["en"]["select_directory"]))
    params = " ".join([f'"{arg}"' for arg in sys.argv])
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, params, None, 1)
    sys.exit()

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

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

def reg_key_name(install_dir, context_type):
    id_base = os.path.abspath(install_dir).lower() + "|" + context_type
    id_hash = hashlib.md5(id_base.encode("utf-8")).hexdigest()[:8]
    return f"PotPlayer_ChatGPT_Translate_{id_hash}"

class InstallThread(threading.Thread):
    def __init__(self, parent, install_dir, version, script_dir, api_key, model, api_base):
        super().__init__()
        self.parent = parent
        self.install_dir = install_dir
        self.version = version
        self.script_dir = script_dir
        self.api_key = api_key
        self.model = model
        self.api_base = api_base

    def run(self):
        try:
            ensure_dir(self.install_dir)
            for src_file, dest_name in OFFLINE_FILES.get(self.version, []):
                src = os.path.join(self.script_dir, src_file)
                dest = os.path.join(self.install_dir, dest_name)
                shutil.copy(src, dest)
                apply_preconfig(dest, self.api_key, self.model, self.api_base)
            pass
        except Exception as e:
            QtWidgets.QMessageBox.critical(None, "Error", LANGUAGE_STRINGS[self.parent.lang]["installation_failed"].format(str(e)))

class InstallerWizard(QtWidgets.QWizard):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("PotPlayer ChatGPT Translate Installer")
        self.resize(500, 400)
        self.lang = "en"
        self.strings = LANGUAGE_STRINGS[self.lang]
        self.install_dir = ""
        self.version = "with_context"
        self.api_key = ""
        self.model_key = "openai"
        self.api_base = COMMON_MODELS[self.model_key]["base"]
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.addPage(LanguagePage(self))
        self.addPage(DirectoryPage(self))
        self.addPage(VersionPage(self))
        self.addPage(ConfigPage(self))
        self.addPage(ProgressPage(self))
        self.addPage(FinishPage(self))

class LanguagePage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        self.setTitle("Language")
        layout = QtWidgets.QVBoxLayout()
        self.combo = QtWidgets.QComboBox()
        self.combo.addItem("English", "en")
        self.combo.addItem("中文", "zh")
        layout.addWidget(self.combo)
        self.setLayout(layout)

    def validatePage(self):
        self.wizard.lang = self.combo.currentData()
        self.wizard.strings = LANGUAGE_STRINGS[self.wizard.lang]
        return True

class DirectoryPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        self.setTitle(wizard.strings["select_install_dir"])
        layout = QtWidgets.QVBoxLayout()
        self.pathEdit = QtWidgets.QLineEdit()
        self.browseBtn = QtWidgets.QPushButton(wizard.strings["browse"])
        self.browseBtn.clicked.connect(self.browse)
        layout.addWidget(self.pathEdit)
        layout.addWidget(self.browseBtn)
        self.setLayout(layout)

    def initializePage(self):
        self.setTitle(self.wizard.strings["select_install_dir"])
        self.browseBtn.setText(self.wizard.strings["browse"])

    def browse(self):
        d = QtWidgets.QFileDialog.getExistingDirectory(self, self.wizard.strings["select_directory"])
        if d:
            self.pathEdit.setText(d)

    def validatePage(self):
        self.wizard.install_dir = self.pathEdit.text().strip()
        return bool(self.wizard.install_dir)

class VersionPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.radio1 = QtWidgets.QRadioButton()
        self.radio2 = QtWidgets.QRadioButton()
        self.desc1 = QtWidgets.QLabel()
        self.desc2 = QtWidgets.QLabel()
        layout.addWidget(self.radio1)
        layout.addWidget(self.desc1)
        layout.addWidget(self.radio2)
        layout.addWidget(self.desc2)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle(s["choose_version"])
        self.radio1.setText(s["with_context"])
        self.radio2.setText(s["without_context"])
        self.desc1.setText(s["with_context_description"] if "with_context_description" in s else "")
        self.desc2.setText(s["without_context_description"] if "without_context_description" in s else "")
        self.radio1.setChecked(True)

    def validatePage(self):
        self.wizard.version = "with_context" if self.radio1.isChecked() else "without_context"
        return True

class ConfigPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.combo = QtWidgets.QComboBox()
        self.combo.currentIndexChanged.connect(self.model_changed)
        layout.addWidget(self.combo)
        self.apiEdit = QtWidgets.QLineEdit()
        layout.addWidget(self.apiEdit)
        self.fetchBtn = QtWidgets.QPushButton("Fetch Models")
        self.fetchBtn.clicked.connect(self.fetch_models)
        layout.addWidget(self.fetchBtn)
        self.keyEdit = QtWidgets.QLineEdit()
        self.keyEdit.setEchoMode(QtWidgets.QLineEdit.EchoMode.Password)
        layout.addWidget(self.keyEdit)
        self.rechargeBtn = QtWidgets.QPushButton("Recharge")
        self.rechargeBtn.clicked.connect(self.open_recharge)
        layout.addWidget(self.rechargeBtn)
        self.skipBtn = QtWidgets.QPushButton()
        self.skipBtn.clicked.connect(self.skip)
        layout.addWidget(self.skipBtn)
        self.setLayout(layout)

    def initializePage(self):
        s = self.wizard.strings
        self.setTitle("API Config")
        self.skipBtn.setText(s["skip"])
        self.combo.clear()
        for key, info in COMMON_MODELS.items():
            name = info.get(f"name_{self.wizard.lang}", info["name_en"])
            self.combo.addItem(name, key)
        self.combo.setCurrentIndex(0)
        self.apiEdit.setText(COMMON_MODELS[self.combo.currentData()]["base"])
        self.keyEdit.setText("")
        # auto skip if file exists
        script_name = OFFLINE_FILES[self.wizard.version][0][1]
        dest = os.path.join(self.wizard.install_dir, script_name)
        if os.path.exists(dest):
            QtWidgets.QMessageBox.information(self, "Info", "Existing installation detected. Skipping configuration.")
            QtCore.QTimer.singleShot(100, self.wizard.next)

    def skip(self):
        self.wizard.next()

    def model_changed(self, idx):
        key = self.combo.currentData()
        info = COMMON_MODELS[key]
        self.apiEdit.setText(info["base"])
        self.wizard.model_key = key

    def fetch_models(self):
        base = self.apiEdit.text().strip()
        if not base:
            return
        url = base
        if "chat/completions" in base:
            url = base.rsplit("chat/completions", 1)[0] + "models"
        elif not base.endswith("/models"):
            url = base.rstrip("/") + "/models"
        try:
            req = urllib.request.Request(url)
            key = self.keyEdit.text().strip()
            if key:
                req.add_header("Authorization", f"Bearer {key}")
            with urllib.request.urlopen(req) as r:
                data = json.load(r)
            models = [d["id"] for d in data.get("data", []) if "id" in d]
            if models:
                self.combo.clear()
                for m in models:
                    self.combo.addItem(m, m)
        except Exception as e:
            QtWidgets.QMessageBox.critical(self, "Error", str(e))

    def open_recharge(self):
        key = self.combo.currentData()
        info = COMMON_MODELS.get(key)
        if info and info["recharge"]:
            webbrowser.open(info["recharge"])

    def validatePage(self):
        self.wizard.api_key = self.keyEdit.text().strip()
        key = self.combo.currentData()
        if key in COMMON_MODELS:
            self.wizard.model_key = key
            self.wizard.api_base = self.apiEdit.text().strip()
        else:
            self.wizard.model_key = key
            self.wizard.api_base = self.apiEdit.text().strip()
        return True

class ProgressPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.text = QtWidgets.QTextEdit()
        self.text.setReadOnly(True)
        layout.addWidget(self.text)
        self.setLayout(layout)

    def initializePage(self):
        self.setTitle(self.wizard.strings["install_progress"])
        self.text.clear()
        self.text.append("Starting installation...")
        thread = InstallThread(
            self,
            self.wizard.install_dir,
            self.wizard.version,
            self.wizard.script_dir,
            self.wizard.api_key,
            COMMON_MODELS[self.wizard.model_key]["model"],
            self.wizard.api_base,
        )
        thread.start()
        thread.join()
        self.text.append(self.wizard.strings["installation_complete"])

class FinishPage(QtWidgets.QWizardPage):
    def __init__(self, wizard):
        super().__init__()
        self.wizard = wizard
        layout = QtWidgets.QVBoxLayout()
        self.lbl = QtWidgets.QLabel()
        layout.addWidget(self.lbl)
        self.setLayout(layout)

    def initializePage(self):
        self.lbl.setText(self.wizard.strings["finish"])

class UserEvent(QtCore.QEvent):
    def __init__(self):
        super().__init__(QtCore.QEvent.Type.User)


def main():
    if not is_admin():
        restart_as_admin()
    app = QtWidgets.QApplication(sys.argv)
    wiz = InstallerWizard()
    wiz.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
