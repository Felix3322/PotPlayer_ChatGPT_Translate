// Only the PotPlayer boundary is replaced. Production script source is compiled
// intact. JSON fixtures model response shapes; Python validates request JSON.
array<string> TestKeys;
array<string> TestValues;
array<string> TestUrls;
array<string> TestHeaders;
array<string> TestPayloads;
array<string> TestResponses;
uint TestResponseIndex = 0;
string TestFilterFile;
bool TestFilterExists = false;
string HostGetScriptFolder() { return "C:\\PotPlayer\\Extension\\Subtitle\\Translate"; }
uintptr HostFileOpen(const string &in path) {
    Check(path == HostGetScriptFolder() + "\\ChatGPT-subtitle-filter.txt", "filter file path");
    return TestFilterExists ? 1 : 0;
}
int64 HostFileLength(uintptr file) { return int64(TestFilterFile.length()); }
string HostFileRead(uintptr file, int len) { return TestFilterFile.substr(0, len); }
void HostFileClose(uintptr file) {}

string HostLoadString(const string &in key, const string &in fallback) {
    for (uint i = 0; i < TestKeys.length(); i++)
        if (TestKeys[i] == key) return TestValues[i];
    return fallback;
}
void HostSaveString(const string &in key, const string &in value) {
    for (uint i = 0; i < TestKeys.length(); i++) {
        if (TestKeys[i] == key) { TestValues[i] = value; return; }
    }
    TestKeys.insertLast(key);
    TestValues.insertLast(value);
}
void HostPrintUTF8(const string &in text) {}
void HostSleep(int milliseconds) {}
string HostUrlGetString(const string &in url, const string &in agent,
                        const string &in headers, const string &in payload) {
    TestUrls.insertLast(url);
    TestHeaders.insertLast(headers);
    TestPayloads.insertLast(payload);
    Check(TestUrls.length() < 20, "unexpected unbounded request loop");
    if (TestResponseIndex < TestResponses.length())
        return TestResponses[TestResponseIndex++];
    return "";
}
void ResetHost() {
    TestKeys.resize(0); TestValues.resize(0);
    TestFilterFile = ""; TestFilterExists = false;
    ResetRequests();
}
void ResetRequests() {
    TestUrls.resize(0); TestHeaders.resize(0); TestPayloads.resize(0);
    TestResponses.resize(0); TestResponseIndex = 0;
}

class JsonValue {
    string fixture;
    string path;
    JsonValue() {}
    JsonValue(const string &in f, const string &in p) { fixture = f; path = p; }
    JsonValue opIndex(const string &in key) const { return JsonValue(fixture, path + "/" + key); }
    JsonValue opIndex(int index) const { return JsonValue(fixture, path + "/" + index); }
    bool isObject() const {
        if (path == "") return true;
        if (fixture == "CHAT_OK") return path == "/choices/0" || path == "/choices/0/message";
        if (fixture == "RESPONSES_OK") return path == "/output/0" || path == "/output/0/content/0";
        if (fixture == "ERROR" || fixture == "CACHE_ERROR") return path == "/error";
        return false;
    }
    bool isArray() const {
        return (fixture == "CHAT_OK" && path == "/choices") ||
               (fixture == "RESPONSES_OK" && (path == "/output" || path == "/output/0/content"));
    }
    int size() const { return isArray() ? 1 : 0; }
    bool isString() const {
        return (fixture == "CHAT_OK" && path == "/choices/0/message/content") ||
               (fixture == "RESPONSES_OK" && (path == "/output/0/content/0/type" || path == "/output/0/content/0/text")) ||
               ((fixture == "ERROR" || fixture == "CACHE_ERROR") && path == "/error/message");
    }
    string asString() const {
        if (path == "/output/0/content/0/type") return "output_text";
        if (fixture == "ERROR" && path == "/error/message") return "mock provider rejected request";
        if (fixture == "CACHE_ERROR" && path == "/error/message") return "prompt_cache_key is unsupported";
        return isString() ? "Translated" : "";
    }
    bool isInt() const { return false; }
    int asInt() const { return 0; }
}
class JsonReader {
    bool parse(const string &in text, JsonValue &out value) {
        if (text != "CHAT_OK" && text != "RESPONSES_OK" && text != "ERROR" && text != "CACHE_ERROR" && text != "{}") return false;
        value = JsonValue(text, "");
        return true;
    }
}
