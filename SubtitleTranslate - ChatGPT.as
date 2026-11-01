/*
    Real-time subtitle translation for PotPlayer using OpenAI ChatGPT API
*/

// Plugin Information Functions
string GetTitle() {
    return "{$CP949=ChatGPT 번역$}"
         + "{$CP950=ChatGPT 翻譯$}"
         + "{$CP936=ChatGPT 翻译$}"
         + "{$CP0=ChatGPT Translate$}";
}

// The version number will be replaced during the installation process
string GetVersion() {
    return "1.9.4";
}

string GetDesc() {
    return "Real-time subtitle translation using OpenAI ChatGPT.";
}

string GetLoginTitle() {
    return "{$CP949=OpenAI 모델 및 API 키 구성$}"
         + "{$CP950=OpenAI 模型與 API 金鑰配置$}"
         + "{$CP936=OpenAI 模型与 API 密钥配置$}"
         + "{$CP0=OpenAI Model + API URL and API Key Configuration$}";
}

string GetLoginDesc() {
    return "{$CP949=모델 이름, API 주소, 선택적 nullkey, 지연(ms) 및 재시도 모드(0-3)를 입력하십시오 (예: gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1).$}"
         + "{$CP949=\n\n설치 프로그램에서 미리 구성한 값이 있다면 PotPlayer 패널에서 다시 설정하기 전까지 해당 값을 사용하며, 패널에서 설정하면 해당 설정이 항상 우선 적용됩니다.$}"
         + "{$CP949=\n\n선택적으로 cache=auto 또는 cache=off 를 추가하여 문맥 캐시 모드를 제어할 수 있으며, auto 는 지원되지 않을 경우 chat 방식으로 자동 전환됩니다.$}"
         + "{$CP950=請輸入模型名稱、API 地址、可選的 nullkey、延遲毫秒與重試模式(0-3)（例如: gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1）。$}"
         + "{$CP950=\n\n如果安裝包已寫入預設配置，在 PotPlayer 面板中未重新設定之前會沿用這些配置；一旦在面板中調整，將始終以面板設定為準。$}"
         + "{$CP950=\n\n可選加上 cache=auto 或 cache=off 以控制上下文快取模式，auto 會在不支援時自動回退至 chat。$}"
         + "{$CP936=请输入模型名称、API 地址、可选的 nullkey、延迟毫秒和重试模式(0-3)（例如: gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1）。$}"
         + "{$CP936=\n\n如果安装包已经写入默认配置，在 PotPlayer 面板中没有重新设置之前会继续使用这些配置；一旦在面板中修改，将始终以面板设置为准。$}"
         + "{$CP936=\n\n可选追加 cache=auto 或 cache=off 用于控制上下文缓存模式，auto 在不支持时会自动回退到 chat。$}"
         + "{$CP950=\n\n支援的服務商可追加 thinking=disabled 關閉思考，thinking=enabled 開啟，thinking=auto 使用預設值。$}"
         + "{$CP949=\n\n지원하는 API에서 thinking=disabled 로 사고 모드를 끄고, thinking=enabled 로 켜고, thinking=auto 로 기본값을 사용할 수 있습니다.$}"
         + "{$CP936=\n\n支持的服务商可追加 thinking=disabled 关闭思考，thinking=enabled 开启，thinking=auto 使用服务商默认值。$}"
         + "{$CP0=Please enter the model name, API URL, optional 'nullkey', optional delay in ms, and retry mode 0-3 (e.g., gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1).$}"
         + "{$CP0=\n\nInstaller defaults will remain in effect until you update the settings in PotPlayer's panel, and any panel changes will always take priority.$}"
         + "{$CP0=\n\nOptionally append cache=auto or cache=off to control context caching. Auto falls back to chat when caching is unsupported.$}"
         + "{$CP0=\n\nFor OpenAI official API you can also append retention=24h (or cache24h) to extend prompt cache retention. For Gemini official API you can append gcache=cachedContents/... to reuse an explicit cache.$}"
         + "{$CP0=\n\nFor compatible providers, append thinking=disabled, thinking=enabled, or thinking=auto (provider default).$}";
}

string GetUserText() {
    return "{$CP949=모델 이름|API 주소|nullkey|지연(ms)|재시도 모드|문맥 자막 수|캐시 모드 (현재: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + " | " + GPT_context_subtitle_count + " | " + GPT_context_cache_mode + ")$}"
         + "{$CP950=模型名稱|API 地址|nullkey|延遲ms|重試模式|上下文字幕條數|快取模式 (目前: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + " | " + GPT_context_subtitle_count + " | " + GPT_context_cache_mode + ")$}"
         + "{$CP936=模型名称|API 地址|nullkey|延迟ms|重试模式|上下文字幕条数|缓存模式 (目前: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + " | " + GPT_context_subtitle_count + " | " + GPT_context_cache_mode + ")$}"
         + "{$CP0=Model Name|API URL|nullkey|Delay ms|Retry mode|Context subtitle count|Cache mode|Retention|Gemini cached_content (Current: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + " | " + GPT_context_subtitle_count + " | " + GPT_context_cache_mode + " | " + GPT_prompt_cache_retention + " | " + GPT_gemini_cached_content + ")$}";
}

string GetPasswordText() {
    return "{$CP949=API 키:$}"
         + "{$CP950=API 金鑰:$}"
         + "{$CP936=API 密钥:$}"
         + "{$CP0=API Key:$}";
}

// Global Variables
// Shared, optional UTF-8 rules file next to the translator scripts.
array<string> GPT_remove_substrings = {};
array<string> GPT_remove_exact_subtitles = {};
array<string> GPT_remove_whole_words = {};

void LoadSubtitleFilters() {
    GPT_remove_substrings.resize(0);
    GPT_remove_exact_subtitles.resize(0);
    GPT_remove_whole_words.resize(0);
    string path = HostGetScriptFolder() + "\\ChatGPT-subtitle-filter.txt";
    uintptr file = HostFileOpen(path);
    if (file == 0) return;
    int64 length = HostFileLength(file);
    if (length < 0 || length > 262144) {
        HostFileClose(file);
        HostPrintUTF8("Subtitle filter file exceeds 256 KiB or cannot be read.\n");
        return;
    }
    string data = HostFileRead(file, int(length));
    HostFileClose(file);
    if (data.substr(0, 3) == "\xEF\xBB\xBF") data = data.substr(3);
    int start = 0;
    while (start < int(data.length())) {
        int end = data.find("\n", start);
        if (end < 0) end = int(data.length());
        string line = data.substr(start, end - start);
        if (line.length() > 0 && line.substr(line.length() - 1, 1) == "\r")
            line = line.substr(0, line.length() - 1);
        if (line.substr(0, 9) == "contains=" && line.length() > 9)
            GPT_remove_substrings.insertLast(line.substr(9));
        else if (line.substr(0, 6) == "exact=" && line.length() > 6)
            GPT_remove_exact_subtitles.insertLast(line.substr(6));
        else if (line.substr(0, 5) == "word=" && line.length() > 5)
            GPT_remove_whole_words.insertLast(line.substr(5));
        start = end + 1;
    }
}

bool IsWordBoundary(const string &in ch) {
    return ch == "" || " \t\r\n.,!?;:()[]{}<>/\\\"'`~@#$%^&*+=|-".find(ch) >= 0;
}

string FilterSubtitle(string text) {
    for (uint i = 0; i < GPT_remove_exact_subtitles.length(); i++) {
        string rule = GPT_remove_exact_subtitles[i];
        if (rule != "" && text.Trim() == rule) return "";
    }
    bool changed = false;
    for (uint i = 0; i < GPT_remove_whole_words.length(); i++) {
        string rule = GPT_remove_whole_words[i];
        if (rule == "") continue;
        int start = 0;
        while (start < int(text.length())) {
            int pos = text.find(rule, start);
            if (pos < 0) break;
            int after = pos + int(rule.length());
            string beforeChar = pos == 0 ? "" : text.substr(pos - 1, 1);
            string afterChar = after >= int(text.length()) ? "" : text.substr(after, 1);
            if (IsWordBoundary(beforeChar) && IsWordBoundary(afterChar)) {
                text = text.substr(0, pos) + text.substr(after);
                changed = true;
                start = pos;
            } else start = pos + 1;
        }
    }
    for (uint i = 0; i < GPT_remove_substrings.length(); i++) {
        string rule = GPT_remove_substrings[i];
        if (rule != "" && text.find(rule) != -1) {
            text.replace(rule, "");
            changed = true;
        }
    }
    return changed ? text.Trim() : text;
}

// Pre-configured values (auto-filled by installer)
string GPT_pre_api_key = ""; // will be replaced during installation
string GPT_pre_selected_model = "gpt-5-nano"; // will be replaced during installation
string GPT_pre_apiUrl = "https://api.openai.com/v1/chat/completions"; // will be replaced during installation
string GPT_pre_delay_ms = "0"; // will be replaced during installation
string GPT_pre_retry_mode = "0"; // will be replaced during installation
string GPT_pre_context_subtitle_count = "3"; // number of previous subtitle entries used as context
string GPT_pre_context_cache_mode = "off"; // auto | off
string GPT_pre_prompt_cache_retention = ""; // ""(default), in-memory, 24h (OpenAI official only)
string GPT_pre_gemini_cached_content = ""; // optional cachedContents/... name for Gemini OpenAI-compatible endpoint
string GPT_pre_thinking_mode = "auto"; // auto (provider default) | enabled | disabled
string GPT_pre_small_model = "0"; // 0 | 1
string GPT_pre_check_hallucination = "0"; // 0 | 1
string GPT_pre_model_token_limits_json = "{}"; // serialized token limit rules (injected by installer)

// Context-specific identifiers to prevent collisions with other subtitle translator scripts.
const string GPT_CTX_TRANSLATION_FAILURE_WARNING_PREFIX = "[Translation failed - please share a screenshot with the developer] ";

string GPT_api_key = GPT_pre_api_key;
string GPT_selected_model = GPT_pre_selected_model; // Default model
string GPT_apiUrl = GPT_pre_apiUrl; // Default API URL
string GPT_delay_ms = GPT_pre_delay_ms; // Request delay in ms
string GPT_retry_mode = GPT_pre_retry_mode; // Auto retry mode
string GPT_context_subtitle_count = GPT_pre_context_subtitle_count; // Previous subtitle entries used as context
string GPT_context_cache_mode = GPT_pre_context_cache_mode; // auto | off
string GPT_prompt_cache_retention = GPT_pre_prompt_cache_retention; // "" | in-memory | 24h
string GPT_gemini_cached_content = GPT_pre_gemini_cached_content; // cachedContents/... (optional)
string GPT_thinking_mode = GPT_pre_thinking_mode;
string GPT_small_model = GPT_pre_small_model;
string GPT_check_hallucination = GPT_pre_check_hallucination;
string GPT_UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
array<string> GPT_subtitleHistory;  // Global subtitle history
bool GPT_context_cache_disabled_for_session = false;
string GPT_context_cache_disable_key = "";
bool GPT_token_rules_initialized = false;
int GPT_default_model_token_limit = 4096;
array<string> GPT_token_rule_types;
array<string> GPT_token_rule_values;
array<int> GPT_token_rule_limits;

// Helper functions to load configuration while respecting installer defaults
string BuildConfigSentinel(const string &in key) {
    return "#__POTPLAYER_CFG_UNSET__#" + key + "#__";
}

string LoadInstallerConfig(const string &in key, const string &in installerValue, const string &in fallbackKey = "") {
    string sentinel = BuildConfigSentinel(key);
    string storedValue = HostLoadString(key, sentinel);
    if (storedValue == sentinel && fallbackKey != "") {
        string fallbackSentinel = BuildConfigSentinel(fallbackKey);
        string fallbackValue = HostLoadString(fallbackKey, fallbackSentinel);
        if (fallbackValue != fallbackSentinel && fallbackValue != "")
            return fallbackValue;
    }
    if (storedValue == sentinel || (storedValue == "" && installerValue != ""))
        return installerValue;
    return storedValue;
}

void EnsureConfigDefault(const string &in key, const string &in value) {
    string sentinel = BuildConfigSentinel(key);
    string stored = HostLoadString(key, sentinel);
    if (stored == sentinel || (stored == "" && value != ""))
        HostSaveString(key, value);
}

void EnsureInstallerDefaultsPersisted() {
    EnsureConfigDefault("gpt_api_key", GPT_pre_api_key);
    EnsureConfigDefault("gpt_selected_model", GPT_pre_selected_model);
    EnsureConfigDefault("gpt_apiUrl", GPT_pre_apiUrl);
    EnsureConfigDefault("gpt_delay_ms", GPT_pre_delay_ms);
    EnsureConfigDefault("gpt_retry_mode", GPT_pre_retry_mode);
    EnsureConfigDefault("gpt_context_subtitle_count", GPT_pre_context_subtitle_count);
    EnsureConfigDefault("gpt_context_cache_mode", GPT_pre_context_cache_mode);
    EnsureConfigDefault("gpt_prompt_cache_retention", GPT_pre_prompt_cache_retention);
    EnsureConfigDefault("gpt_gemini_cached_content", GPT_pre_gemini_cached_content);
    EnsureConfigDefault("gpt_thinking_mode", GPT_pre_thinking_mode);
    EnsureConfigDefault("gpt_small_model", GPT_pre_small_model);
    EnsureConfigDefault("gpt_check_hallucination", GPT_pre_check_hallucination);
}

void RefreshConfiguration() {
    EnsureInstallerDefaultsPersisted();
    GPT_api_key = LoadInstallerConfig("gpt_api_key", GPT_pre_api_key, "wc_api_key");
    GPT_selected_model = LoadInstallerConfig("gpt_selected_model", GPT_pre_selected_model, "wc_selected_model");
    GPT_apiUrl = LoadInstallerConfig("gpt_apiUrl", GPT_pre_apiUrl, "wc_apiUrl");
    GPT_delay_ms = LoadInstallerConfig("gpt_delay_ms", GPT_pre_delay_ms, "wc_delay_ms");
    GPT_retry_mode = LoadInstallerConfig("gpt_retry_mode", GPT_pre_retry_mode, "wc_retry_mode");
    GPT_context_subtitle_count = LoadInstallerConfig("gpt_context_subtitle_count", GPT_pre_context_subtitle_count);
    GPT_context_cache_mode = NormalizeCacheMode(LoadInstallerConfig("gpt_context_cache_mode", GPT_pre_context_cache_mode));
    GPT_prompt_cache_retention = NormalizePromptCacheRetention(LoadInstallerConfig("gpt_prompt_cache_retention", GPT_pre_prompt_cache_retention));
    GPT_gemini_cached_content = LoadInstallerConfig("gpt_gemini_cached_content", GPT_pre_gemini_cached_content).Trim();
    GPT_thinking_mode = GPT_CTX_NormalizeThinkingMode(LoadInstallerConfig("gpt_thinking_mode", GPT_pre_thinking_mode));
    GPT_small_model = LoadInstallerConfig("gpt_small_model", GPT_pre_small_model);
    GPT_check_hallucination = LoadInstallerConfig("gpt_check_hallucination", GPT_pre_check_hallucination);
}

// Supported Language List
array<string> LangTable =
{
    "", // Auto Detect
    "af", // Afrikaans
    "sq", // Albanian
    "am", // Amharic
    "ar", // Arabic
    "hy", // Armenian
    "az", // Azerbaijani
    "eu", // Basque
    "be", // Belarusian
    "bn", // Bengali
    "bs", // Bosnian
    "bg", // Bulgarian
    "ca", // Catalan
    "ceb", // Cebuano
    "ny", // Chichewa
    "zh-CN", // Chinese (Simplified)
    "zh-TW", // Chinese (Traditional)
    "co", // Corsican
    "hr", // Croatian
    "cs", // Czech
    "da", // Danish
    "nl", // Dutch
    "en", // English
    "eo", // Esperanto
    "et", // Estonian
    "tl", // Filipino
    "fi", // Finnish
    "fr", // French
    "fy", // Frisian
    "gl", // Galician
    "ka", // Georgian
    "de", // German
    "el", // Greek
    "gu", // Gujarati
    "ht", // Haitian Creole
    "ha", // Hausa
    "haw", // Hawaiian
    "he", // Hebrew
    "hi", // Hindi
    "hmn", // Hmong
    "hu", // Hungarian
    "is", // Icelandic
    "ig", // Igbo
    "id", // Indonesian
    "ga", // Irish
    "it", // Italian
    "ja", // Japanese
    "jw", // Javanese
    "kn", // Kannada
    "kk", // Kazakh
    "km", // Khmer
    "ko", // Korean
    "ku", // Kurdish (Kurmanji)
    "ky", // Kyrgyz
    "lo", // Lao
    "la", // Latin
    "lv", // Latvian
    "lt", // Lithuanian
    "lb", // Luxembourgish
    "mk", // Macedonian
    "ms", // Malay
    "mg", // Malagasy
    "ml", // Malayalam
    "mt", // Maltese
    "mi", // Maori
    "mr", // Marathi
    "mn", // Mongolian
    "my", // Myanmar (Burmese)
    "ne", // Nepali
    "no", // Norwegian
    "ps", // Pashto
    "fa", // Persian
    "pl", // Polish
    "pt", // Portuguese
    "pa", // Punjabi
    "ro", // Romanian
    "ru", // Russian
    "sm", // Samoan
    "gd", // Scots Gaelic
    "sr", // Serbian
    "st", // Sesotho
    "sn", // Shona
    "sd", // Sindhi
    "si", // Sinhala
    "sk", // Slovak
    "sl", // Slovenian
    "so", // Somali
    "es", // Spanish
    "su", // Sundanese
    "sw", // Swahili
    "sv", // Swedish
    "tg", // Tajik
    "ta", // Tamil
    "te", // Telugu
    "th", // Thai
    "tr", // Turkish
    "uk", // Ukrainian
    "ur", // Urdu
    "uz", // Uzbek
    "vi", // Vietnamese
    "cy", // Welsh
    "xh", // Xhosa
    "yi", // Yiddish
    "yo", // Yoruba
    "zu"  // Zulu
};

array<string> GetSrcLangs() {
    array<string> ret = LangTable;
    return ret;
}

array<string> GetDstLangs() {
    array<string> ret = LangTable;
    return ret;
}

bool IsDigits(const string &in s) {
    if (s.length() == 0)
        return false;
    for (uint i = 0; i < s.length(); i++) {
        uint8 c = s[i];
        if (c < 48 || c > 57)
            return false;
    }
    return true;
}

int ParseInt(const string &in s) {
    int v = 0;
    for (uint i = 0; i < s.length(); i++) {
        uint8 c = s[i];
        if (c < 48 || c > 57)
            return 0;
        v = v * 10 + (c - 48);
    }
    return v;
}

bool EqualsIgnoreCase(const string &in a, const string &in b) {
    if (a.length() != b.length())
        return false;
    for (uint i = 0; i < a.length(); i++) {
        uint8 ca = a[i];
        uint8 cb = b[i];
        if (ca >= 65 && ca <= 90)
            ca += 32;
        if (cb >= 65 && cb <= 90)
            cb += 32;
        if (ca != cb)
            return false;
    }
    return true;
}

string BuildAuthHeaders(const string &in key) {
    string trimmedKey = key.Trim();
    string lowerKey = string(trimmedKey).MakeLower();
    string headers = "Content-Type: application/json";
    if (trimmedKey != "" && lowerKey != "nullkey")
        headers = "Authorization: Bearer " + trimmedKey + "\n" + headers;
    return headers;
}

// API Key and API Base verification process
string ServerLogin(string User, string Pass) {
    RefreshConfiguration();
    string errorAccum = "";
    User = User.Trim();
    Pass = Pass.Trim();
    string lowerPass = string(Pass).MakeLower();
    array<string> tokens;
    int start = 0;
    for (int i = 0; i <= int(User.length()); i++) {
        if (i == int(User.length()) || User.substr(i, 1) == "|") {
            string token = User.substr(start, i - start).Trim();
            tokens.insertLast(token);
            start = i + 1;
        }
    }
    string userModel = "";
    string customApiUrl = "";
    bool allowNullApiKey = (Pass == "" || lowerPass == "nullkey");
    string delayToken = "";
    string retryToken = "";
    string contextSubtitleCountToken = "";
    string cacheToken = "";
    string promptCacheRetentionToken = GPT_prompt_cache_retention;
    string geminiCachedContentToken = GPT_gemini_cached_content;
    string smallModelToken = "";
    string halluToken = "";
    string thinkingModeToken = "auto";
    string normalizedCacheMode = GPT_context_cache_mode;
    if (tokens.length() >= 1) {
        userModel = tokens[0];
    }
    for (int i = 1; i < int(tokens.length()); i++) {
        string t = tokens[i];
        string lowered = ToLower(t);
        if (lowered == "nullkey")
            allowNullApiKey = true;
        else if (lowered.length() >= 5 && lowered.substr(0,5) == "retry" && IsDigits(t.substr(5)))
            retryToken = t.substr(5);
        else if (IsDigits(t))
            delayToken = t;
        else if (lowered.length() >= 6 && lowered.substr(0,6) == "cache=")
            cacheToken = lowered.substr(6);
        else if (lowered.length() >= 8 && lowered.substr(0,8) == "context=" && IsDigits(t.substr(8)))
            contextSubtitleCountToken = t.substr(8);
        else if (lowered.length() >= 13 && lowered.substr(0,13) == "contextlines=" && IsDigits(t.substr(13)))
            contextSubtitleCountToken = t.substr(13);
        else if (lowered.length() >= 15 && lowered.substr(0,15) == "subtitlecount=" && IsDigits(t.substr(15)))
            contextSubtitleCountToken = t.substr(15);
        else if (lowered == "cacheauto" || lowered == "cacheon" || lowered == "cache")
            cacheToken = "auto";
        else if (lowered == "cacheoff" || lowered == "nocache")
            cacheToken = "off";
        else if (lowered.length() >= 10 && lowered.substr(0,10) == "retention=")
            promptCacheRetentionToken = lowered.substr(10);
        else if (lowered == "cache24h")
            promptCacheRetentionToken = "24h";
        else if (lowered == "cachemem" || lowered == "cachememory")
            promptCacheRetentionToken = "in-memory";
        else if (lowered.length() >= 15 && lowered.substr(0,15) == "cachedcontent=")
            geminiCachedContentToken = t.substr(15).Trim();
        else if (lowered.length() >= 15 && lowered.substr(0,15) == "cached_content=")
            geminiCachedContentToken = t.substr(15).Trim();
        else if (lowered.length() >= 7 && lowered.substr(0,7) == "gcache=")
            geminiCachedContentToken = t.substr(7).Trim();
        else if (lowered == "gcacheoff" || lowered == "nocachedcontent")
            geminiCachedContentToken = "";
        else if (lowered == "smallmodel=1" || lowered == "smallmodel")
            smallModelToken = "1";
        else if (lowered == "smallmodel=0")
            smallModelToken = "0";
        else if (lowered == "checkhallucination=1" || lowered == "hallucination=1")
            halluToken = "1";
        else if (lowered == "checkhallucination=0" || lowered == "hallucination=0")
            halluToken = "0";
        else if (lowered.length() >= 9 && lowered.substr(0,9) == "thinking=") {
            thinkingModeToken = GPT_CTX_NormalizeThinkingMode(lowered.substr(9));
            if (thinkingModeToken == "")
                return "Invalid thinking mode. Use thinking=auto, thinking=enabled, or thinking=disabled.\n";
        }
        else if (customApiUrl == "")
            customApiUrl = t;
    }
    if (retryToken != "")
        GPT_retry_mode = retryToken;
    if (delayToken != "")
        GPT_delay_ms = delayToken;
    if (contextSubtitleCountToken != "")
        GPT_context_subtitle_count = contextSubtitleCountToken;
    if (cacheToken != "")
        normalizedCacheMode = NormalizeCacheMode(cacheToken);
    else
        normalizedCacheMode = NormalizeCacheMode(normalizedCacheMode);
    promptCacheRetentionToken = NormalizePromptCacheRetention(promptCacheRetentionToken);
    if (smallModelToken != "")
        GPT_small_model = smallModelToken;
    if (halluToken != "")
        GPT_check_hallucination = halluToken;
    
    if (userModel == "")
        userModel = GPT_selected_model;

    if (userModel == "") {
        errorAccum += "Model name not entered. Please enter a valid model name.\n";
        return errorAccum;
    }
    string apiUrlLocal = "";
    if (customApiUrl != "") {
        apiUrlLocal = customApiUrl;
        while (apiUrlLocal != "" && apiUrlLocal.substr(apiUrlLocal.length()-1, 1) == "/")
            apiUrlLocal = apiUrlLocal.substr(0, apiUrlLocal.length()-1);
    } else {
        apiUrlLocal = GPT_apiUrl;
    }

    if (Pass == "")
        Pass = GPT_api_key;
    
    if (string(Pass).MakeLower() == "nullkey")
        allowNullApiKey = true;

    if (!allowNullApiKey && Pass == "") {
        errorAccum += "API Key not configured. Please enter a valid API Key.\n";
        return errorAccum;
    }
    string storedApiKey = (lowerPass == "nullkey" || (allowNullApiKey && Pass == "")) ? "nullkey" : Pass;
    bool isOfficial = IsOpenAIOfficialApiUrl(apiUrlLocal);
    bool isGemini = IsGeminiApiUrl(apiUrlLocal);
    string verifyHeaders = BuildAuthHeaders(Pass);
    string testSystemMsg = "You are a test assistant.";
    string testUserMsg = "Hello";
    string testPromptCacheKey = BuildPromptCacheKey(userModel, "verify", "verify");
    string testRequestData = BuildChatPayload(
        userModel,
        testSystemMsg,
        testUserMsg,
        isOfficial,
        testPromptCacheKey,
        promptCacheRetentionToken,
        isGemini,
        geminiCachedContentToken,
        thinkingModeToken
    );
    string testResponse = HostUrlGetString(apiUrlLocal, GPT_UserAgent, verifyHeaders, testRequestData);
    if (testResponse != "") {
        JsonReader testReader;
        JsonValue testRoot;
            if (testReader.parse(testResponse, testRoot)) {
                if (testRoot.isObject() && testRoot["choices"].isArray() && testRoot["choices"].size() > 0) {
                    GPT_selected_model = userModel;
                    GPT_api_key = storedApiKey;
                    HostSaveString("gpt_api_key", GPT_api_key);
                    HostSaveString("gpt_selected_model", GPT_selected_model);
                    GPT_thinking_mode = thinkingModeToken;
                    HostSaveString("gpt_thinking_mode", GPT_thinking_mode);
                    HostSaveString("gpt_apiUrl", apiUrlLocal);
                    HostSaveString("gpt_delay_ms", GPT_delay_ms);
                    HostSaveString("gpt_retry_mode", GPT_retry_mode);
                    HostSaveString("gpt_context_subtitle_count", GPT_context_subtitle_count);
                    GPT_context_cache_mode = normalizedCacheMode;
                    HostSaveString("gpt_context_cache_mode", GPT_context_cache_mode);
                    GPT_prompt_cache_retention = promptCacheRetentionToken;
                    HostSaveString("gpt_prompt_cache_retention", GPT_prompt_cache_retention);
                    GPT_gemini_cached_content = geminiCachedContentToken;
                    HostSaveString("gpt_gemini_cached_content", GPT_gemini_cached_content);
                    HostSaveString("gpt_small_model", GPT_small_model);
                    HostSaveString("gpt_check_hallucination", GPT_check_hallucination);
                    GPT_context_cache_disabled_for_session = false;
                    GPT_context_cache_disable_key = "";
                    return "200 ok";
                } else {
                    if (testRoot.isObject() && testRoot["error"].isObject() && testRoot["error"]["message"].isString())
                        errorAccum += "Test message error: " + testRoot["error"]["message"].asString() + "\n";
                    else
                    errorAccum += "Test message response invalid.\n";
            }
        } else {
            errorAccum += "Failed to parse test message response.\n";
        }
    } else {
        errorAccum += "No response from server when sending test message.\n";
    }
    if (apiUrlLocal.find("chat/completions") == -1) {
        string correctedApiUrl = apiUrlLocal + "/chat/completions";
        bool correctedIsOfficial = IsOpenAIOfficialApiUrl(correctedApiUrl);
        bool correctedIsGemini = IsGeminiApiUrl(correctedApiUrl);
        string correctedTestRequestData = BuildChatPayload(
            userModel,
            testSystemMsg,
            testUserMsg,
            correctedIsOfficial,
            testPromptCacheKey,
            promptCacheRetentionToken,
            correctedIsGemini,
            geminiCachedContentToken,
            thinkingModeToken
        );
        string correctedTestResponse = HostUrlGetString(correctedApiUrl, GPT_UserAgent, verifyHeaders, correctedTestRequestData);
        if (correctedTestResponse != "") {
            JsonReader correctedReader;
            JsonValue correctedRoot;
            if (correctedReader.parse(correctedTestResponse, correctedRoot)) {
                if (correctedRoot.isObject() && correctedRoot["choices"].isArray() && correctedRoot["choices"].size() > 0) {
                    apiUrlLocal = correctedApiUrl;
                    GPT_selected_model = userModel;
                    GPT_api_key = storedApiKey;
                    HostSaveString("gpt_api_key", GPT_api_key);
                    HostSaveString("gpt_selected_model", GPT_selected_model);
                    GPT_thinking_mode = thinkingModeToken;
                    HostSaveString("gpt_thinking_mode", GPT_thinking_mode);
                    HostSaveString("gpt_apiUrl", apiUrlLocal);
                    HostSaveString("gpt_delay_ms", GPT_delay_ms);
                    HostSaveString("gpt_retry_mode", GPT_retry_mode);
                    HostSaveString("gpt_context_subtitle_count", GPT_context_subtitle_count);
                    GPT_context_cache_mode = normalizedCacheMode;
                    HostSaveString("gpt_context_cache_mode", GPT_context_cache_mode);
                    GPT_prompt_cache_retention = promptCacheRetentionToken;
                    HostSaveString("gpt_prompt_cache_retention", GPT_prompt_cache_retention);
                    GPT_gemini_cached_content = geminiCachedContentToken;
                    HostSaveString("gpt_gemini_cached_content", GPT_gemini_cached_content);
                    HostSaveString("gpt_small_model", GPT_small_model);
                    HostSaveString("gpt_check_hallucination", GPT_check_hallucination);
                    GPT_context_cache_disabled_for_session = false;
                    GPT_context_cache_disable_key = "";
                    return "Warning: Your API base was auto-corrected to: " + apiUrlLocal + "\n200 ok";
                } else {
                    if (correctedRoot.isObject() && correctedRoot["error"].isObject() && correctedRoot["error"]["message"].isString())
                        errorAccum += "Auto-correction test error: " + correctedRoot["error"]["message"].asString() + "\n";
                    else
                        errorAccum += "Auto-correction test response invalid.\n";
                }
            } else {
                errorAccum += "Failed to parse auto-correction test response.\n";
            }
        } else {
            errorAccum += "No response from server after auto-correction.\n";
        }
    }
    if (isOfficial) {
        string verifyUrl = "";
        int pos = apiUrlLocal.find("chat/completions");
        if (pos != -1)
            verifyUrl = apiUrlLocal.substr(0, pos) + "models";
        else
            verifyUrl = "https://api.openai.com/v1/models";
        string verifyResponse = HostUrlGetString(verifyUrl, GPT_UserAgent, verifyHeaders, "");
        if (verifyResponse == "")
            errorAccum += "Server connection failed: Unable to retrieve model list. Check network and API Base.\n";
        else {
            JsonReader reader;
            JsonValue root;
            if (!reader.parse(verifyResponse, root))
                errorAccum += "Failed to parse model list response. Check API Base and API Key.\n";
            else {
                if (root.isObject() && root["error"].isObject() && root["error"]["message"].isString())
                    errorAccum += "API error during model list retrieval: " + root["error"]["message"].asString() + "\n";
                else if (root.isObject() && root["data"].isArray()) {
                    bool modelFound = false;
                    int dataSize = root["data"].size();
                    for (int i = 0; i < dataSize; i++) {
                        JsonValue element = root["data"][i];
                        if (element.isObject() && element["id"].isString()) {
                            if (element["id"].asString() == userModel) {
                                modelFound = true;
                                break;
                            }
                        }
                    }
                    if (!modelFound)
                        errorAccum += "The specified model '" + userModel + "' is not available in the official API.\n";
                } else
                    errorAccum += "Invalid format of model list response.\n";
            }
        }
    } else {
        errorAccum += "API verification via model list skipped for third-party API Base.\n";
    }
    if (!allowNullApiKey && Pass.length() < 20)
        errorAccum += "API Key verification failed: API Key length may too short. Please verify your API Key.\n";
    if (errorAccum != "")
        return "API verification failed with the following issues:\n\n" + errorAccum;
    return "Unknown error during API verification. Please check your network, API Key, and API Base settings.\n";
}

// Logout Interface to clear model name and API Key
void ServerLogout() {
    GPT_api_key = "";
    GPT_selected_model = GPT_pre_selected_model;
    GPT_apiUrl = GPT_pre_apiUrl;
    GPT_delay_ms = GPT_pre_delay_ms;
    GPT_retry_mode = GPT_pre_retry_mode;
    GPT_context_subtitle_count = GPT_pre_context_subtitle_count;
    GPT_context_cache_mode = GPT_pre_context_cache_mode;
    GPT_prompt_cache_retention = GPT_pre_prompt_cache_retention;
    GPT_gemini_cached_content = GPT_pre_gemini_cached_content;
    GPT_thinking_mode = GPT_pre_thinking_mode;
    GPT_small_model = GPT_pre_small_model;
    GPT_context_cache_disabled_for_session = false;
    GPT_context_cache_disable_key = "";
    HostSaveString("gpt_api_key", "");
    HostSaveString("gpt_selected_model", GPT_selected_model);
    HostSaveString("gpt_apiUrl", GPT_apiUrl);
    HostSaveString("gpt_delay_ms", GPT_delay_ms);
    HostSaveString("gpt_retry_mode", GPT_retry_mode);
    HostSaveString("gpt_context_subtitle_count", GPT_context_subtitle_count);
    HostSaveString("gpt_context_cache_mode", GPT_context_cache_mode);
    HostSaveString("gpt_prompt_cache_retention", GPT_prompt_cache_retention);
    HostSaveString("gpt_gemini_cached_content", GPT_gemini_cached_content);
    HostSaveString("gpt_thinking_mode", GPT_thinking_mode);
    HostSaveString("gpt_small_model", GPT_small_model);
    HostSaveString("gpt_check_hallucination", GPT_check_hallucination);
    HostPrintUTF8("Successfully logged out.\n");
}

// Explicit opt-in: never send provider-specific thinking fields by default.
string GPT_CTX_NormalizeThinkingMode(const string &in mode) {
    string normalized = string(mode.Trim()).MakeLower();
    if (normalized == "auto" || normalized == "enabled" || normalized == "disabled")
        return normalized;
    return "";
}

string GPT_CTX_BuildThinkingFields(const string &in mode, bool responses = false) {
    string normalized = GPT_CTX_NormalizeThinkingMode(mode);
    if (normalized != "enabled" && normalized != "disabled")
        return "";
    if (responses)
        return ",\"reasoning\":{\"effort\":\"" + (normalized == "disabled" ? "none" : "high") + "\"}";
    return ",\"thinking\":{\"type\":\"" + normalized + "\"}";
}

// JSON String Escape Function
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    output.replace("/", "\\/");
    return output;
}

// Function to estimate token count based on character length
int EstimateTokenCount(const string &in text) {
    return int(float(text.length()) / 4);
}

// Function to get the model's maximum context length
int GetModelMaxTokens(const string &in modelName) {
    EnsureTokenRulesLoaded();
    string trimmedModel = modelName.Trim();
    if (trimmedModel == "")
        return GPT_default_model_token_limit;

    for (uint i = 0; i < GPT_token_rule_types.length(); i++) {
        string matchType = GPT_token_rule_types[i];
        string matchValue = GPT_token_rule_values[i];
        int limit = GPT_token_rule_limits[i];
        if (matchType == "prefix") {
            if (trimmedModel.length() >= matchValue.length() &&
                trimmedModel.substr(0, matchValue.length()) == matchValue)
                return limit;
        } else if (matchType == "contains") {
            if (trimmedModel.find(matchValue) != -1)
                return limit;
        } else if (matchType == "equals") {
            if (trimmedModel == matchValue)
                return limit;
        }
    }

    return GPT_default_model_token_limit;
}

// Translation Function
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    RefreshConfiguration();
    LoadSubtitleFilters();
    Text = FilterSubtitle(Text);
    if (Text.Trim() == "") return "";

    if (GPT_api_key == "") {
        HostPrintUTF8("API Key not configured. Please enter it in the settings menu.\n");
        return "";
    }

    if (DstLang == "" || DstLang == "Auto Detect") {
        HostPrintUTF8("Target language not specified. Please select a target language.\n");
        return "";
    }

    if (SrcLang == "" || SrcLang == "Auto Detect") {
        SrcLang = "";
    }

    GPT_subtitleHistory.insertLast(Text);

    int maxContextLines = ParseInt(GPT_context_subtitle_count);
    if (maxContextLines < 0)
        maxContextLines = 0;
    if (maxContextLines > 20)
        maxContextLines = 20;

    array<string> contextSegments;
    int addedContextLines = 0;
    string currentText = Text.Trim();
    int idx = int(GPT_subtitleHistory.length()) - 2;
    while (idx >= 0 && addedContextLines < maxContextLines) {
        // Rules may have changed since this entry was recorded.
        string subtitle = FilterSubtitle(GPT_subtitleHistory[idx]).Trim();
        if (subtitle == "" || subtitle == currentText) {
            idx--;
            continue;
        }
        contextSegments.insertAt(0, subtitle);
        addedContextLines++;
        idx--;
    }

    string context = "";
    for (uint ctxIndex = 0; ctxIndex < contextSegments.length(); ctxIndex++) {
        if (ctxIndex > 0)
            context += "\n";
        context += contextSegments[ctxIndex];
    }

    int historyTarget = maxContextLines + 32;
    if (historyTarget < 64)
        historyTarget = 64;
    if (historyTarget > 256)
        historyTarget = 256;
    int shrinkTarget = historyTarget - 16;
    if (shrinkTarget < 32)
        shrinkTarget = 32;
    const uint historyTargetCount = historyTarget > 0 ? uint(historyTarget) : 0;
    const uint shrinkTargetCount = shrinkTarget > 0 ? uint(shrinkTarget) : 0;
    if (GPT_subtitleHistory.length() > historyTargetCount) {
        while (GPT_subtitleHistory.length() > shrinkTargetCount) {
            GPT_subtitleHistory.removeAt(0);
        }
    }

    string sourceLabel = (SrcLang == "" ? "Auto Detect" : SrcLang);
    string targetLangCode = DstLang;
    string targetLabel = targetLangCode;

    string systemMsg =
        "You are a subtitle translator. "
        "Translate ONLY the text inside <CURRENT> into " + targetLabel + ". "
        "The text inside <CONTEXT> is for understanding only and MUST NOT be translated, repeated, summarized, or mentioned. "
        "Output only the translation of <CURRENT>. No explanations.\n"
        "Source language: " + sourceLabel + "\n"
        "Target language: " + targetLabel + "\n";

    string userMsg = "";
    if (context != "") {
        userMsg += "<CONTEXT>\n" + context + "\n</CONTEXT>\n\n";
    }
    userMsg += "<CURRENT>\n" + Text + "\n</CURRENT>";

    bool isOpenAIOfficial = IsOpenAIOfficialApiUrl(GPT_apiUrl);
    bool isGeminiApi = IsGeminiApiUrl(GPT_apiUrl);
    bool enableOpenAIPromptCacheControls = isOpenAIOfficial;
    string promptCacheRetention = isOpenAIOfficial ? NormalizePromptCacheRetention(GPT_prompt_cache_retention) : "";
    string promptCacheKey = isOpenAIOfficial ? BuildPromptCacheKey(GPT_selected_model, sourceLabel, targetLabel) : "";

    string requestData = BuildChatPayload(
        GPT_selected_model,
        systemMsg,
        userMsg,
        enableOpenAIPromptCacheControls,
        promptCacheKey,
        promptCacheRetention,
        isGeminiApi,
        GPT_gemini_cached_content,
        GPT_thinking_mode
    );

    string headers = BuildAuthHeaders(GPT_api_key);
    int delayInt = ParseInt(GPT_delay_ms);
    int retryModeInt = ParseInt(GPT_retry_mode);

    string cacheSessionKey = GPT_context_cache_mode + "|" + GPT_apiUrl + "|" + GPT_selected_model + "|" + promptCacheRetention + "|" + GPT_gemini_cached_content + "|" + GPT_thinking_mode;
    if (cacheSessionKey != GPT_context_cache_disable_key)
        GPT_context_cache_disabled_for_session = false;
    GPT_context_cache_disable_key = cacheSessionKey;

    string translation = "";
    string response = "";

    // Unified Retry Loop: Handles Network, API Errors, and Hallucinations
    int maxRetries = retryModeInt;
    if (maxRetries < 0) maxRetries = 0;
    if (retryModeInt == 2) maxRetries = 999999; // retry until success (infinite-ish)
    if (retryModeInt == 3) maxRetries = 999999; // retry until success delayed

    int attempts = 0;

    while (attempts <= maxRetries) {
        if (attempts > 0) {
            if (delayInt > 0) HostSleep(delayInt);
        }

        translation = "";
        response = "";

        // Try Context Caching first if enabled
        if (GPT_context_cache_mode != "off" && !GPT_context_cache_disabled_for_session && ShouldTryResponsesEndpoint(GPT_apiUrl)) {
            string responsesUrl = DeriveResponsesUrl(GPT_apiUrl);
            string cacheFailure = "";
            if (responsesUrl != "") {
                translation = TranslateWithResponses(responsesUrl, headers, GPT_selected_model, systemMsg, userMsg, promptCacheKey, promptCacheRetention, cacheFailure);
            } else {
                cacheFailure = "Unable to resolve responses endpoint from current API URL.";
            }
            if (translation != "") {
                            // Check for Hallucination
                            if (GPT_check_hallucination == "1" && IsOverlongTranslation(translation, Text)) {
                                HostPrintUTF8("Hallucination detected (Length > 5x). Retrying...\n");
                                attempts++;
                                continue; 
                            }                break; // Success
            }

            if (!GPT_context_cache_disabled_for_session) {
                string fallbackMessage = cacheFailure == "" ? "Context caching failed." : "Context caching failed: " + cacheFailure;
                if (ShouldDisableContextCacheForSession(cacheFailure)) {
                    // Permanent capability errors should disable responses attempts for this session.
                    GPT_context_cache_disabled_for_session = true;
                    HostPrintUTF8(fallbackMessage + "\nUsing chat completions for this session.\n");
                } else {
                    HostPrintUTF8(fallbackMessage + "\nUsing chat completions for this request.\n");
                }
            }
        }

        // Standard Chat Completion
        response = ExecuteSimple(GPT_apiUrl, headers, requestData);

        if (response == "") {
             // Network failure
             attempts++;
             continue;
        }

        JsonReader Reader;
        JsonValue Root;
        if (!Reader.parse(response, Root)) {
            HostPrintUTF8("Failed to parse API response.\n");
            attempts++;
            continue;
        }

        JsonValue choices = Root["choices"];
        if (choices.isArray() && choices.size() > 0 &&
            choices[0].isObject() &&
            choices[0]["message"].isObject() &&
            choices[0]["message"]["content"].isString()) {
            translation = choices[0]["message"]["content"].asString();
            
                        // Check for Hallucination
                        if (GPT_check_hallucination == "1" && IsOverlongTranslation(translation, Text)) {
                            HostPrintUTF8("Hallucination detected (Length > 5x). Retrying...\n");
                            attempts++;
                            continue; 
                        }
            break; // Success
        } else if (Root.isObject() &&
                   Root["error"].isObject() &&
                   Root["error"]["message"].isString()) {
            string errorMessage = Root["error"]["message"].asString();
            HostPrintUTF8("API Error: " + errorMessage + "\n");
            string loweredError = ToLower(errorMessage);
            if (enableOpenAIPromptCacheControls && loweredError.find("prompt_cache") != -1) {
                enableOpenAIPromptCacheControls = false;
                requestData = BuildChatPayload(
                    GPT_selected_model,
                    systemMsg,
                    userMsg,
                    false,
                    promptCacheKey,
                    promptCacheRetention,
                    isGeminiApi,
                    GPT_gemini_cached_content,
                    GPT_thinking_mode
                );
                HostPrintUTF8("Prompt cache control fields are unsupported on this endpoint. Retrying without them.\n");
            }
             // API returned an error (e.g. rate limit, context length). 
             // Should we retry? Usually yes for rate limits, maybe no for invalid request.
             // For simplicity and robustness, we retry.
            attempts++;
            continue;
        } else {
            HostPrintUTF8("Translation failed. Unknown response format.\n");
            attempts++;
            continue;
        }
    }

    if (translation == "") {
         string failureMessage = "Translation failed after retries.";
         if (response != "") failureMessage += " Last response: " + response;
         HostPrintUTF8(failureMessage + "\n");
         return FormatFailureTranslation(response, "Translation failed. Check settings and network.");
    }

    bool isFailureTranslation = translation.length() >= GPT_CTX_TRANSLATION_FAILURE_WARNING_PREFIX.length() &&
                                translation.substr(0, GPT_CTX_TRANSLATION_FAILURE_WARNING_PREFIX.length()) == GPT_CTX_TRANSLATION_FAILURE_WARNING_PREFIX;

    if (!isFailureTranslation && GPT_selected_model.find("gemini") != -1) {
        while (translation.length() > 0 && translation.substr(translation.length() - 1, 1) == "\n") {
            translation = translation.substr(0, translation.length() - 1);
        }
    }
    if (!isFailureTranslation && (targetLangCode == "fa" || targetLangCode == "ar" || targetLangCode == "he")) {
        string UNICODE_RLE = "\u202B";
        translation = UNICODE_RLE + translation;
    }
    SrcLang = "UTF8";
    DstLang = "UTF8";
    return translation.Trim();
}

string FormatFailureTranslation(const string &in rawResponse, const string &in fallbackMessage) {
    string detail = rawResponse.Trim();
    if (detail == "")
        detail = fallbackMessage;
    return GPT_CTX_TRANSLATION_FAILURE_WARNING_PREFIX + detail;
}

// Plugin Initialization
void OnInitialize() {
    HostPrintUTF8("ChatGPT translation plugin loaded.\n");
    RefreshConfiguration();
    GPT_context_cache_disabled_for_session = false;
    GPT_context_cache_disable_key = "";
    if (GPT_api_key != "") {
        HostPrintUTF8("Saved API Key, model name, and API URL loaded.\n");
    }
}

// Plugin Finalization
void OnFinalize() {
    HostPrintUTF8("ChatGPT translation plugin unloaded.\n");
}
string ToLower(const string &in s) {
    return s.MakeLower();
}

string NormalizeCacheMode(const string &in mode) {
    string trimmed = mode.Trim();
    if (trimmed == "")
        return "auto";
    string lower = ToLower(trimmed);
    if (lower == "off" || lower == "disable" || lower == "disabled" || lower == "chat")
        return "off";
    return "auto";
}

string NormalizePromptCacheRetention(const string &in retention) {
    string trimmed = retention.Trim();
    if (trimmed == "")
        return "";
    string lower = ToLower(trimmed);
    if (lower == "24h")
        return "24h";
    if (lower == "in_memory" || lower == "in-memory" || lower == "memory" || lower == "mem" || lower == "default")
        return "in-memory";
    return "";
}

bool IsOpenAIOfficialApiUrl(const string &in apiUrl) {
    return ToLower(apiUrl).find("api.openai.com") != -1;
}

bool IsGeminiApiUrl(const string &in apiUrl) {
    string lower = ToLower(apiUrl);
    return lower.find("generativelanguage.googleapis.com") != -1;
}

bool ShouldTryResponsesEndpoint(const string &in apiUrl) {
    if (IsGeminiApiUrl(apiUrl))
        return false;
    return true;
}

bool ShouldDisableContextCacheForSession(const string &in failureReason) {
    string lower = ToLower(failureReason.Trim());
    if (lower == "")
        return false;
    if (lower.find("404") != -1 || lower.find("not found") != -1)
        return true;
    if (lower.find("unsupported") != -1 || lower.find("does not support") != -1)
        return true;
    if (lower.find("unknown parameter") != -1 || lower.find("unrecognized") != -1 || lower.find("invalid parameter") != -1)
        return true;
    if (lower.find("no response from responses endpoint") != -1)
        return true;
    if (lower.find("route") != -1 || lower.find("endpoint") != -1 || lower.find("responses endpoint") != -1)
        return true;
    return false;
}

string BuildPromptCacheKey(const string &in modelName, const string &in sourceLang, const string &in targetLang) {
    string key = "potplayer_subtitle_translate_v2";
    string model = ToLower(modelName.Trim());
    string src = ToLower(sourceLang.Trim());
    string dst = ToLower(targetLang.Trim());
    if (model != "")
        key += "|" + model;
    if (src == "")
        src = "auto";
    if (dst == "")
        dst = "auto";
    key += "|" + src + ">" + dst;
    return key;
}

string BuildChatPayload(
    const string &in modelName,
    const string &in systemMsg,
    const string &in userMsg,
    bool includePromptCacheControls,
    const string &in promptCacheKey,
    const string &in promptCacheRetention,
    bool includeGeminiCachedContent,
    const string &in geminiCachedContent,
    const string &in thinkingMode
) {
    string escapedModel = JsonEscape(modelName);
    string escapedSystem = JsonEscape(systemMsg);
    string escapedUser = JsonEscape(userMsg);
    string payload = "{\"model\":\"" + escapedModel + "\"";

    payload += GPT_CTX_BuildThinkingFields(thinkingMode);

    string cacheKey = promptCacheKey.Trim();
    if (includePromptCacheControls && cacheKey != "")
        payload += ",\"prompt_cache_key\":\"" + JsonEscape(cacheKey) + "\"";

    string retention = NormalizePromptCacheRetention(promptCacheRetention);
    if (includePromptCacheControls && retention != "")
        payload += ",\"prompt_cache_retention\":\"" + JsonEscape(retention) + "\"";

    payload += ",\"messages\":[{\"role\":\"system\",\"content\":\"" + escapedSystem + "\"},{\"role\":\"user\",\"content\":\"" + escapedUser + "\"}]";

    string cachedContent = geminiCachedContent.Trim();
    if (includeGeminiCachedContent && cachedContent != "")
        payload += ",\"google\":{\"cached_content\":\"" + JsonEscape(cachedContent) + "\"}";

    payload += "}";
    return payload;
}

void EnsureTokenRulesLoaded() {
    if (GPT_token_rules_initialized)
        return;
    GPT_token_rules_initialized = true;
    GPT_default_model_token_limit = 4096;
    GPT_token_rule_types.resize(0);
    GPT_token_rule_values.resize(0);
    GPT_token_rule_limits.resize(0);

    JsonReader reader;
    JsonValue root;
    if (!reader.parse(GPT_pre_model_token_limits_json, root))
        return;
    if (!root.isObject())
        return;

    if (root["default"].isInt())
        GPT_default_model_token_limit = root["default"].asInt();
    else if (root["default"].isString()) {
        int parsedDefault = ParseInt(root["default"].asString());
        if (parsedDefault > 0)
            GPT_default_model_token_limit = parsedDefault;
    }

    JsonValue rulesNode = root["rules"];
    if (!rulesNode.isArray())
        return;

    int count = rulesNode.size();
    for (int i = 0; i < count; i++) {
        JsonValue entry = rulesNode[i];
        if (!entry.isObject())
            continue;
        string matchType = "";
        string matchValue = "";
        int limit = 0;
        if (entry["type"].isString())
            matchType = entry["type"].asString();
        if (entry["value"].isString())
            matchValue = entry["value"].asString();
        if (entry["tokens"].isInt())
            limit = entry["tokens"].asInt();
        else if (entry["tokens"].isString())
            limit = ParseInt(entry["tokens"].asString());
        if (matchType != "" && matchValue != "" && limit > 0) {
            GPT_token_rule_types.insertLast(matchType);
            GPT_token_rule_values.insertLast(matchValue);
            GPT_token_rule_limits.insertLast(limit);
        }
    }
}

string DeriveResponsesUrl(const string &in originalUrl) {
    string url = originalUrl.Trim();
    while (url.length() > 0 && url.substr(url.length() - 1, 1) == "/")
        url = url.substr(0, url.length() - 1);
    if (url == "")
        return "";
    if (url.find("/responses") != -1)
        return url;
    int chatPos = url.find("/chat/completions");
    if (chatPos != -1)
        return url.substr(0, chatPos) + "/responses";
    return url + "/responses";
}

string ExecuteSimple(const string &in url, const string &in headers, const string &in payload) {
    return HostUrlGetString(url, GPT_UserAgent, headers, payload);
}

string BuildResponsesPayload(
    const string &in modelName,
    const string &in systemMsg,
    const string &in userMsg,
    const string &in promptCacheKey,
    const string &in promptCacheRetention,
    const string &in thinkingMode
) {
    string escapedSystem = JsonEscape(systemMsg);
    string escapedUser = JsonEscape(userMsg);
    string payload = "{\"model\":\"" + JsonEscape(modelName) + "\"";
    payload += GPT_CTX_BuildThinkingFields(thinkingMode, true);
    string cacheKey = promptCacheKey.Trim();
    if (cacheKey != "")
        payload += ",\"prompt_cache_key\":\"" + JsonEscape(cacheKey) + "\"";
    string retention = NormalizePromptCacheRetention(promptCacheRetention);
    if (retention != "")
        payload += ",\"prompt_cache_retention\":\"" + JsonEscape(retention) + "\"";
    payload += ",\"input\":[";
    payload += "{\"role\":\"system\",\"content\":[{\"type\":\"input_text\",\"text\":\"" + escapedSystem + "\"}]}";
    payload += ",{\"role\":\"user\",\"content\":[{\"type\":\"input_text\",\"text\":\"" + escapedUser + "\"}]}";
    payload += "]}";
    return payload;
}

string ExtractResponsesText(JsonValue &in root) {
    if (!root.isObject())
        return "";

    JsonValue output = root["output"];
    if (!output.isArray())
        return "";

    int size = output.size();
    for (int i = 0; i < size; i++) {
        JsonValue entry = output[i];
        if (!entry.isObject())
            continue;
        JsonValue content = entry["content"];
        if (!content.isArray())
            continue;
        int csize = content.size();
        for (int j = 0; j < csize; j++) {
            JsonValue part = content[j];
            if (part.isObject()) {
                if (part["type"].isString() && part["type"].asString() == "output_text" && part["text"].isString())
                    return part["text"].asString();
            } else if (part.isString()) {
                return part.asString();
            }
        }
    }
    return "";
}

string TranslateWithResponses(
    const string &in responsesUrl,
    const string &in headers,
    const string &in modelName,
    const string &in systemMsg,
    const string &in userMsg,
    const string &in promptCacheKey,
    const string &in promptCacheRetention,
    string &out failureReason
) {
    string requestData = BuildResponsesPayload(modelName, systemMsg, userMsg, promptCacheKey, promptCacheRetention, GPT_thinking_mode);
    string response = ExecuteSimple(responsesUrl, headers, requestData);
    if (response == "") {
        failureReason = "No response from Responses endpoint.";
        return "";
    }

    JsonReader reader;
    JsonValue root;
    if (!reader.parse(response, root)) {
        failureReason = "Failed to parse Responses API response.";
        return "";
    }

    string translatedText = ExtractResponsesText(root);
    if (translatedText != "") {
        return translatedText;
    }

    if (root.isObject() && root["error"].isObject() && root["error"]["message"].isString()) {
        failureReason = root["error"]["message"].asString();
    } else {
        failureReason = "Responses API returned no usable output.";
    }
    return "";
}

bool IsOverlongTranslation(const string &in translation, const string &in original) {
    if (original.length() == 0) return false;
    return translation.length() > (original.length() * 5);
}
