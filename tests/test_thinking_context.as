string TestPrefix() { return "gpt_"; }
string NormalizeMode(const string &in mode) { return GPT_CTX_NormalizeThinkingMode(mode); }
string ChatPayload(const string &in model, const string &in system, const string &in user, const string &in mode) {
    return BuildChatPayload(model, system, user, false, "", "", false, "", mode);
}
void ResetVariant() {
    GPT_subtitleHistory.resize(0);
    GPT_context_cache_disabled_for_session = false;
    GPT_context_cache_disable_key = "";
}
void TestVariant() {
    Fresh();
    GPT_remove_substrings.insertLast("private ");
    GPT_remove_exact_subtitles.insertLast("omit");
    string srcFilter = "en", dstFilter = "fr";
    Check(Translate("omit", srcFilter, dstFilter) == "", "excluded subtitle skipped");
    TestResponses.insertLast("CHAT_OK");
    Translate("private first", srcFilter, dstFilter);
    TestResponses.insertLast("CHAT_OK");
    Translate("second", srcFilter, dstFilter);
    Check(TestPayloads[1].find("first") != -1 && TestPayloads[1].find("private") == -1 && TestPayloads[1].find("omit") == -1, "history contains only filtered text");
    GPT_remove_substrings.resize(0);
    GPT_remove_exact_subtitles.resize(0);
    // Check coexistence with all existing cache metadata and JSON escaping.
    array<string> modes = {"auto", "disabled", "enabled"};
    for (uint i = 0; i < modes.length(); i++) {
        RecordPayload(BuildChatPayload("model", "System", "Text", true, "cache-key", "24h", true, "cachedContents/example", modes[i]), "chat_cache", modes[i]);
        RecordPayload(BuildResponsesPayload("model", "System", "Text", "cache-key", "24h", modes[i]), "responses_cache", modes[i]);
    }
    RecordPayload(BuildResponsesPayload("model\"/\\", "line1\nline2\t\"\\/", "text\r\n\"\\/", "", "", "disabled"), "responses_escaped", "disabled");

    // Actual Translate -> Responses path, including active saved setting.
    for (uint i = 0; i < modes.length(); i++) {
        Fresh(modes[i]);
        HostSaveString("gpt_context_cache_mode", "auto");
        TestResponses.insertLast("RESPONSES_OK");
        string src = "en", dst = "fr";
        Check(Translate("Hello", src, dst) == "Translated", "Responses translation succeeds");
        Check(TestUrls.length() == 1 && TestUrls[0] == "https://provider.example/v1/responses", "Responses endpoint used");
        AssertRequest(0, modes[i], "responses");
    }

    // Responses rejection falls back to chat, with the explicit mode intact.
    Fresh("disabled");
    HostSaveString("gpt_context_cache_mode", "auto");
    TestResponses.insertLast("ERROR"); TestResponses.insertLast("CHAT_OK");
    string src = "en", dst = "fr";
    Check(Translate("Hello", src, dst) == "Translated", "Responses failure falls back to chat");
    Check(TestUrls.length() == 2, "Responses fallback request count");
    AssertRequest(0, "disabled", "responses");
    AssertRequest(1, "disabled");

    // Rebuilding payload after a cache-field error must preserve thinking mode.
    Fresh("disabled");
    HostSaveString("gpt_apiUrl", "https://api.openai.com/v1/chat/completions");
    HostSaveString("gpt_retry_mode", "1");
    HostSaveString("gpt_prompt_cache_retention", "24h");
    TestResponses.insertLast("CACHE_ERROR"); TestResponses.insertLast("CHAT_OK");
    src = "en"; dst = "fr";
    Check(Translate("Hello", src, dst) == "Translated", "cache-field error recovers");
    Check(TestUrls.length() == 2, "cache-field retry request count");
    AssertRequest(0, "disabled", "chat_has_cache");
    AssertRequest(1, "disabled", "chat_no_cache");

    Fresh("auto");
    HostSaveString("wc_thinking_mode", "disabled");
    RefreshConfiguration();
    AssertMode("auto");
    Check(HostLoadString("wc_thinking_mode", "") == "disabled", "variants keep independent settings");
}
