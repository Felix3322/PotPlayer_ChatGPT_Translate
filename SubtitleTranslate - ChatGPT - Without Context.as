/*
    Real-time subtitle translation for PotPlayer using OpenAI ChatGPT API
    (Without Context Support)
*/

// Plugin Information Functions
string GetTitle() {
    return "{$CP949=ChatGPT 번역 (문맥 없음) $}"
         + "{$CP950=ChatGPT 翻譯 (無上下文) $}"
         + "{$CP936=ChatGPT 翻译 (无上下文) $}"
         + "{$CP0=ChatGPT Translate (No Context) $}";
}

// The version number will be replaced during the installation process
string GetVersion() {
    return "1.9.4-wc";
}

string GetDesc() {
    return "Real-time subtitle translation using OpenAI ChatGPT. (No Context Support)";
}

string GetLoginTitle() {
    return "{$CP949=OpenAI 모델 및 API 키 구성 (문맥 없음) $}"
         + "{$CP950=OpenAI 模型與 API 金鑰配置 (無上下文) $}"
         + "{$CP936=OpenAI 模型与 API 密钥配置 (无上下文) $}"
         + "{$CP0=OpenAI Model + API URL and API Key Configuration (No Context) $}";
}

string GetLoginDesc() {
    return "{$CP949=모델 이름, API 주소, 선택적 nullkey, 지연(ms) 및 재시도 모드(0-3)를 입력하십시오 (예: gpt-5-mini|https://api.openai.com/v1/chat/completions|nullkey|500|retry1).$}"
         + "{$CP949=\n\n설치 프로그램에서 미리 구성한 값이 있다면 PotPlayer 패널에서 다시 설정하기 전까지 해당 값을 사용하며, 패널에서 설정하면 해당 설정이 항상 우선 적용됩니다.$}"
         + "{$CP950=請輸入模型名稱、API 地址、可選的 nullkey、延遲毫秒與重試模式(0-3)（例如: gpt-5-mini|https://api.openai.com/v1/chat/completions|nullkey|500|retry1）。$}"
         + "{$CP950=\n\n如果安裝包已寫入預設配置，在 PotPlayer 面板中未重新設定之前會沿用這些配置；一旦在面板中調整，將始終以面板設定為準。$}"
         + "{$CP936=请输入模型名称、API 地址、可选的 nullkey、延迟毫秒和重试模式(0-3)（例如: gpt-5-mini|https://api.openai.com/v1/chat/completions|nullkey|500|retry1）。$}"
         + "{$CP936=\n\n如果安装包已经写入默认配置，在 PotPlayer 面板中没有重新设置之前会继续使用这些配置；一旦在面板中修改，将始终以面板设置为准。$}"
         + "{$CP950=\n\n支援的服務商可追加 thinking=disabled 關閉思考，thinking=enabled 開啟，thinking=auto 使用預設值。$}"
         + "{$CP949=\n\n지원하는 API에서 thinking=disabled 로 사고 모드를 끄고, thinking=enabled 로 켜고, thinking=auto 로 기본값을 사용할 수 있습니다.$}"
         + "{$CP936=\n\n支持的服务商可追加 thinking=disabled 关闭思考，thinking=enabled 开启，thinking=auto 使用服务商默认值。$}"
         + "{$CP0=Please enter the model name, API URL, optional 'nullkey', optional delay in ms, and retry mode 0-3 (e.g., gpt-5-mini|https://api.openai.com/v1/chat/completions|nullkey|500|retry1).$}"
         + "{$CP0=\n\nInstaller defaults will remain in effect until you update the settings in PotPlayer's panel, and any panel changes will always take priority.$}"
         + "{$CP0=\n\nFor compatible providers, append thinking=disabled, thinking=enabled, or thinking=auto (provider default).$}";
}

string GetUserText() {
    return "{$CP949=모델 이름|API 주소|nullkey|지연(ms)|재시도 모드 (현재: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + ")$}"
         + "{$CP950=模型名稱|API 地址|nullkey|延遲ms|重試模式 (目前: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + ")$}"
         + "{$CP936=模型名称|API 地址|nullkey|延迟ms|重试模式 (目前: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + ")$}"
         + "{$CP0=Model Name|API URL|nullkey|Delay ms|Retry mode (Current: " + GPT_selected_model + " | " + GPT_apiUrl + " | " + GPT_delay_ms + " | " + GPT_retry_mode + ")$}";
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
// No-context identifiers are prefixed to avoid conflicts with other subtitle translator scripts.
const string GPT_WC_TRANSLATION_FAILURE_WARNING_PREFIX = "[Translation failed - please share a screenshot with the developer] ";

string GPT_pre_api_key = ""; // will be replaced during installation
string GPT_pre_selected_model = "gpt-5-mini"; // will be replaced during installation
string GPT_pre_apiUrl = "https://api.openai.com/v1/chat/completions"; // will be replaced during installation
string GPT_pre_delay_ms = "0"; // will be replaced during installation
string GPT_pre_retry_mode = "0"; // will be replaced during installation
string GPT_pre_thinking_mode = "auto"; // auto (provider default) | enabled | disabled
string GPT_pre_small_model = "0"; // 0 | 1
string GPT_pre_check_hallucination = "0"; // 0 | 1
string GPT_pre_model_token_limits_json = "{}"; // serialized token limit rules (injected by installer)

string GPT_api_key = GPT_pre_api_key;
string GPT_selected_model = GPT_pre_selected_model; // Default model
string GPT_apiUrl = GPT_pre_apiUrl; // Default API URL
string GPT_delay_ms = GPT_pre_delay_ms; // Request delay in ms
string GPT_retry_mode = GPT_pre_retry_mode; // Auto retry mode
string GPT_thinking_mode = GPT_pre_thinking_mode;
string GPT_small_model = GPT_pre_small_model;
string GPT_check_hallucination = GPT_pre_check_hallucination;
string GPT_context_cache_mode = "off"; // Always off for WC version, but kept for compatibility logic
string GPT_UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
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
    EnsureConfigDefault("wc_api_key", GPT_pre_api_key);
    EnsureConfigDefault("wc_selected_model", GPT_pre_selected_model);
    EnsureConfigDefault("wc_apiUrl", GPT_pre_apiUrl);
    EnsureConfigDefault("wc_delay_ms", GPT_pre_delay_ms);
    EnsureConfigDefault("wc_retry_mode", GPT_pre_retry_mode);
    EnsureConfigDefault("wc_thinking_mode", GPT_pre_thinking_mode);
    EnsureConfigDefault("wc_small_model", GPT_pre_small_model);
    EnsureConfigDefault("wc_check_hallucination", GPT_pre_check_hallucination);
}

void RefreshConfiguration() {
    EnsureInstallerDefaultsPersisted();
    GPT_api_key = LoadInstallerConfig("wc_api_key", GPT_pre_api_key, "gpt_api_key");
    GPT_selected_model = LoadInstallerConfig("wc_selected_model", GPT_pre_selected_model, "gpt_selected_model");
    GPT_apiUrl = LoadInstallerConfig("wc_apiUrl", GPT_pre_apiUrl, "gpt_apiUrl");
    GPT_delay_ms = LoadInstallerConfig("wc_delay_ms", GPT_pre_delay_ms, "gpt_delay_ms");
    GPT_retry_mode = LoadInstallerConfig("wc_retry_mode", GPT_pre_retry_mode, "gpt_retry_mode");
    GPT_thinking_mode = GPT_WC_NormalizeThinkingMode(LoadInstallerConfig("wc_thinking_mode", GPT_pre_thinking_mode));
    GPT_small_model = LoadInstallerConfig("wc_small_model", GPT_pre_small_model, "gpt_small_model");
    GPT_check_hallucination = LoadInstallerConfig("wc_check_hallucination", GPT_pre_check_hallucination, "gpt_check_hallucination");
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
    string cacheToken = "";
    string smallModelToken = "";
    string halluToken = "";
    string thinkingModeToken = "auto";
    string normalizedCacheMode = GPT_context_cache_mode;
    if (tokens.length() >= 1) {
        userModel = tokens[0];
    }
    for (int i = 1; i < int(tokens.length()); i++) {
        string t = tokens[i];
        string lowered = t.MakeLower();
        if (lowered == "nullkey")
            allowNullApiKey = true;
        else if (lowered.length() >= 5 && lowered.substr(0,5) == "retry" && IsDigits(t.substr(5)))
            retryToken = t.substr(5);
        else if (IsDigits(t))
            delayToken = t;
        else if (lowered == "smallmodel=1" || lowered == "smallmodel")
            smallModelToken = "1";
        else if (lowered == "smallmodel=0")
            smallModelToken = "0";
        else if (lowered == "checkhallucination=1" || lowered == "hallucination=1")
            halluToken = "1";
        else if (lowered == "checkhallucination=0" || lowered == "hallucination=0")
            halluToken = "0";
        else if (lowered.length() >= 9 && lowered.substr(0,9) == "thinking=") {
            thinkingModeToken = GPT_WC_NormalizeThinkingMode(lowered.substr(9));
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
    bool isOfficial = (apiUrlLocal.find("api.openai.com") != -1);
    string verifyHeaders = BuildAuthHeaders(Pass);
    string testSystemMsg = "You are a test assistant.";
    string testUserMsg = "Hello";
    string testRequestData = GPT_WC_BuildChatPayload(userModel, testSystemMsg, testUserMsg, thinkingModeToken);
    string testResponse = HostUrlGetString(apiUrlLocal, GPT_UserAgent, verifyHeaders, testRequestData);
    if (testResponse != "") {
        JsonReader testReader;
        JsonValue testRoot;
        if (testReader.parse(testResponse, testRoot)) {
            if (testRoot.isObject() && testRoot["choices"].isArray() && testRoot["choices"].size() > 0) {
                GPT_selected_model = userModel;
                GPT_api_key = storedApiKey;
                HostSaveString("wc_api_key", GPT_api_key);
                HostSaveString("wc_selected_model", GPT_selected_model);
                GPT_thinking_mode = thinkingModeToken;
                HostSaveString("wc_thinking_mode", GPT_thinking_mode);
                HostSaveString("wc_apiUrl", apiUrlLocal);
                HostSaveString("wc_delay_ms", GPT_delay_ms);
                HostSaveString("wc_retry_mode", GPT_retry_mode);
                HostSaveString("wc_small_model", GPT_small_model);
                HostSaveString("wc_check_hallucination", GPT_check_hallucination);
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
        string correctedTestResponse = HostUrlGetString(correctedApiUrl, GPT_UserAgent, verifyHeaders, testRequestData);
        if (correctedTestResponse != "") {
            JsonReader correctedReader;
            JsonValue correctedRoot;
            if (correctedReader.parse(correctedTestResponse, correctedRoot)) {
                if (correctedRoot.isObject() && correctedRoot["choices"].isArray() && correctedRoot["choices"].size() > 0) {
                    apiUrlLocal = correctedApiUrl;
                    GPT_selected_model = userModel;
                    GPT_api_key = storedApiKey;
                    HostSaveString("wc_api_key", GPT_api_key);
                    HostSaveString("wc_selected_model", GPT_selected_model);
                    GPT_thinking_mode = thinkingModeToken;
                    HostSaveString("wc_thinking_mode", GPT_thinking_mode);
                    HostSaveString("wc_apiUrl", apiUrlLocal);
                    HostSaveString("wc_delay_ms", GPT_delay_ms);
                HostSaveString("wc_retry_mode", GPT_retry_mode);
                HostSaveString("wc_small_model", GPT_small_model);
                HostSaveString("wc_check_hallucination", GPT_check_hallucination);
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
    GPT_thinking_mode = GPT_pre_thinking_mode;
    GPT_small_model = GPT_pre_small_model;
    GPT_check_hallucination = GPT_pre_check_hallucination;
    HostSaveString("wc_api_key", "");
    HostSaveString("wc_selected_model", GPT_selected_model);
    HostSaveString("wc_apiUrl", GPT_apiUrl);
    HostSaveString("wc_delay_ms", GPT_delay_ms);
    HostSaveString("wc_retry_mode", GPT_retry_mode);
    HostSaveString("wc_thinking_mode", GPT_thinking_mode);
    HostSaveString("wc_small_model", GPT_small_model);
    HostSaveString("wc_check_hallucination", GPT_check_hallucination);
    HostPrintUTF8("Successfully logged out.\n");
}

// Explicit opt-in: never send provider-specific thinking fields by default.
string GPT_WC_NormalizeThinkingMode(const string &in mode) {
    string normalized = string(mode.Trim()).MakeLower();
    if (normalized == "auto" || normalized == "enabled" || normalized == "disabled")
        return normalized;
    return "";
}

string GPT_WC_BuildThinkingFields(const string &in mode, bool responses = false) {
    string normalized = GPT_WC_NormalizeThinkingMode(mode);
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

string ExecuteSimple(const string &in url, const string &in headers, const string &in payload) {
    return HostUrlGetString(url, GPT_UserAgent, headers, payload);
}

bool IsOverlongTranslation(const string &in translation, const string &in original) {
    if (original.length() == 0) return false;
    return translation.length() > (original.length() * 5);
}

// Translation Function (Without Context Support)
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

    string systemMsg = "You translate subtitles. Output only the translation.";
    string userMsg = "Translate from " + (SrcLang == "" ? "Auto Detect" : SrcLang) + " to " + DstLang + ":\n" + Text;
    
    // Separate instruction from user content if Small Model Mode is enabled
    if (GPT_small_model == "1") {
        systemMsg = "You translate subtitles from " + (SrcLang == "" ? "Auto Detect" : SrcLang) + " to " + DstLang + ". Output only the translation.";
        userMsg = Text;
    }

    string requestData = GPT_WC_BuildChatPayload(GPT_selected_model, systemMsg, userMsg, GPT_thinking_mode);

    string headers = BuildAuthHeaders(GPT_api_key);
    int delayInt = ParseInt(GPT_delay_ms);
    int retryModeInt = ParseInt(GPT_retry_mode);
    string response = "";

    int maxRetries = retryModeInt;
    if (maxRetries < 0) maxRetries = 0;
    if (retryModeInt == 2) maxRetries = 999999;
    if (retryModeInt == 3) maxRetries = 999999;

    int attempts = 0;
    while (attempts <= maxRetries) {
        if (attempts > 0) {
            if (delayInt > 0) HostSleep(delayInt);
        }

        response = ExecuteSimple(GPT_apiUrl, headers, requestData);

        if (response == "") {
            // Network error
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
            
            string translatedText = choices[0]["message"]["content"].asString();
            
            // Hallucination Check
            if (GPT_check_hallucination == "1" && IsOverlongTranslation(translatedText, Text)) {
                 HostPrintUTF8("Hallucination detected (Length > 5x). Retrying...\n");
                 attempts++;
                 continue;
            }

            bool isFailureTranslation = translatedText.length() >= GPT_WC_TRANSLATION_FAILURE_WARNING_PREFIX.length() &&
                                        translatedText.substr(0, GPT_WC_TRANSLATION_FAILURE_WARNING_PREFIX.length()) == GPT_WC_TRANSLATION_FAILURE_WARNING_PREFIX;

            if (!isFailureTranslation && GPT_selected_model.find("gemini") != -1) {
                while (translatedText.length() > 0 && translatedText.substr(translatedText.length() - 1, 1) == "\n") {
                    translatedText = translatedText.substr(0, translatedText.length() - 1);
                }
            }
            if (!isFailureTranslation && (DstLang == "fa" || DstLang == "ar" || DstLang == "he")) {
                string UNICODE_RLE = "\u202B";
                translatedText = UNICODE_RLE + translatedText;
            }
            SrcLang = "UTF8";
            DstLang = "UTF8";
            return translatedText.Trim();
        } else if (Root.isObject() &&
                   Root["error"].isObject() &&
                   Root["error"]["message"].isString()) {
            string errorMessage = Root["error"]["message"].asString();
            HostPrintUTF8("API Error: " + errorMessage + "\n");
             // Retry on API error? Yes, per Unified Loop logic
            attempts++;
            continue;
        } else {
             // Unknown format
            HostPrintUTF8("Translation failed. Unknown response format.\n");
            attempts++;
            continue;
        }
    }

    if (response == "") {
        string failureMessage = "Translation request failed. Please check network connection or API Key.";
        HostPrintUTF8(failureMessage + "\n");
        return FormatFailureTranslation("", failureMessage);
    }
    
    // Fallback for when loop exhausts but we have a response (usually means parsing failed repeatedly or error returned repeatedly)
    return FormatFailureTranslation(response, "Translation failed after retries.");
}

string FormatFailureTranslation(const string &in rawResponse, const string &in fallbackMessage) {
    string detail = rawResponse.Trim();
    if (detail == "")
        detail = fallbackMessage;
    return GPT_WC_TRANSLATION_FAILURE_WARNING_PREFIX + detail;
}

// Plugin Initialization
void OnInitialize() {
    HostPrintUTF8("ChatGPT translation plugin loaded.\n");
    RefreshConfiguration();
    if (GPT_api_key != "") {
        HostPrintUTF8("Saved API Key, model name, and API URL loaded.\n");
    }
}

// Plugin Finalization
void OnFinalize() {
    HostPrintUTF8("ChatGPT translation plugin unloaded.\n");
}

// Share serialization between verification and subtitle translation.
string GPT_WC_BuildChatPayload(
    const string &in modelName,
    const string &in systemMsg,
    const string &in userMsg,
    const string &in thinkingMode
) {
    string payload = "{\"model\":\"" + JsonEscape(modelName) + "\"";
    payload += GPT_WC_BuildThinkingFields(thinkingMode);
    payload += ",\"messages\":[{\"role\":\"system\",\"content\":\"" + JsonEscape(systemMsg) + "\"},";
    payload += "{\"role\":\"user\",\"content\":\"" + JsonEscape(userMsg) + "\"}]}";
    return payload;
}
