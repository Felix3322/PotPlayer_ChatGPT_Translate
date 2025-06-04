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

string GetVersion() {
    return "1.5.2-wc";
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
    return "{$CP949=모델 이름과 API 주소, 그리고 API 키를 입력하십시오 (예: gpt-4.1-mini|https://api.openai.com/v1/chat/completions).$}"
         + "{$CP950=請輸入模型名稱與 API 地址，以及 API 金鑰（例如: gpt-4.1-mini|https://api.openai.com/v1/chat/completions）。$}"
         + "{$CP936=请输入模型名称和 API 地址，以及 API 密钥（例如: gpt-4.1-mini|https://api.openai.com/v1/chat/completions）。$}"
         + "{$CP0=Please enter the model name + API URL and provide the API Key (e.g., gpt-4.1-mini|https://api.openai.com/v1/chat/completions).$}";
}

string GetUserText() {
    return "{$CP949=모델 이름|API 주소 (현재: " + selected_model + " | " + apiUrl + ")$}"
         + "{$CP950=模型名稱|API 地址 (目前: " + selected_model + " | " + apiUrl + ")$}"
         + "{$CP936=模型名称|API 地址 (目前: " + selected_model + " | " + apiUrl + ")$}"
         + "{$CP0=Model Name|API URL (Current: " + selected_model + " | " + apiUrl + ")$}";
}

string GetPasswordText() {
    return "{$CP949=API 키:$}"
         + "{$CP950=API 金鑰:$}"
         + "{$CP936=API 密钥:$}"
         + "{$CP0=API Key:$}";
}

// Global Variables
// Pre-configured values (auto-filled by installer)
string pre_api_key = ""; // will be replaced during installation
string pre_selected_model = "gpt-4.1-mini"; // will be replaced during installation
string pre_apiUrl = "https://api.openai.com/v1/chat/completions"; // will be replaced during installation

string api_key = pre_api_key;
string selected_model = pre_selected_model; // Default model
string apiUrl = pre_apiUrl; // Default API URL
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";

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

// API Key and API Base verification process
string ServerLogin(string User, string Pass) {
    string errorAccum = "";
    User = User.Trim();
    Pass = Pass.Trim();
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
    bool allowNullApiKey = false;
    if (tokens.length() >= 1) {
        userModel = tokens[0];
    }
    if (tokens.length() >= 2) {
        if (tokens[1] == "nullkey")
            allowNullApiKey = true;
        else
            customApiUrl = tokens[1];
    }
    if (tokens.length() >= 3) {
        if (tokens[2] == "nullkey")
            allowNullApiKey = true;
    }
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
        apiUrlLocal = pre_apiUrl;
    }
    if (!allowNullApiKey && Pass == "") {
        errorAccum += "API Key not configured. Please enter a valid API Key.\n";
        return errorAccum;
    }
    bool isOfficial = (apiUrlLocal.find("api.openai.com") != -1);
    string verifyHeaders = "Authorization: Bearer " + Pass + "\nContent-Type: application/json";
    string testSystemMsg = "You are a test assistant.";
    string testUserMsg = "Hello";
    string escapedTestSystemMsg = JsonEscape(testSystemMsg);
    string escapedTestUserMsg = JsonEscape(testUserMsg);
    string testRequestData = "{\"model\":\"" + userModel + "\","
                             "\"messages\":[{\"role\":\"system\",\"content\":\"" + escapedTestSystemMsg + "\"},"
                             "{\"role\":\"user\",\"content\":\"" + escapedTestUserMsg + "\"}],"
                             "\"max_tokens\":1,\"temperature\":0}";
    string testResponse = HostUrlGetString(apiUrlLocal, UserAgent, verifyHeaders, testRequestData);
    if (testResponse != "") {
        JsonReader testReader;
        JsonValue testRoot;
        if (testReader.parse(testResponse, testRoot)) {
            if (testRoot.isObject() && testRoot["choices"].isArray() && testRoot["choices"].size() > 0) {
                selected_model = userModel;
                api_key = Pass;
                HostSaveString("wc_api_key", api_key);
                HostSaveString("wc_selected_model", selected_model);
                HostSaveString("wc_apiUrl", apiUrlLocal);
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
        string correctedTestResponse = HostUrlGetString(correctedApiUrl, UserAgent, verifyHeaders, testRequestData);
        if (correctedTestResponse != "") {
            JsonReader correctedReader;
            JsonValue correctedRoot;
            if (correctedReader.parse(correctedTestResponse, correctedRoot)) {
                if (correctedRoot.isObject() && correctedRoot["choices"].isArray() && correctedRoot["choices"].size() > 0) {
                    apiUrlLocal = correctedApiUrl;
                    selected_model = userModel;
                    api_key = Pass;
                    HostSaveString("wc_api_key", api_key);
                    HostSaveString("wc_selected_model", selected_model);
                    HostSaveString("wc_apiUrl", apiUrlLocal);
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
        string verifyResponse = HostUrlGetString(verifyUrl, UserAgent, verifyHeaders, "");
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
    api_key = "";
    selected_model = pre_selected_model;
    apiUrl = pre_apiUrl;
    HostSaveString("wc_api_key", "");
    HostSaveString("wc_selected_model", selected_model);
    HostSaveString("wc_apiUrl", apiUrl);
    HostPrintUTF8("Successfully logged out.\n");
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
    if (modelName == "gpt-3.5-turbo")
        return 4096;
    else if (modelName == "gpt-3.5-turbo-16k")
        return 16384;
    else if (modelName == "gpt-4o")
        return 128000;
    else if (modelName == "gpt-4.1-mini")
        return 128000;
    else
        return 4096;
}

// Translation Function (Without Context Support)
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    api_key = HostLoadString("wc_api_key", api_key);
    selected_model = HostLoadString("wc_selected_model", selected_model);
    apiUrl = HostLoadString("wc_apiUrl", apiUrl);

    if (api_key == "") {
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

    string systemMsg = "You are a professional subtitle translate tool. Do not output any explanatory text or extra context.";
    string userMsg = "You are an expert subtitle translate tool with a deep understanding of both language and culture. Do not output any explanatory text or extra context. Translate the following subtitle from " + (SrcLang == "" ? "Auto Detect" : SrcLang) + " to " + DstLang + ":\n" + Text;

    string escapedSystemMsg = JsonEscape(systemMsg);
    string escapedUserMsg = JsonEscape(userMsg);

    string requestData = "{\"model\":\"" + selected_model + "\","
                         "\"messages\":[{\"role\":\"system\",\"content\":\"" + escapedSystemMsg + "\"},"
                         "{\"role\":\"user\",\"content\":\"" + escapedUserMsg + "\"}],"
                         "\"max_tokens\":1000,\"temperature\":0}";

    string headers = "Authorization: Bearer " + api_key + "\nContent-Type: application/json";

    string response = HostUrlGetString(apiUrl, UserAgent, headers, requestData);
    if (response == "") {
        HostPrintUTF8("Translation request failed. Please check network connection or API Key.\n");
        return "";
    }

    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        HostPrintUTF8("Failed to parse API response.\n");
        return "";
    }

    JsonValue choices = Root["choices"];
    if (choices.isArray() && choices.size() > 0 &&
        choices[0].isObject() &&
        choices[0]["message"].isObject() &&
        choices[0]["message"]["content"].isString()) {
        string translatedText = choices[0]["message"]["content"].asString();
        if (selected_model.find("gemini") != -1) {
            while (translatedText.length() > 0 && translatedText.substr(translatedText.length() - 1, 1) == "\n") {
                translatedText = translatedText.substr(0, translatedText.length() - 1);
            }
        }
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            string UNICODE_RLE = "\u202B";
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText.Trim();
    }

    if (Root.isObject() &&
        Root["error"].isObject() &&
        Root["error"]["message"].isString()) {
        string errorMessage = Root["error"]["message"].asString();
        HostPrintUTF8("API Error: " + errorMessage + "\n");
        return "API Error: " + errorMessage;
    } else {
        HostPrintUTF8("Translation failed. Please check input parameters or API Key configuration.\n");
        return "Translation failed. Please check input parameters or API Key configuration.";
    }
}

// Plugin Initialization
void OnInitialize() {
    HostPrintUTF8("ChatGPT translation plugin loaded.\n");
    api_key = HostLoadString("wc_api_key", api_key);
    selected_model = HostLoadString("wc_selected_model", selected_model);
    apiUrl = HostLoadString("wc_apiUrl", apiUrl);
    if (api_key != "") {
        HostPrintUTF8("Saved API Key, model name, and API URL loaded.\n");
    }
}

// Plugin Finalization
void OnFinalize() {
    HostPrintUTF8("ChatGPT translation plugin unloaded.\n");
}
