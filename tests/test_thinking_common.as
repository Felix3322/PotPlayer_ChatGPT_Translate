const string TEST_URL = "https://provider.example/v1/chat/completions";

void Fresh(const string &in mode = "auto") {
    ResetHost();
    HostSaveString(TestPrefix() + "thinking_mode", mode);
    HostSaveString(TestPrefix() + "api_key", "nullkey");
    HostSaveString(TestPrefix() + "apiUrl", TEST_URL);
    HostSaveString(TestPrefix() + "selected_model", "deepseek-flash");
    HostSaveString(TestPrefix() + "context_cache_mode", "off");
    HostSaveString(TestPrefix() + "retry_mode", "0");
    HostSaveString(TestPrefix() + "delay_ms", "0");
    RefreshConfiguration();
    ResetVariant();
}
void AssertMode(const string &in expected) {
    Check(GPT_thinking_mode == expected, "active thinking mode: " + expected);
    Check(HostLoadString(TestPrefix() + "thinking_mode", "MISSING") == expected, "saved thinking mode: " + expected);
}
void AssertRequest(uint index, const string &in expected, const string &in kind = "chat") {
    Check(index < TestPayloads.length(), "request exists");
    RecordPayload(TestPayloads[index], kind, expected);
}
void TestNormalizationAndBuilders() {
    Check(NormalizeMode("auto") == "auto", "normalize auto");
    Check(NormalizeMode(" ENABLED ") == "enabled", "case-insensitive enabled");
    Check(NormalizeMode("\tDiSaBlEd\r\n") == "disabled", "trim disabled");
    Check(NormalizeMode("") == "", "empty is invalid");
    Check(NormalizeMode("true") == "", "boolean is invalid");
    Check(NormalizeMode("off") == "", "off is not a supported value");
    Check(NormalizeMode("disabledx") == "", "reject partial match");
    array<string> modes = {"auto", "enabled", "disabled", "invalid", ""};
    for (uint i = 0; i < modes.length(); i++) {
        string expected = (modes[i] == "enabled" || modes[i] == "disabled") ? modes[i] : "auto";
        RecordPayload(ChatPayload("deepseek-v4-pro", "System", "Text", modes[i]), "chat", expected);
    }
    RecordPayload(ChatPayload("model\"/\\", "line1\nline2\t\"\\/", "text\r\n\"\\/", "disabled"), "chat_escaped", "disabled");
}
void TestDefaultsAndRefresh() {
    ResetHost();
    RefreshConfiguration();
    AssertMode("auto");
    HostSaveString(TestPrefix() + "thinking_mode", " DISABLED ");
    RefreshConfiguration();
    Check(GPT_thinking_mode == "disabled", "normalize persisted setting");
    HostSaveString(TestPrefix() + "thinking_mode", "invalid-old-value");
    RefreshConfiguration();
    RecordPayload(ChatPayload("deepseek-v4-pro", "System", "Text", GPT_thinking_mode), "chat", "auto");
}
void TestLoginSuccessAndTranslation() {
    Fresh();
    TestResponses.insertLast("CHAT_OK");
    // Exercise option before URL, whitespace/case, and existing options together.
    string result = ServerLogin("deepseek-flash| ThInKiNg= DiSaBlEd |" + TEST_URL + "|nullkey|0|retry0|smallmodel=1|hallucination=0", "nullkey");
    Check(result == "200 ok", "login with thinking=disabled succeeds");
    Check(TestUrls.length() == 1 && TestUrls[0] == TEST_URL, "thinking token is not interpreted as URL");
    AssertMode("disabled");
    AssertRequest(0, "disabled");
    Check(TestHeaders[0].find("Authorization") == -1, "nullkey remains keyless");
    GPT_thinking_mode = "auto";
    RefreshConfiguration();
    AssertMode("disabled");
    ResetRequests();
    TestResponses.insertLast("CHAT_OK");
    string src = "en", dst = "fr";
    Check(Translate("Hello", src, dst) == "Translated", "translation succeeds");
    Check(TestUrls.length() == 1, "one translation request");
    AssertRequest(0, "disabled");

    ResetRequests();
    TestResponses.insertLast("CHAT_OK");
    result = ServerLogin("other-model|" + TEST_URL + "|thinking=enabled", "nullkey");
    Check(result == "200 ok", "login with thinking=enabled succeeds");
    AssertMode("enabled");
    AssertRequest(0, "enabled");

    ResetRequests();
    TestResponses.insertLast("CHAT_OK");
    result = ServerLogin("deepseek-v4-pro|" + TEST_URL, "nullkey");
    Check(result == "200 ok", "login without option succeeds");
    AssertMode("auto");
    AssertRequest(0, "auto");
    ResetRequests();
    TestResponses.insertLast("CHAT_OK");
    src = "en"; dst = "fr";
    Check(Translate("Hello", src, dst) == "Translated", "auto translation succeeds");
    AssertRequest(0, "auto");
}
void TestFailedAndInvalidLogin() {
    Fresh("disabled");
    TestResponses.insertLast("ERROR");
    string result = ServerLogin("changed-model|" + TEST_URL + "|thinking=enabled", "nullkey");
    Check(result.find("200 ok") == -1, "provider rejection fails login");
    AssertRequest(0, "enabled");
    AssertMode("disabled");
    RefreshConfiguration();
    AssertMode("disabled");
    ResetRequests();
    TestResponses.insertLast("not-json");
    result = ServerLogin("changed-model|" + TEST_URL + "|thinking=enabled", "nullkey");
    Check(result.find("200 ok") == -1, "malformed provider response fails login");
    AssertMode("disabled");
    ResetRequests();
    TestResponses.insertLast(""); TestResponses.insertLast("ERROR");
    result = ServerLogin("changed-model|https://provider.example/v1|thinking=enabled", "nullkey");
    Check(result.find("200 ok") == -1, "failed corrected endpoint fails login");
    Check(TestUrls.length() == 2, "failed correction sends two requests");
    AssertRequest(0, "enabled"); AssertRequest(1, "enabled");
    AssertMode("disabled");
    array<string> invalid = {"", "true", "off", "disabledx", "enabled disabled"};
    for (uint i = 0; i < invalid.length(); i++) {
        ResetRequests();
        result = ServerLogin("model|thinking=" + invalid[i] + "|" + TEST_URL, "nullkey");
        Check(result.find("Invalid thinking mode") != -1, "invalid option reports error: " + invalid[i]);
        Check(TestUrls.length() == 0, "invalid option makes no request");
        AssertMode("disabled");
    }
    ResetRequests();
    TestResponses.insertLast("CHAT_OK");
    result = ServerLogin("model|" + TEST_URL + "|thinking=auto", "nullkey");
    Check(result == "200 ok", "explicit auto login succeeds");
    AssertMode("auto");
    AssertRequest(0, "auto");
}
void TestCorrectedEndpointAndLogout() {
    Fresh();
    TestResponses.insertLast("");
    TestResponses.insertLast("CHAT_OK");
    string result = ServerLogin("deepseek-flash|https://provider.example/v1/|thinking=disabled", "nullkey");
    Check(result.find("200 ok") != -1, "corrected endpoint succeeds");
    Check(TestUrls.length() == 2, "auto-correction sends two requests");
    Check(TestUrls[0] == "https://provider.example/v1", "first endpoint has trailing slash removed");
    Check(TestUrls[1] == TEST_URL, "corrected endpoint appends chat/completions");
    Check(HostLoadString(TestPrefix() + "apiUrl", "") == TEST_URL, "corrected endpoint persisted");
    AssertRequest(0, "disabled");
    AssertRequest(1, "disabled");
    AssertMode("disabled");
    ServerLogout();
    AssertMode("auto");
    Check(HostLoadString(TestPrefix() + "api_key", "MISSING") == "", "logout clears API key");
    RefreshConfiguration();
    AssertMode("auto");
}
void TestSubtitleFilter() {
    Fresh();
    GPT_remove_substrings.insertLast("my name is");
    GPT_remove_substrings.insertLast("");
    GPT_remove_exact_subtitles.insertLast("skip this");
    GPT_remove_exact_subtitles.insertLast("");
    Check(FilterSubtitle("my name is li si") == "li si", "remove substring");
    Check(FilterSubtitle("my name is my name is li si") == "li si", "remove repeated substrings");
    Check(FilterSubtitle("  skip this  ") == "", "exact subtitle ignores outer whitespace");
    Check(FilterSubtitle("skip this too") == "skip this too", "exact rule does not remove partial match");
    Check(FilterSubtitle("My name is li si") == "My name is li si", "matching is case sensitive");
    string src = "en", dst = "fr";
    Check(Translate("skip this", src, dst) == "", "exact match returns empty");
    Check(Translate("my name is", src, dst) == "", "fully removed text returns empty");
    Check(TestUrls.length() == 0, "empty result does not call API");
    TestResponses.insertLast("CHAT_OK");
    Check(Translate("my name is li si", src, dst) == "Translated", "filtered subtitle translates");
    Check(TestPayloads[0].find("li si") != -1 && TestPayloads[0].find("my name is") == -1, "request contains only filtered text");
    GPT_remove_substrings.resize(0);
    GPT_remove_exact_subtitles.resize(0);
}

void Main() {
    TestNormalizationAndBuilders();
    TestDefaultsAndRefresh();
    TestLoginSuccessAndTranslation();
    TestFailedAndInvalidLogin();
    TestCorrectedEndpointAndLogout();
    TestSubtitleFilter();
    TestVariant();
}
