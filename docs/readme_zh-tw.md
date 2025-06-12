<a id="readme-top"></a>

[![Forks][forks-shield]]([forks-url])
[![Stargazers][stars-shield]]([stars-url])
[![Issues][issues-shield]]([issues-url])
[![License][license-shield]]([license-url])

<div align="right">
  <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/docs/readme_zh.md">简体中文</a> | 
  <strong href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/docs/readme_zh-tw.md">繁体中文</strong> | 
  <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/README.md">English</a>
</div>

<div align="center">
  <h3 align="center">PotPlayer_ChatGPT_Translate 🚀</h3>
  <p align="center">
    一款利用 ChatGPT API 提供即時、語境感知字幕翻譯的 PotPlayer 插件。✨
  </p>
    <p align="center">
    <img src="https://blog.codinghorror.com/content/images/uploads/2007/03/6a0120a85dcdae970b0128776ff992970c-pi.png" alt="It works on my machine">
  </p>
  <p align="center"><em>Works on my machine.</em></p>
  <p align="center">
    <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues/new?labels=bug&template=bug-report---.md">🐞 回報 Bug</a>
    &nbsp;&middot;&nbsp;
    <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues/new?labels=enhancement&template=feature-request---.md">💡 功能需求</a>
  </p>
</div>

<!-- HTML 目錄 (Table of Contents) -->

<div>
  <h2>📑 目錄</h2>
  <ol>
    <li><a href="#關於本專案-">關於本專案</a></li>
    <li><a href="#影片教學-">影片教學</a></li>
    <li><a href="#技術棧-">技術棧</a></li>
    <li>
      <a href="#安裝-">安裝</a>
      <ol>
        <li><a href="#全自動安裝推薦-">全自動安裝（推薦）</a></li>
        <li><a href="#手動安裝-">手動安裝</a></li>
      </ol>
    </li>
    <li><a href="#配置-">配置</a></li>
    <li><a href="#使用方法-">使用方法</a></li>
    <li><a href="#開發規劃-">開發規劃</a></li>
    <li><a href="#貢獻指南-">貢獻指南</a></li>
    <li><a href="#授權條款-">授權條款</a></li>
    <li><a href="#聯絡方式-">聯絡方式</a></li>
    <li><a href="#致謝-">致謝</a></li>
  </ol>
</div>

---

## 關於本專案 💬

**PotPlayer\_ChatGPT\_Translate** 是一個 PotPlayer 插件，整合 ChatGPT API，實現即時、語境感知的字幕翻譯。不同於傳統翻譯工具，本插件可考慮上下文、慣用語與文化差異，提供更精確的翻譯。核心部分以 AngleScript 實現，結合 ChatGPT API 及 PotPlayer API，實現深度整合。

### 本插件亦相容任何採用與 ChatGPT 相同 API 調用方式的 AI 模型。

## 🔍 Google 翻譯 vs ChatGPT 翻譯

使用 ChatGPT 進行字幕翻譯的一大優勢在於它能理解上下文和文化參考。請參見下方對比：

* **原始字幕：**

  > *"You're gonna old yeller my f\*\*king universe."*

* **Google 翻譯結果：**

  > *"你要老了我他媽的宇宙嗎？"*
  > ![](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/docs/Google%20translate.png)
  > *(意義不明且不正確)*

* **ChatGPT 翻譯結果：**

  > *"你要像《老黃狗》一樣對待我的宇宙？"*
  > ![](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/docs/ChatGPT.png)
  > *(準確捕捉引用及其意圖)*

## 🧐 ChatGPT 無上下文 vs ChatGPT 有上下文

* **原始字幕：**

  > *"But being one in real life is even better."*

* **ChatGPT 翻譯（無上下文）：**

  > *"但是，在現實生活中成為一個人甚至更好。"*
  > ![](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/docs/without%20context.png)
  > *(字面翻譯，未能體現隱含意義)*

* **ChatGPT 翻譯（有上下文）：**

  > *"但在現實生活中成為反派更好。"*
  > ![](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/docs/using%20context.png)
  > *(準確捕捉語境)*

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 影片教學 🎥

點擊下方連結，在 Bilibili 上觀看教學影片：

<a href="https://www.bilibili.com/video/BV1w9FzegEbM" title="在 Bilibili 上觀看">
  <img src="https://i1.hdslb.com/bfs/archive/88992bd0e80ff751771e78675a558b663a728028.jpg" alt="在 Bilibili 上觀看">
</a>

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 技術棧 🛠

* **AngleScript** – 插件開發腳本語言
* **ChatGPT API** – 提供語境感知翻譯功能
* **PotPlayer API** – 與 PotPlayer 無縫整合

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 安裝 📦

### 全自動安裝（推薦） ⚡

1. **下載安裝程式：**
   [安裝程式](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/releases/latest)
   *(安裝程式為開源，可檢視其原始碼)*
2. **執行安裝程式：**

   * 雙擊 installer.exe 開始安裝。
   * 安裝程式會自動偵測你的 PotPlayer 路徑並完成設定。
   * 進階使用者可啟用靜默模式：
     ```bash
     installer.exe --dir "C:\\Program Files\\DAUM\\PotPlayer\\Extension\\Subtitle\\Translate" \
       --version with_context --lang zh --silent
     ```
     如此可在無需互動的情況下完成安裝。

### 手動安裝 🔧

1. **下載 ZIP 檔案：**
   從本倉庫下載最新版 ZIP 檔。
2. **解壓 ZIP 檔：**
   將內容解壓到臨時資料夾。
3. **複製檔案：**
   將 `ChatGPTSubtitleTranslate.as` 和 `ChatGPTSubtitleTranslate.ico` 複製到以下目錄：

   ```
   C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate
   ```

   若你的 PotPlayer 安裝於其他路徑，請將 `C:\Program Files\DAUM\PotPlayer` 替換成對應路徑。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 配置 ⚙️

1. **開啟 PotPlayer 設定：**
   按下 **F5** 開啟 PotPlayer **偏好設定**。

2. **前往擴充設定：**
   依序選擇 **擴充 > 字幕翻譯**。

3. **選擇翻譯插件：**
   選擇 **ChatGPT 翻譯** 作為翻譯插件。

4. **配置插件：**

   * **Model Name（模型名稱）：**
     你可僅輸入模型名稱，系統會使用預設 API 介面 URL。
     **範例：**

     ```
     gpt-4.1-nano
     ```

     或者，也可指定自訂 API 介面 URL，格式如下：

     ```
     模型名稱|API 提供商
     ```

     **範例：**

     ```
     gpt-4.1-nano|https://api.openai.com/v1/chat/completions
     ```

     > **備註：**
     > 在新版插件（v1.5）中，如需支援第三方 API 且不使用 API Key，可於第二個參數填入 `nullkey`。例如：
     >
     > ```
     > gpt-4.1-nano|nullkey
     > ```
     >
     > 或者：
     >
     > ```
     > qwen2.5:7b|http://127.0.0.1:11434/v1/chat/completions|nullkey
     > ```

   * **API Key：**
     輸入你的 API Key。

     > 你可利用 **[keytest.obanarchy.org](https://keytest.obanarchy.org/)** 測試 API Key 是否有效。

5. **設定原語言與目標語言：**
   根據需求設置字幕來源與目標語言。

---

### 模型填寫範例列表

格式如下：

```
模型名稱|API 位址|nullkey（可選）
```

以下為已支援或可用的模型介面範例：

```
Deepseek: deepseek-chat|https://api.deepseek.com/v1/chat/completions
通義千問: qwen-plus|https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions
矽基流動: siliconflow-chat|https://api.siliconflow.cn/v1/chat/completions
文心一言: ernie-4.0-turbo-8k|https://qianfan.baidubce.com/v2/chat/completions
Gemini: gemini-2.0-flash|https://generativelanguage.googleapis.com/v1beta/openai/chat/completions
ChatGLM: chatglm-6b|https://api.chatglm.cn/v1/chat/completions
LLaMA: llama-13b|https://api.llama.ai/v1/chat/completions
Code LLaMA: code-llama-34b|https://api.llama.ai/v1/code/completions
OpenAI GPT-4o: gpt-4o|https://api.openai.com/v1/chat/completions
OpenAI GPT-4 Turbo: gpt-4-turbo|https://api.openai.com/v1/chat/completions
OpenAI GPT-3.5 Turbo: gpt-3.5-turbo|https://api.openai.com/v1/chat/completions
Claude 3 Sonnet: claude-3-sonnet-20240229|https://api.anthropic.com/v1/messages
Mistral Large: mistral-large|https://api.mistral.ai/v1/chat/completions
Groq Llama 3: llama3-70b-8192|https://api.groq.com/openai/v1/chat/completions
Perplexity Sonar Large: pplx-70b-online|https://api.perplexity.ai/chat/completions
Fireworks Mixtral: accounts/fireworks/models/mixtral-8x7b-instruct|https://api.fireworks.ai/inference/v1/chat/completions
Moonshot v1: moonshot-v1-128k|https://api.moonshot.cn/v1/chat/completions
Yi 34B Chat: yi-34b-chat|https://api.lingyi.ai/v1/chat/completions
本地部署（無需 API Key）：模型名稱|http://127.0.0.1:端口/v1/chat/completions|nullkey
```

你亦可根據需求擴充其他支援 OpenAI 介面的模型，僅需確保其支援 `chat/completions` 介面。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 使用方法 ▶️

在 PotPlayer 播放帶有字幕的影片時，本插件會自動調用 ChatGPT API，進行即時字幕翻譯。透過處理語境、慣用語與文化差異，插件能提供更精確的翻譯結果。

例如：

* **輸入：** *"You're gonna old yeller my f\*\*king universe."*

  * **傳統翻譯工具** 可能會直譯或生硬翻譯。
  * **ChatGPT 翻譯** 則能捕捉電影引用與語境，給出貼切翻譯。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 開發規劃 🗺

* [x] 集成 PotPlayer API 與 ChatGPT API，實現即時字幕翻譯。
* [ ] 支援更多 AI 模型（規劃中，近期內不實現）。
* [ ] 優化語境處理，進一步提升翻譯精度。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 貢獻指南 🤝

歡迎任何貢獻！提交 Pull Request 時，請詳細描述你的修改內容。
若有改進建議或 Bug 修復，建議先於 Issue 討論。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 授權條款 📄

本專案採 GPLv3 授權條款。詳情請參閱 `LICENSE` 檔案。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 聯絡方式 📞

個人網站：[obanarchy.org](https://obanarchy.org)

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## 致謝 🙏

* 感謝 OpenAI 提供強大的 ChatGPT API。
* 感謝 PotPlayer 團隊打造出色的多媒體播放器。
* 感謝所有為本專案建議或貢獻程式碼的朋友（貢獻者名單將於此更新）。

<p align="right">(<a href="#readme-top">回到頂部</a>)</p>

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Felix3322/PotPlayer_ChatGPT_Translate\&type=Date)](https://www.star-history.com/#Felix3322/PotPlayer_ChatGPT_Translate&Date)

<!-- MARKDOWN LINKS & IMAGES -->

[stars-shield]: https://img.shields.io/github/stars/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[stars-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/stargazers
[forks-shield]: https://img.shields.io/github/forks/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[forks-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/network/members
[issues-shield]: https://img.shields.io/github/issues/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[issues-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues
[license-shield]: https://img.shields.io/github/license/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[license-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/LICENSE

---

如有特定地區用語需求、繁體中文標點或風格微調，請補充說明。我可以直接生成 `.md` 檔案或者 diff，按你的 workflow 來。
