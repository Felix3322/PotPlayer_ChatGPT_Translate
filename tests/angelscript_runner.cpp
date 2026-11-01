// Small runtime adapter for the PotPlayer script regression tests.
// Uses the official AngelScript SDK; no requests leave this process.
#include <angelscript.h>
#include "scriptstdstring.h"
#include "scriptarray.h"
#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>

static void Message(const asSMessageInfo *m, void *) {
    std::cerr << m->section << ':' << m->row << ':' << m->col << ": " << m->message << '\n';
}
static std::string Trim(const std::string &s) {
    const auto first = s.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return "";
    return s.substr(first, s.find_last_not_of(" \t\r\n") - first + 1);
}
static std::string Lower(const std::string &s) {
    std::string out = s;
    for (auto &c : out) c = char(std::tolower(static_cast<unsigned char>(c)));
    return out;
}
static int Find(const std::string &part, int start, const std::string &s) {
    const auto at = s.find(part, size_t(std::max(0, start)));
    return at == std::string::npos ? -1 : int(at);
}
static void Replace(const std::string &from, const std::string &to, std::string &s) {
    if (from.empty()) return;
    size_t at = 0;
    while ((at = s.find(from, at)) != std::string::npos) {
        s.replace(at, from.size(), to);
        at += to.size();
    }
}
static int assertions = 0;
static void Check(bool ok, const std::string &label) {
    ++assertions;
    if (!ok) asGetActiveContext()->SetException(("Assertion failed: " + label).c_str());
}
static void Payload(const std::string &payload, const std::string &kind, const std::string &mode) {
    // Payload JSON escapes embedded newlines, so a tab-separated line is safe.
    std::cout << "PAYLOAD\t" << kind << '\t' << mode << '\t' << payload << '\n';
}
static std::string Read(const char *path) {
    std::ifstream f(path);
    if (!f) throw std::runtime_error(std::string("Cannot open ") + path);
    std::ostringstream text;
    text << f.rdbuf();
    return text.str();
}
static void Register(asIScriptEngine *engine, int result) {
    if (result < 0) throw std::runtime_error("AngelScript adapter registration failed: " + std::to_string(result));
}
int main(int argc, char **argv) {
    if (argc < 4) {
        std::cerr << "Usage: angelscript_runner SCRIPT HOST_STUB TEST [TEST ...]\n";
        return 2;
    }
    asIScriptEngine *engine = asCreateScriptEngine();
    engine->SetMessageCallback(asFUNCTION(Message), nullptr, asCALL_CDECL);
    RegisterStdString(engine);
    RegisterScriptArray(engine, true);
    Register(engine, engine->RegisterTypedef("uintptr", "uint64"));
    Register(engine, engine->RegisterObjectMethod("string", "string Trim() const", asFUNCTION(Trim), asCALL_CDECL_OBJLAST));
    Register(engine, engine->RegisterObjectMethod("string", "string MakeLower() const", asFUNCTION(Lower), asCALL_CDECL_OBJLAST));
    Register(engine, engine->RegisterObjectMethod("string", "int find(const string &in, int start = 0) const", asFUNCTION(Find), asCALL_CDECL_OBJLAST));
    Register(engine, engine->RegisterObjectMethod("string", "void replace(const string &in, const string &in)", asFUNCTION(Replace), asCALL_CDECL_OBJLAST));
    Register(engine, engine->RegisterGlobalFunction("void Check(bool, const string &in)", asFUNCTION(Check), asCALL_CDECL));
    Register(engine, engine->RegisterGlobalFunction("void RecordPayload(const string &in, const string &in, const string &in)", asFUNCTION(Payload), asCALL_CDECL));
    asIScriptModule *module = engine->GetModule("tests", asGM_ALWAYS_CREATE);
    try {
        for (int i = 1; i < argc; ++i) {
            const auto text = Read(argv[i]);
            module->AddScriptSection(argv[i], text.c_str(), text.size());
        }
        if (module->Build() < 0) return 1;
        auto context = engine->CreateContext();
        auto main = module->GetFunctionByDecl("void Main()");
        if (!main) throw std::runtime_error("Missing test Main()");
        context->Prepare(main);
        const int result = context->Execute();
        if (result != asEXECUTION_FINISHED) {
            std::cerr << "Execution failed: " << context->GetExceptionString() << '\n';
            for (asUINT i = 0; i < context->GetCallstackSize(); ++i) {
                auto function = context->GetFunction(i);
                std::cerr << "  " << (function ? function->GetDeclaration() : "?")
                          << ':' << context->GetLineNumber(i) << '\n';
            }
            context->Release();
            engine->ShutDownAndRelease();
            return 1;
        }
        context->Release();
        std::cout << "PASS " << assertions << " AngelScript assertions\n";
        engine->ShutDownAndRelease();
    } catch (const std::exception &e) {
        std::cerr << e.what() << '\n';
        engine->ShutDownAndRelease();
        return 1;
    }
    return 0;
}
