#define MyAppName "PotPlayer ChatGPT Translate"
#ifndef PluginVersion
  #define PluginVersion "dev"
#endif
#ifndef PluginNumericVersion
  #define PluginNumericVersion "0.0.0"
#endif

[Setup]
AppId={code:GetDynamicAppId}
AppName={#MyAppName}
AppVersion={#PluginVersion}
AppVerName={#MyAppName} {#PluginVersion}
AppPublisher=Felix3322
VersionInfoProductName={#MyAppName}
VersionInfoVersion={#PluginNumericVersion}
VersionInfoProductVersion={#PluginNumericVersion}
VersionInfoProductTextVersion={#PluginVersion}
VersionInfoTextVersion={#PluginVersion}
AppPublisherURL=https://github.com/Felix3322/PotPlayer_ChatGPT_Translate
DefaultDirName={code:GetDefaultInstallDir}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
OutputDir=..\releases\latest
OutputBaseFilename=installer
SetupIconFile=..\icon.ico
PrivilegesRequired=admin
UninstallFilesDir={commonappdata}\PotPlayer ChatGPT Translate\Uninstall
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
UsePreviousAppDir=no
DirExistsWarning=no
ArchitecturesAllowed=x86 x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupLogging=yes
UninstallDisplayName={code:GetDynamicUninstallDisplayName}
UsePreviousLanguage=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "zh"; MessagesFile: ".\ChineseSimplified.isl"

[CustomMessages]
en.WelcomeBody=Welcome to the PotPlayer ChatGPT Translate Installer (v{#PluginVersion}). This installer detects the PotPlayer subtitle translation folder, lets you choose one plugin variant, writes API-related defaults into the plugin script, and creates a standard uninstaller entry for the selected variant in the selected folder.
zh.WelcomeBody=欢迎使用 PotPlayer ChatGPT 翻译安装程序 (v{#PluginVersion})。该安装器会尝试识别 PotPlayer 字幕翻译目录，让你选择一个插件变体，将 API 相关默认值写入插件脚本，并为所选目录中的该变体创建标准卸载入口。
en.VariantTitle=Choose Plugin Variant
zh.VariantTitle=选择插件变体
en.VariantDescription=Select the plugin variant to install. Re-running the installer for the same folder with the other variant keeps the current variant and adds a separate uninstall entry.
zh.VariantDescription=选择要安装的插件变体。若之后对同一目录安装另一个变体，当前变体会保留，并新增独立的卸载入口。
en.WithContext=With context handling
zh.WithContext=带上下文处理
en.WithoutContext=Without context handling
zh.WithoutContext=不带上下文处理
en.VariantWarning=Please choose a plugin variant.
zh.VariantWarning=请选择一个插件变体。
en.ConfigTitle=API Settings
zh.ConfigTitle=API 设置
en.ConfigDescription=Choose a preset or customize the model, endpoint and key. Clicking Next on this page will verify the settings and continue. Use the skip button below if you want to continue without verification. Leave the key blank only if your endpoint allows empty-key requests.
zh.ConfigDescription=选择预设，或自行修改模型、接口地址和 Key。此页点击“下一步”会先验证再继续。如需不验证直接继续，请使用下方的跳过按钮。只有你的接口允许空 Key 请求时才应留空。
en.PresetLabel=Preset:
zh.PresetLabel=预设：
en.ModelLabel=Model:
zh.ModelLabel=模型：
en.ApiUrlLabel=API URL:
zh.ApiUrlLabel=API 地址：
en.ApiKeyLabel=API Key:
zh.ApiKeyLabel=API Key：
en.SmallModelLabel=Enable small model mode
zh.SmallModelLabel=启用小模型模式
en.VerifyAndContinueButton=Verify and Continue
zh.VerifyAndContinueButton=验证并继续
en.SkipVerifyButton=Skip Verification and Continue
zh.SkipVerifyButton=跳过验证并继续
en.PurchaseButton=Open Billing / Recharge Page
zh.PurchaseButton=打开购买 / 充值页面
en.VerifyIdle=Verification has not been run yet.
zh.VerifyIdle=尚未执行验证。
en.VerifyRunning=Verifying API settings...
zh.VerifyRunning=正在验证 API 设置...
en.VerifySuccess=Verification passed.
zh.VerifySuccess=验证通过。
en.VerifyEmptySuccess=Empty key verified. The installer will write nullkey.
zh.VerifyEmptySuccess=空 Key 验证通过。安装器将写入 nullkey。
en.VerifyFailed=API verification failed:
zh.VerifyFailed=API验证失败：
en.DelayTitle=Request Delay
zh.DelayTitle=请求延迟
en.DelayDescription=Set the delay between API requests in milliseconds.
zh.DelayDescription=设置 API 请求之间的延迟（毫秒）。
en.DelayLabel=Delay (ms):
zh.DelayLabel=延迟（毫秒）：
en.RetryTitle=Retry Mode
zh.RetryTitle=重试模式
en.RetryDescription=Choose how the plugin retries failed requests.
zh.RetryDescription=选择插件在请求失败时的重试方式。
en.RetryOff=Off
zh.RetryOff=关闭
en.RetryOnce=Retry once immediately
zh.RetryOnce=立即重试一次
en.RetryUntil=Retry until success
zh.RetryUntil=重试直到成功
en.RetryDelayed=Retry until success (delayed)
zh.RetryDelayed=重试直到成功（带间隔）
en.HallucinationTitle=Anti-Hallucination
zh.HallucinationTitle=反幻觉机制
en.HallucinationDescription=Retry translations when the response becomes disproportionately long.
zh.HallucinationDescription=当翻译结果异常偏长时自动重试。
en.HallucinationLabel=Enable anti-hallucination retry
zh.HallucinationLabel=启用反幻觉重试
en.ContextTitle=Context Settings
zh.ContextTitle=上下文设置
en.ContextDescription=These settings apply only to the context-aware plugin.
zh.ContextDescription=这些设置仅作用于带上下文的插件版本。
en.ContextSubtitleCountLabel=Recent subtitle entries:
zh.ContextSubtitleCountLabel=最近字幕条数：
en.ContextSubtitleCountHint=Default is 3. Lower values are faster and reduce timeout risk.
zh.ContextSubtitleCountHint=默认 3 条。数值越小越快，也越不容易超时。
en.ContextCacheLabel=Context cache:
zh.ContextCacheLabel=上下文缓存：
en.ContextCacheAuto=Auto
zh.ContextCacheAuto=自动
en.ContextCacheOff=Off
zh.ContextCacheOff=关闭
en.PromptCacheRetentionLabel=Prompt cache retention:
zh.PromptCacheRetentionLabel=Prompt Cache 保留：
en.GeminiCachedContentLabel=Gemini cached content:
zh.GeminiCachedContentLabel=Gemini cached content：
en.DebugTitle=Debug Mode
zh.DebugTitle=调试模式
en.DebugDescription=Enable HostOpenConsole() in the installed script.
zh.DebugDescription=在安装后的脚本中启用 HostOpenConsole()。
en.DebugLabel=Enable debug console injection
zh.DebugLabel=启用调试控制台注入
en.PathDetected=Detected PotPlayer translate directory:
zh.PathDetected=已识别 PotPlayer 翻译目录：
en.PathNotDetected=PotPlayer was not detected. Install PotPlayer first, then choose the PotPlayer folder containing PotPlayerMini64.exe/PotPlayerMini.exe or its Extension\Subtitle\Translate subfolder.
zh.PathNotDetected=未检测到 PotPlayer。请先安装 PotPlayer，然后选择包含 PotPlayerMini64.exe/PotPlayerMini.exe 的程序目录，或其 Extension\Subtitle\Translate 子目录。
en.InvalidNumber=Please enter a valid non-negative integer.
zh.InvalidNumber=请输入有效的非负整数。
en.EmptyModel=Model cannot be empty.
zh.EmptyModel=模型不能为空。
en.EmptyApiUrl=API URL cannot be empty.
zh.EmptyApiUrl=API 地址不能为空。
en.ChatEndpointRequiredError=Please enter a full /chat/completions endpoint or a known compatible base URL. The installer will automatically convert known base URLs and /responses URLs to the matching /chat/completions endpoint.
zh.ChatEndpointRequiredError=请输入完整的 /chat/completions 端点，或已知的兼容 base URL。安装器会自动把已知 base URL 和 /responses 地址改写为对应的 /chat/completions 端点。
en.OverwritePrompt=The following target files already exist. Overwrite them?
zh.OverwritePrompt=以下目标文件已存在。是否覆盖？
en.InstallFailure=Installation failed:
zh.InstallFailure=安装失败：
en.InstallingVariant=Installing variant:
zh.InstallingVariant=正在安装变体：
en.FinishBody=Installation completed. This installed variant can be removed later using its own uninstaller entry or by deleting the installed files manually.
zh.FinishBody=安装已完成。之后你可以使用该变体对应的卸载入口，或手动删除已安装的插件文件。

[Files]
Source: "..\SubtitleTranslate - ChatGPT.as"; Flags: dontcopy
Source: "..\SubtitleTranslate - ChatGPT.ico"; Flags: dontcopy
Source: "..\SubtitleTranslate - ChatGPT - Without Context.as"; Flags: dontcopy
Source: "..\SubtitleTranslate - ChatGPT - Without Context.ico"; Flags: dontcopy

[UninstallDelete]
Type: files; Name: "{app}\SubtitleTranslate - ChatGPT.as"; Check: ShouldUninstallContextVariant
Type: files; Name: "{app}\SubtitleTranslate - ChatGPT.ico"; Check: ShouldUninstallContextVariant
Type: files; Name: "{app}\SubtitleTranslate - ChatGPT - Without Context.as"; Check: ShouldUninstallWithoutContextVariant
Type: files; Name: "{app}\SubtitleTranslate - ChatGPT - Without Context.ico"; Check: ShouldUninstallWithoutContextVariant

[Code]
type
  TProviderPreset = record
    Key: String;
    Model: String;
    ApiBase: String;
    PurchasePage: String;
    AllowCustomModel: Boolean;
  end;

const
  CP_UTF8 = 65001;
  DRIVE_FIXED = 3;
  TranslateSuffix = '\Extension\Subtitle\Translate';
  SubtitleSuffix = '\Extension\Subtitle';
  CustomPageMarginX = 12;
  CustomPageMarginTop = 12;
  CustomPageLabelGapY = 4;
  CustomPageFieldGapY = 10;
  CustomPageSectionGapY = 12;
  CustomPageButtonGapX = 8;
  CustomPageCheckBoxHeight = 24;

var
  ProviderPresets: array of TProviderPreset;
  VariantPage: TInputOptionWizardPage;
  DelayPage: TInputQueryWizardPage;
  RetryPage: TInputOptionWizardPage;
  HallucinationPage: TInputOptionWizardPage;
  DebugPage: TInputOptionWizardPage;
  ConfigPage: TWizardPage;
  ContextPage: TWizardPage;
  PresetLabel: TNewStaticText;
  PresetCombo: TNewComboBox;
  ModelLabel: TNewStaticText;
  ModelEdit: TNewEdit;
  ApiUrlLabel: TNewStaticText;
  ApiUrlEdit: TNewEdit;
  ApiKeyLabel: TNewStaticText;
  ApiKeyEdit: TPasswordEdit;
  SmallModelCheck: TNewCheckBox;
  SkipVerifyButton: TNewButton;
  PurchaseButton: TNewButton;
  ContextSubtitleCountLabel: TNewStaticText;
  ContextSubtitleCountEdit: TNewEdit;
  ContextSubtitleCountHint: TNewStaticText;
  ContextCacheLabel: TNewStaticText;
  ContextCacheCombo: TNewComboBox;
  PromptCacheRetentionLabel: TNewStaticText;
  PromptCacheRetentionEdit: TNewEdit;
  GeminiCachedContentLabel: TNewStaticText;
  GeminiCachedContentEdit: TNewEdit;
  GeneratedPluginVersion: String;
  GeneratedModelTokenLimitsJson: String;
  VerifiedConfigFingerprint: String;
  SkipVerificationRequested: Boolean;
  LastVariantSelectionSyncDir: String;
  InitialDetectedDir: String;
  LastInstallError: String;

#include "generated\installer_data.iss.inc"

function GetDriveType(lpRootPathName: String): UINT;
  external 'GetDriveTypeW@kernel32.dll stdcall';
function MultiByteToWideChar(CodePage: UINT; dwFlags: DWORD; const lpMultiByteStr: AnsiString;
  cbMultiByte: Integer; lpWideCharStr: String; cchWideChar: Integer): Integer;
  external 'MultiByteToWideChar@kernel32.dll stdcall';
function WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD; lpWideCharStr: String;
  cchWideChar: Integer; lpMultiByteStr: AnsiString; cchMultiByte: Integer;
  lpDefaultChar: Integer; lpUsedDefaultChar: Integer): Integer;
  external 'WideCharToMultiByte@kernel32.dll stdcall';

function GetVariantScriptName(const IsContextVariant: Boolean): String; forward;
function GetVariantIconName(const IsContextVariant: Boolean): String; forward;

function PosFrom(const Needle, Haystack: String; Offset: Integer): Integer;
var
  Found: Integer;
begin
  if Offset <= 1 then
  begin
    Result := Pos(Needle, Haystack);
    exit;
  end;

  Found := Pos(Needle, Copy(Haystack, Offset, MaxInt));
  if Found = 0 then
    Result := 0
  else
    Result := Offset + Found - 1;
end;

function ReplaceAll(const Value, OldPattern, NewPattern: String): String;
begin
  Result := Value;
  StringChangeEx(Result, OldPattern, NewPattern, True);
end;

function StripQuotes(const Value: String): String;
begin
  Result := Trim(Value);
  if (Length(Result) >= 2) and (Result[1] = '"') and (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function EndsWithText(const Value, Suffix: String): Boolean;
begin
  if Length(Value) < Length(Suffix) then
  begin
    Result := False;
    exit;
  end;

  Result := CompareText(Copy(Value, Length(Value) - Length(Suffix) + 1, Length(Suffix)), Suffix) = 0;
end;

function TrimTrailingSlashes(const Value: String): String;
begin
  Result := Trim(Value);
  while (Length(Result) > 0) and (Result[Length(Result)] = '/') do
    Delete(Result, Length(Result), 1);
end;

function DirectoryContainsPotPlayerExecutable(const Dir: String): Boolean;
var
  NormalizedDir: String;
begin
  NormalizedDir := RemoveBackslashUnlessRoot(Trim(Dir));
  Result := FileExists(AddBackslash(NormalizedDir) + 'PotPlayerMini64.exe') or
            FileExists(AddBackslash(NormalizedDir) + 'PotPlayerMini.exe');
end;

function TranslateDirFromPotPlayerRoot(const RootDir: String): String;
begin
  Result := AddBackslash(RemoveBackslashUnlessRoot(Trim(RootDir))) + 'Extension\Subtitle\Translate';
end;

function NormalizeSelectedInstallDir(const SelectedDir: String): String;
var
  NormalizedDir: String;
  PotPlayerRoot: String;
begin
  Result := '';
  NormalizedDir := RemoveBackslashUnlessRoot(Trim(SelectedDir));
  if NormalizedDir = '' then
    exit;

  if DirectoryContainsPotPlayerExecutable(NormalizedDir) then
  begin
    Result := TranslateDirFromPotPlayerRoot(NormalizedDir);
    exit;
  end;

  if EndsWithText(NormalizedDir, TranslateSuffix) then
  begin
    PotPlayerRoot := Copy(NormalizedDir, 1, Length(NormalizedDir) - Length(TranslateSuffix));
    if DirectoryContainsPotPlayerExecutable(PotPlayerRoot) then
      Result := NormalizedDir;
    exit;
  end;

  if EndsWithText(NormalizedDir, SubtitleSuffix) then
  begin
    PotPlayerRoot := Copy(NormalizedDir, 1, Length(NormalizedDir) - Length(SubtitleSuffix));
    if DirectoryContainsPotPlayerExecutable(PotPlayerRoot) then
      Result := AddBackslash(NormalizedDir) + 'Translate';
    exit;
  end;
end;

function GetSelectedVariantIsContext: Boolean;
begin
  Result := True;
  if Assigned(VariantPage) then
    Result := VariantPage.Values[0];
end;

function GetSelectedVariantName: String;
begin
  if GetSelectedVariantIsContext then
    Result := CustomMessage('WithContext')
  else
    Result := CustomMessage('WithoutContext');
end;

function GetSelectedVariantKey: String;
begin
  if GetSelectedVariantIsContext then
    Result := 'with_context'
  else
    Result := 'without_context';
end;

function ShouldUninstallContextVariant: Boolean;
begin
  Result := GetSelectedVariantIsContext;
end;

function ShouldUninstallWithoutContextVariant: Boolean;
begin
  Result := not GetSelectedVariantIsContext;
end;

function GetInstallDirIdentitySeed: String;
var
  Candidate: String;
begin
  Candidate := '';
  if WizardForm <> nil then
    Candidate := WizardDirValue();

  if (Trim(Candidate) = '') and (Trim(InitialDetectedDir) <> '') then
    Candidate := InitialDetectedDir;

  Result := NormalizeSelectedInstallDir(Candidate);
  if Result = '' then
    Result := RemoveBackslashUnlessRoot(Trim(Candidate));
end;

function GetDynamicAppId(Param: String): String;
var
  IdentitySeed: String;
begin
  IdentitySeed := GetInstallDirIdentitySeed;
  if IdentitySeed = '' then
    Result := 'PotPlayerChatGPTTranslatePending_' + GetSelectedVariantKey
  else
    Result := 'PotPlayerChatGPTTranslate_' + GetMD5OfUnicodeString(LowerCase(IdentitySeed + '|' + GetSelectedVariantKey));
end;

function GetDynamicUninstallDisplayName(Param: String): String;
var
  InstallDir: String;
begin
  Result := '{#MyAppName} (' + GetSelectedVariantName + ')';
  InstallDir := GetInstallDirIdentitySeed;
  if InstallDir <> '' then
    Result := Result + ' [' + InstallDir + ']';
end;

function TryGetPotPlayerRootFromAppPaths(const RootKey: Integer; const ExeName: String; var PotPlayerRoot: String): Boolean;
var
  ExePath: String;
begin
  Result := False;
  if RegQueryStringValue(RootKey, 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\' + ExeName, '', ExePath) then
  begin
    ExePath := StripQuotes(ExePath);
    if FileExists(ExePath) then
    begin
      PotPlayerRoot := ExtractFileDir(ExePath);
      Result := True;
    end;
  end;
end;

function GetPotPlayerRootFromRegistry: String;
begin
  Result := '';
  if TryGetPotPlayerRootFromAppPaths(HKLM64, 'PotPlayerMini64.exe', Result) then
    exit;
  if TryGetPotPlayerRootFromAppPaths(HKLM64, 'PotPlayerMini.exe', Result) then
    exit;
  if TryGetPotPlayerRootFromAppPaths(HKLM32, 'PotPlayerMini.exe', Result) then
    exit;
  if TryGetPotPlayerRootFromAppPaths(HKLM, 'PotPlayerMini64.exe', Result) then
    exit;
  if TryGetPotPlayerRootFromAppPaths(HKLM, 'PotPlayerMini.exe', Result) then
    exit;
end;

function NormalizeApiUrlForConfig(const ApiUrl: String): String;
begin
  Result := Trim(ApiUrl);
  if Result = '' then
  begin
    Result := 'https://api.openai.com/v1/chat/completions';
    exit;
  end;

  Result := TrimTrailingSlashes(Result);
  if EndsWithText(Result, '/chat/completions') or EndsWithText(Result, '/responses') then
    exit;

  if EndsWithText(Result, '/v1') or
     EndsWithText(Result, '/v4') or
     EndsWithText(Result, '/v1beta/openai') or
     EndsWithText(Result, '/compatible-mode/v1') or
     EndsWithText(Result, '/openai/v1') or
     EndsWithText(Result, '/inference/v1') then
    Result := Result + '/chat/completions';
end;

function NormalizeBaseUrlForOpenAI(const ApiUrl: String): String;
begin
  Result := TrimTrailingSlashes(ApiUrl);
  if Result = '' then
  begin
    Result := 'https://api.openai.com/v1';
    exit;
  end;

  if EndsWithText(Result, '/chat/completions') then
    Delete(Result, Length(Result) - Length('/chat/completions') + 1, Length('/chat/completions'))
  else if EndsWithText(Result, '/responses') then
    Delete(Result, Length(Result) - Length('/responses') + 1, Length('/responses'));
end;

function TryResolveCallableChatApiUrl(const ApiUrl: String; var ResolvedUrl: String): Boolean;
begin
  ResolvedUrl := Trim(ApiUrl);
  if ResolvedUrl = '' then
  begin
    ResolvedUrl := 'https://api.openai.com/v1/chat/completions';
    Result := True;
    exit;
  end;

  ResolvedUrl := TrimTrailingSlashes(ResolvedUrl);

  if EndsWithText(ResolvedUrl, '/responses') then
  begin
    ResolvedUrl := NormalizeBaseUrlForOpenAI(ResolvedUrl);
    ResolvedUrl := TrimTrailingSlashes(ResolvedUrl) + '/chat/completions';
    Result := True;
    exit;
  end;

  if EndsWithText(ResolvedUrl, '/chat/completions') then
  begin
    Result := True;
    exit;
  end;

  if EndsWithText(ResolvedUrl, '/v1') or
     EndsWithText(ResolvedUrl, '/v4') or
     EndsWithText(ResolvedUrl, '/v1beta/openai') or
     EndsWithText(ResolvedUrl, '/compatible-mode/v1') or
     EndsWithText(ResolvedUrl, '/openai/v1') or
     EndsWithText(ResolvedUrl, '/inference/v1') then
  begin
    ResolvedUrl := ResolvedUrl + '/chat/completions';
    Result := True;
    exit;
  end;

  Result := False;
end;

function ResolveCallableChatApiUrl(const ApiUrl: String): String;
begin
  if not TryResolveCallableChatApiUrl(ApiUrl, Result) then
    Result := NormalizeApiUrlForConfig(ApiUrl);
end;

function EscapeJsonString(const Value: String): String;
begin
  Result := Value;
  Result := ReplaceAll(Result, '\', '\\');
  Result := ReplaceAll(Result, '"', '\"');
  Result := ReplaceAll(Result, #13, '');
  Result := ReplaceAll(Result, #10, '\n');
  Result := ReplaceAll(Result, #9, '\t');
end;

function EscapeForAsString(const Value: String): String;
begin
  Result := Value;
  Result := ReplaceAll(Result, '\', '\\');
  Result := ReplaceAll(Result, '"', '\"');
  Result := ReplaceAll(Result, #13, '');
  Result := ReplaceAll(Result, #10, '\n');
end;

function Utf8ToString(const Value: AnsiString): String;
var
  LengthNeeded: Integer;
begin
  if Value = '' then
  begin
    Result := '';
    exit;
  end;

  LengthNeeded := MultiByteToWideChar(CP_UTF8, 0, Value, Length(Value), Result, 0);
  SetLength(Result, LengthNeeded);
  if LengthNeeded > 0 then
    MultiByteToWideChar(CP_UTF8, 0, Value, Length(Value), Result, LengthNeeded);
end;

function StringToUtf8(const Value: String): AnsiString;
var
  LengthNeeded: Integer;
begin
  if Value = '' then
  begin
    Result := '';
    exit;
  end;

  LengthNeeded := WideCharToMultiByte(CP_UTF8, 0, Value, Length(Value), Result, 0, 0, 0);
  SetLength(Result, LengthNeeded);
  if LengthNeeded > 0 then
    WideCharToMultiByte(CP_UTF8, 0, Value, Length(Value), Result, LengthNeeded, 0, 0);
end;

function LoadUtf8TextFile(const FileName: String; var Value: String): Boolean;
var
  Raw: AnsiString;
begin
  Result := LoadStringFromFile(FileName, Raw);
  if not Result then
    exit;

  if (Length(Raw) >= 3) and (Raw[1] = AnsiChar(#$EF)) and (Raw[2] = AnsiChar(#$BB)) and (Raw[3] = AnsiChar(#$BF)) then
    Delete(Raw, 1, 3);
  Value := Utf8ToString(Raw);
end;

function SaveUtf8TextFileNoBOM(const FileName, Value: String): Boolean;
begin
  Result := SaveStringToFile(FileName, StringToUtf8(Value), False);
end;

function ReplaceQuotedValue(var Data: String; const Key, NewValue: String): Boolean;
var
  KeyPos: Integer;
  EqualsPos: Integer;
  OpenQuotePos: Integer;
  CloseQuotePos: Integer;
  Escaped: Boolean;
  Ch: Char;
begin
  Result := False;
  KeyPos := Pos(Key, Data);
  if KeyPos = 0 then
    exit;

  EqualsPos := PosFrom('=', Data, KeyPos + Length(Key));
  if EqualsPos = 0 then
    exit;

  OpenQuotePos := PosFrom('"', Data, EqualsPos + 1);
  if OpenQuotePos = 0 then
    exit;

  CloseQuotePos := OpenQuotePos + 1;
  Escaped := False;
  while CloseQuotePos <= Length(Data) do
  begin
    Ch := Data[CloseQuotePos];
    if Escaped then
      Escaped := False
    else if Ch = '\' then
      Escaped := True
    else if Ch = '"' then
      break;
    CloseQuotePos := CloseQuotePos + 1;
  end;

  if CloseQuotePos > Length(Data) then
    exit;

  Delete(Data, OpenQuotePos + 1, CloseQuotePos - OpenQuotePos - 1);
  Insert(NewValue, Data, OpenQuotePos + 1);
  Result := True;
end;

function DetectNewLine(const Value: String): String;
begin
  if Pos(#13#10, Value) > 0 then
    Result := #13#10
  else
    Result := #10;
end;

procedure InjectDebugConsole(var Data: String);
var
  NewLineValue: String;
  InitPos: Integer;
  BracePos: Integer;
  LineEndPos: Integer;
  IndentStart: Integer;
  IndentEnd: Integer;
  Indent: String;
  CommentEnd: Integer;
begin
  if Pos('HostOpenConsole();', Data) > 0 then
    exit;

  NewLineValue := DetectNewLine(Data);
  InitPos := Pos('void OnInitialize()', Data);
  if InitPos > 0 then
  begin
    BracePos := PosFrom('{', Data, InitPos);
    if BracePos > 0 then
    begin
      LineEndPos := PosFrom(#10, Data, BracePos);
      if LineEndPos > 0 then
      begin
        IndentStart := LineEndPos + 1;
        if (IndentStart <= Length(Data)) and (Data[IndentStart] = #13) then
          IndentStart := IndentStart + 1;
        IndentEnd := IndentStart;
        while (IndentEnd <= Length(Data)) and ((Data[IndentEnd] = ' ') or (Data[IndentEnd] = #9)) do
          IndentEnd := IndentEnd + 1;
        if IndentEnd > IndentStart then
          Indent := Copy(Data, IndentStart, IndentEnd - IndentStart)
        else
          Indent := '    ';
        Insert(Indent + 'HostOpenConsole();' + NewLineValue, Data, IndentStart);
        exit;
      end;
    end;
  end;
end;

function InstallScriptFile(const TempFileName, DestFileName: String; IsContextVariant: Boolean): Boolean;
var
  SourceFileName: String;
  Data: String;
  ApiKeyToWrite: String;
begin
  Result := False;
  SourceFileName := ExpandConstant('{tmp}\' + TempFileName);
  ExtractTemporaryFile(TempFileName);
  if not LoadUtf8TextFile(SourceFileName, Data) then
  begin
    LastInstallError := 'Could not read ' + TempFileName;
    exit;
  end;

  ApiKeyToWrite := Trim(ApiKeyEdit.Text);
  if ApiKeyToWrite = '' then
    ApiKeyToWrite := 'nullkey';

  ReplaceQuotedValue(Data, 'pre_api_key', EscapeForAsString(ApiKeyToWrite));
  ReplaceQuotedValue(Data, 'pre_selected_model', EscapeForAsString(Trim(ModelEdit.Text)));
  ReplaceQuotedValue(Data, 'pre_apiUrl', EscapeForAsString(ResolveCallableChatApiUrl(Trim(ApiUrlEdit.Text))));
  ReplaceQuotedValue(Data, 'pre_delay_ms', EscapeForAsString(Trim(DelayPage.Values[0])));
  ReplaceQuotedValue(Data, 'pre_retry_mode', EscapeForAsString(IntToStr(RetryPage.SelectedValueIndex)));
  ReplaceQuotedValue(Data, 'pre_small_model', EscapeForAsString(IntToStr(Integer(SmallModelCheck.Checked))));
  ReplaceQuotedValue(Data, 'pre_check_hallucination', EscapeForAsString(IntToStr(Integer(HallucinationPage.Values[0]))));
  ReplaceQuotedValue(Data, 'pre_model_token_limits_json', EscapeForAsString(GeneratedModelTokenLimitsJson));

  if IsContextVariant then
  begin
    ReplaceQuotedValue(Data, 'pre_context_subtitle_count', EscapeForAsString(Trim(ContextSubtitleCountEdit.Text)));

    if ContextCacheCombo.ItemIndex = 1 then
      ReplaceQuotedValue(Data, 'pre_context_cache_mode', 'off')
    else
      ReplaceQuotedValue(Data, 'pre_context_cache_mode', 'auto');

    ReplaceQuotedValue(Data, 'pre_prompt_cache_retention', EscapeForAsString(Trim(PromptCacheRetentionEdit.Text)));
    ReplaceQuotedValue(Data, 'pre_gemini_cached_content', EscapeForAsString(Trim(GeminiCachedContentEdit.Text)));
  end;

  if DebugPage.Values[0] then
    InjectDebugConsole(Data);

  if not SaveUtf8TextFileNoBOM(DestFileName, Data) then
  begin
    LastInstallError := 'Could not write ' + DestFileName;
    exit;
  end;

  Result := True;
end;

function InstallBinaryFile(const TempFileName, DestFileName: String): Boolean;
var
  SourceFileName: String;
begin
  Result := False;
  SourceFileName := ExpandConstant('{tmp}\' + TempFileName);
  ExtractTemporaryFile(TempFileName);
  if not FileCopy(SourceFileName, DestFileName, False) then
  begin
    LastInstallError := 'Could not copy ' + TempFileName + ' to ' + DestFileName;
    exit;
  end;
  Result := True;
end;

function InstallVariantFiles(const VariantName: String; IsContextVariant: Boolean): Boolean;
var
  TargetDir: String;
  ScriptName: String;
  IconName: String;
begin
  Result := False;
  TargetDir := WizardDirValue();
  if not ForceDirectories(TargetDir) then
  begin
    LastInstallError := 'Could not create ' + TargetDir;
    exit;
  end;

  ScriptName := GetVariantScriptName(IsContextVariant);
  IconName := GetVariantIconName(IsContextVariant);

  WizardForm.StatusLabel.Caption := CustomMessage('InstallingVariant') + ' ' + VariantName;
  WizardForm.FilenameLabel.Caption := AddBackslash(TargetDir) + ScriptName;
  if not InstallScriptFile(ScriptName, AddBackslash(TargetDir) + ScriptName, IsContextVariant) then
    exit;

  WizardForm.FilenameLabel.Caption := AddBackslash(TargetDir) + IconName;
  if not InstallBinaryFile(IconName, AddBackslash(TargetDir) + IconName) then
    exit;

  Result := True;
end;

function PerformInstall: Boolean;
var
  IsContextVariant: Boolean;
begin
  LastInstallError := '';
  Result := False;
  IsContextVariant := GetSelectedVariantIsContext;

  if not InstallVariantFiles(GetSelectedVariantName, IsContextVariant) then
    exit;

  Result := True;
end;

function BuildConfigFingerprint: String;
begin
  Result := Trim(ModelEdit.Text) + #1 + ResolveCallableChatApiUrl(Trim(ApiUrlEdit.Text)) + #1 + Trim(ApiKeyEdit.Text);
end;

procedure ApplySelectedPreset;
var
  Index: Integer;
begin
  Index := PresetCombo.ItemIndex;
  if (Index < 0) or (Index >= GetArrayLength(ProviderPresets)) then
    exit;

  if ProviderPresets[Index].Key = '__CUSTOM__' then
  begin
    PurchaseButton.Enabled := False;
    exit;
  end;

  ModelEdit.Text := ProviderPresets[Index].Model;
  ApiUrlEdit.Text := NormalizeApiUrlForConfig(ProviderPresets[Index].ApiBase);
  PurchaseButton.Enabled := (Trim(ProviderPresets[Index].PurchasePage) <> '') and (CompareText(ProviderPresets[Index].PurchasePage, 'pass') <> 0);
end;

procedure PresetComboChange(Sender: TObject);
begin
  ApplySelectedPreset;
  VerifiedConfigFingerprint := '';
end;

procedure PurchaseButtonClick(Sender: TObject);
var
  Index: Integer;
  ErrorCode: Integer;
  Url: String;
begin
  Index := PresetCombo.ItemIndex;
  if (Index < 0) or (Index >= GetArrayLength(ProviderPresets)) then
    exit;

  Url := ProviderPresets[Index].PurchasePage;
  if (Trim(Url) = '') or (CompareText(Url, 'pass') = 0) then
    exit;

  ShellExec('open', Url, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

function UsesResponsesEndpoint(const ApiUrl: String): Boolean;
begin
  Result := EndsWithText(TrimTrailingSlashes(ApiUrl), '/responses');
end;

function VerifyApiSettings(var ErrorMessage: String): Boolean;
var
  Request: Variant;
  RequestUrl: String;
  Body: String;
  ResponseText: String;
  StatusCode: Integer;
  ApiKeyValue: String;
  IsResponsesEndpoint: Boolean;
begin
  Result := False;
  ErrorMessage := '';
  RequestUrl := ResolveCallableChatApiUrl(Trim(ApiUrlEdit.Text));

  IsResponsesEndpoint := UsesResponsesEndpoint(RequestUrl);
  if IsResponsesEndpoint then
    Body := '{"model":"' + EscapeJsonString(Trim(ModelEdit.Text)) + '","input":[{"role":"system","content":[{"type":"input_text","text":"You are a test assistant."}]},{"role":"user","content":[{"type":"input_text","text":"Hello"}]}]}'
  else
    Body := '{"model":"' + EscapeJsonString(Trim(ModelEdit.Text)) + '","messages":[{"role":"system","content":"You are a test assistant."},{"role":"user","content":"Hello"}]}';
  ApiKeyValue := Trim(ApiKeyEdit.Text);

  try
    Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Request.SetTimeouts(15000, 15000, 15000, 60000);
    Request.Open('POST', RequestUrl, False);
    Request.SetRequestHeader('Content-Type', 'application/json');
    if ApiKeyValue <> '' then
      Request.SetRequestHeader('Authorization', 'Bearer ' + ApiKeyValue);
    Request.Send(Body);
    StatusCode := Request.Status;
    ResponseText := Request.ResponseText;
    if IsResponsesEndpoint then
      Result := (StatusCode >= 200) and (StatusCode < 300) and ((Pos('"output"', ResponseText) > 0) or (Pos('"output_text"', ResponseText) > 0))
    else
      Result := (StatusCode >= 200) and (StatusCode < 300) and (Pos('"choices"', ResponseText) > 0);
    if not Result then
    begin
      if Trim(ResponseText) <> '' then
        ErrorMessage := ResponseText
      else
        ErrorMessage := 'HTTP ' + IntToStr(StatusCode);
    end;
  except
    ErrorMessage := GetExceptionMessage;
  end;
end;

function RunVerification: Boolean;
var
  ErrorMessage: String;
begin
  Result := VerifyApiSettings(ErrorMessage);
  if Result then
  begin
    VerifiedConfigFingerprint := BuildConfigFingerprint;
  end
  else
  begin
    VerifiedConfigFingerprint := '';
    if Trim(ErrorMessage) = '' then
      ErrorMessage := 'Unknown verification error';
    MsgBox(CustomMessage('VerifyFailed') + #13#10 + ErrorMessage, mbCriticalError, MB_OK);
  end;
end;

procedure SkipVerifyButtonClick(Sender: TObject);
begin
  SkipVerificationRequested := True;
  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

function IsNonNegativeIntegerText(const Value: String): Boolean;
var
  I: Integer;
begin
  Result := Trim(Value) <> '';
  if not Result then
    exit;

  for I := 1 to Length(Value) do
    if (Value[I] < '0') or (Value[I] > '9') then
    begin
      Result := False;
      exit;
    end;
end;

function IsFixedDrive(const RootPath: String): Boolean;
begin
  Result := GetDriveType(RootPath) = DRIVE_FIXED;
end;

function DetectPotPlayerTranslateDir: String;
var
  DriveOrdinal: Integer;
  PotPlayerRoot: String;
  DriveRoot: String;
  CandidateRoot: String;
begin
  Result := '';

  PotPlayerRoot := GetPotPlayerRootFromRegistry;
  if PotPlayerRoot <> '' then
  begin
    Result := TranslateDirFromPotPlayerRoot(PotPlayerRoot);
    exit;
  end;

  CandidateRoot := ExpandConstant('{autopf}\DAUM\PotPlayer');
  if DirectoryContainsPotPlayerExecutable(CandidateRoot) then
  begin
    Result := TranslateDirFromPotPlayerRoot(CandidateRoot);
    exit;
  end;

  CandidateRoot := ExpandConstant('{pf32}\DAUM\PotPlayer');
  if DirectoryContainsPotPlayerExecutable(CandidateRoot) then
  begin
    Result := TranslateDirFromPotPlayerRoot(CandidateRoot);
    exit;
  end;

  for DriveOrdinal := Ord('C') to Ord('Z') do
  begin
    DriveRoot := Chr(DriveOrdinal) + ':\';
    if IsFixedDrive(DriveRoot) then
    begin
      CandidateRoot := Copy(DriveRoot, 1, 2) + '\Program Files\DAUM\PotPlayer';
      if DirectoryContainsPotPlayerExecutable(CandidateRoot) then
      begin
        Result := TranslateDirFromPotPlayerRoot(CandidateRoot);
        exit;
      end;

      CandidateRoot := Copy(DriveRoot, 1, 2) + '\Program Files (x86)\DAUM\PotPlayer';
      if DirectoryContainsPotPlayerExecutable(CandidateRoot) then
      begin
        Result := TranslateDirFromPotPlayerRoot(CandidateRoot);
        exit;
      end;
    end;
  end;
end;

function GetDefaultInstallDir(Param: String): String;
begin
  Result := DetectPotPlayerTranslateDir;
  if Result = '' then
    Result := ExpandConstant('{autopf}');
end;

function GetVariantScriptName(const IsContextVariant: Boolean): String;
begin
  if IsContextVariant then
    Result := 'SubtitleTranslate - ChatGPT.as'
  else
    Result := 'SubtitleTranslate - ChatGPT - Without Context.as';
end;

function GetVariantIconName(const IsContextVariant: Boolean): String;
begin
  if IsContextVariant then
    Result := 'SubtitleTranslate - ChatGPT.ico'
  else
    Result := 'SubtitleTranslate - ChatGPT - Without Context.ico';
end;

function VariantFilesExist(const TargetDir: String; const IsContextVariant: Boolean): Boolean;
begin
  Result := FileExists(AddBackslash(TargetDir) + GetVariantScriptName(IsContextVariant)) or
            FileExists(AddBackslash(TargetDir) + GetVariantIconName(IsContextVariant));
end;

procedure SyncVariantSelectionFromInstallDir(const TargetDir: String);
var
  NormalizedDir: String;
  WithContextExists: Boolean;
  WithoutContextExists: Boolean;
begin
  NormalizedDir := RemoveBackslashUnlessRoot(Trim(TargetDir));
  WithContextExists := VariantFilesExist(NormalizedDir, True);
  WithoutContextExists := VariantFilesExist(NormalizedDir, False);

  if WithContextExists or WithoutContextExists then
  begin
    if WithContextExists and (not WithoutContextExists) then
    begin
      VariantPage.Values[0] := True;
      VariantPage.Values[1] := False;
    end
    else if WithoutContextExists and (not WithContextExists) then
    begin
      VariantPage.Values[0] := False;
      VariantPage.Values[1] := True;
    end
    else
    begin
      VariantPage.Values[0] := True;
      VariantPage.Values[1] := False;
    end;
  end
  else
  begin
    VariantPage.Values[0] := True;
    VariantPage.Values[1] := False;
  end;

  LastVariantSelectionSyncDir := NormalizedDir;
end;

function GetExistingTargetFilesText: String;
var
  Candidate: String;
  IsContextVariant: Boolean;
begin
  Result := '';
  IsContextVariant := GetSelectedVariantIsContext;
  Candidate := AddBackslash(WizardDirValue()) + GetVariantScriptName(IsContextVariant);
  if FileExists(Candidate) then
    Result := Result + Candidate + #13#10;
  Candidate := AddBackslash(WizardDirValue()) + GetVariantIconName(IsContextVariant);
  if FileExists(Candidate) then
    Result := Result + Candidate + #13#10;

  Result := Trim(Result);
end;

procedure InitializeConfigPage;
var
  CurrentTop: Integer;
  I: Integer;
  ContentLeft: Integer;
  ContentWidth: Integer;
  LabelGap: Integer;
  FieldGap: Integer;
  SectionGap: Integer;
  ButtonGap: Integer;
begin
  ConfigPage := CreateCustomPage(VariantPage.ID, CustomMessage('ConfigTitle'), CustomMessage('ConfigDescription'));

  ContentLeft := ScaleX(CustomPageMarginX);
  ContentWidth := ConfigPage.SurfaceWidth - (ContentLeft * 2);
  CurrentTop := ScaleY(CustomPageMarginTop);
  LabelGap := ScaleY(CustomPageLabelGapY);
  FieldGap := ScaleY(CustomPageFieldGapY);
  SectionGap := ScaleY(CustomPageSectionGapY);
  ButtonGap := ScaleX(CustomPageButtonGapX);

  PresetLabel := TNewStaticText.Create(ConfigPage);
  PresetLabel.Parent := ConfigPage.Surface;
  PresetLabel.Left := ContentLeft;
  PresetLabel.Top := CurrentTop;
  PresetLabel.Caption := CustomMessage('PresetLabel');
  CurrentTop := CurrentTop + PresetLabel.Height + LabelGap;

  PresetCombo := TNewComboBox.Create(ConfigPage);
  PresetCombo.Parent := ConfigPage.Surface;
  PresetCombo.Left := ContentLeft;
  PresetCombo.Top := CurrentTop;
  PresetCombo.Width := ContentWidth;
  PresetCombo.Style := csDropDownList;
  PresetCombo.OnChange := @PresetComboChange;
  for I := 0 to GetArrayLength(ProviderPresets) - 1 do
    PresetCombo.Items.Add(ProviderPresets[I].Key);
  CurrentTop := CurrentTop + PresetCombo.Height + FieldGap;

  ModelLabel := TNewStaticText.Create(ConfigPage);
  ModelLabel.Parent := ConfigPage.Surface;
  ModelLabel.Left := ContentLeft;
  ModelLabel.Top := CurrentTop;
  ModelLabel.Caption := CustomMessage('ModelLabel');
  CurrentTop := CurrentTop + ModelLabel.Height + LabelGap;

  ModelEdit := TNewEdit.Create(ConfigPage);
  ModelEdit.Parent := ConfigPage.Surface;
  ModelEdit.Left := ContentLeft;
  ModelEdit.Top := CurrentTop;
  ModelEdit.Width := ContentWidth;
  CurrentTop := CurrentTop + ModelEdit.Height + FieldGap;

  ApiUrlLabel := TNewStaticText.Create(ConfigPage);
  ApiUrlLabel.Parent := ConfigPage.Surface;
  ApiUrlLabel.Left := ContentLeft;
  ApiUrlLabel.Top := CurrentTop;
  ApiUrlLabel.Caption := CustomMessage('ApiUrlLabel');
  CurrentTop := CurrentTop + ApiUrlLabel.Height + LabelGap;

  ApiUrlEdit := TNewEdit.Create(ConfigPage);
  ApiUrlEdit.Parent := ConfigPage.Surface;
  ApiUrlEdit.Left := ContentLeft;
  ApiUrlEdit.Top := CurrentTop;
  ApiUrlEdit.Width := ContentWidth;
  CurrentTop := CurrentTop + ApiUrlEdit.Height + FieldGap;

  ApiKeyLabel := TNewStaticText.Create(ConfigPage);
  ApiKeyLabel.Parent := ConfigPage.Surface;
  ApiKeyLabel.Left := ContentLeft;
  ApiKeyLabel.Top := CurrentTop;
  ApiKeyLabel.Caption := CustomMessage('ApiKeyLabel');
  CurrentTop := CurrentTop + ApiKeyLabel.Height + LabelGap;

  ApiKeyEdit := TPasswordEdit.Create(ConfigPage);
  ApiKeyEdit.Parent := ConfigPage.Surface;
  ApiKeyEdit.Left := ContentLeft;
  ApiKeyEdit.Top := CurrentTop;
  ApiKeyEdit.Width := ContentWidth;
  CurrentTop := CurrentTop + ApiKeyEdit.Height + FieldGap;

  SmallModelCheck := TNewCheckBox.Create(ConfigPage);
  SmallModelCheck.Parent := ConfigPage.Surface;
  SmallModelCheck.Left := ContentLeft;
  SmallModelCheck.Top := CurrentTop;
  SmallModelCheck.Width := ContentWidth;
  SmallModelCheck.Height := ScaleY(CustomPageCheckBoxHeight);
  SmallModelCheck.Caption := CustomMessage('SmallModelLabel');
  CurrentTop := CurrentTop + SmallModelCheck.Height + SectionGap;

  PurchaseButton := TNewButton.Create(ConfigPage);
  PurchaseButton.Parent := ConfigPage.Surface;
  PurchaseButton.Left := ContentLeft;
  PurchaseButton.Top := CurrentTop;
  PurchaseButton.Width := (ContentWidth - ButtonGap) div 2;
  PurchaseButton.Height := WizardForm.NextButton.Height;
  PurchaseButton.Caption := CustomMessage('PurchaseButton');
  PurchaseButton.OnClick := @PurchaseButtonClick;

  SkipVerifyButton := TNewButton.Create(ConfigPage);
  SkipVerifyButton.Parent := ConfigPage.Surface;
  SkipVerifyButton.Left := PurchaseButton.Left + PurchaseButton.Width + ButtonGap;
  SkipVerifyButton.Top := CurrentTop;
  SkipVerifyButton.Width := ContentLeft + ContentWidth - SkipVerifyButton.Left;
  SkipVerifyButton.Height := PurchaseButton.Height;
  SkipVerifyButton.Caption := CustomMessage('SkipVerifyButton');
  SkipVerifyButton.OnClick := @SkipVerifyButtonClick;
  CurrentTop := CurrentTop + SkipVerifyButton.Height + FieldGap;

  PresetCombo.ItemIndex := 2;
  ApplySelectedPreset;
end;

procedure InitializeContextPage;
var
  CurrentTop: Integer;
  ContentLeft: Integer;
  ContentWidth: Integer;
  LabelGap: Integer;
  FieldGap: Integer;
begin
  ContextPage := CreateCustomPage(HallucinationPage.ID, CustomMessage('ContextTitle'), CustomMessage('ContextDescription'));

  ContentLeft := ScaleX(CustomPageMarginX);
  ContentWidth := ContextPage.SurfaceWidth - (ContentLeft * 2);
  CurrentTop := ScaleY(CustomPageMarginTop);
  LabelGap := ScaleY(CustomPageLabelGapY);
  FieldGap := ScaleY(CustomPageFieldGapY);

  ContextSubtitleCountLabel := TNewStaticText.Create(ContextPage);
  ContextSubtitleCountLabel.Parent := ContextPage.Surface;
  ContextSubtitleCountLabel.Left := ContentLeft;
  ContextSubtitleCountLabel.Top := CurrentTop;
  ContextSubtitleCountLabel.Caption := CustomMessage('ContextSubtitleCountLabel');
  CurrentTop := CurrentTop + ContextSubtitleCountLabel.Height + LabelGap;

  ContextSubtitleCountEdit := TNewEdit.Create(ContextPage);
  ContextSubtitleCountEdit.Parent := ContextPage.Surface;
  ContextSubtitleCountEdit.Left := ContentLeft;
  ContextSubtitleCountEdit.Top := CurrentTop;
  ContextSubtitleCountEdit.Width := ContentWidth;
  ContextSubtitleCountEdit.Text := '3';
  CurrentTop := CurrentTop + ContextSubtitleCountEdit.Height + LabelGap;

  ContextSubtitleCountHint := TNewStaticText.Create(ContextPage);
  ContextSubtitleCountHint.Parent := ContextPage.Surface;
  ContextSubtitleCountHint.Left := ContentLeft;
  ContextSubtitleCountHint.Top := CurrentTop;
  ContextSubtitleCountHint.Width := ContentWidth;
  ContextSubtitleCountHint.Caption := CustomMessage('ContextSubtitleCountHint');
  CurrentTop := CurrentTop + ContextSubtitleCountHint.Height + FieldGap;

  ContextCacheLabel := TNewStaticText.Create(ContextPage);
  ContextCacheLabel.Parent := ContextPage.Surface;
  ContextCacheLabel.Left := ContentLeft;
  ContextCacheLabel.Top := CurrentTop;
  ContextCacheLabel.Caption := CustomMessage('ContextCacheLabel');
  CurrentTop := CurrentTop + ContextCacheLabel.Height + LabelGap;

  ContextCacheCombo := TNewComboBox.Create(ContextPage);
  ContextCacheCombo.Parent := ContextPage.Surface;
  ContextCacheCombo.Left := ContentLeft;
  ContextCacheCombo.Top := CurrentTop;
  ContextCacheCombo.Width := ContentWidth;
  ContextCacheCombo.Style := csDropDownList;
  ContextCacheCombo.Items.Add(CustomMessage('ContextCacheAuto'));
  ContextCacheCombo.Items.Add(CustomMessage('ContextCacheOff'));
  ContextCacheCombo.ItemIndex := 0;
  CurrentTop := CurrentTop + ContextCacheCombo.Height + FieldGap;

  PromptCacheRetentionLabel := TNewStaticText.Create(ContextPage);
  PromptCacheRetentionLabel.Parent := ContextPage.Surface;
  PromptCacheRetentionLabel.Left := ContentLeft;
  PromptCacheRetentionLabel.Top := CurrentTop;
  PromptCacheRetentionLabel.Caption := CustomMessage('PromptCacheRetentionLabel');
  CurrentTop := CurrentTop + PromptCacheRetentionLabel.Height + LabelGap;

  PromptCacheRetentionEdit := TNewEdit.Create(ContextPage);
  PromptCacheRetentionEdit.Parent := ContextPage.Surface;
  PromptCacheRetentionEdit.Left := ContentLeft;
  PromptCacheRetentionEdit.Top := CurrentTop;
  PromptCacheRetentionEdit.Width := ContentWidth;
  PromptCacheRetentionEdit.Text := '24h';
  CurrentTop := CurrentTop + PromptCacheRetentionEdit.Height + FieldGap;

  GeminiCachedContentLabel := TNewStaticText.Create(ContextPage);
  GeminiCachedContentLabel.Parent := ContextPage.Surface;
  GeminiCachedContentLabel.Left := ContentLeft;
  GeminiCachedContentLabel.Top := CurrentTop;
  GeminiCachedContentLabel.Caption := CustomMessage('GeminiCachedContentLabel');
  CurrentTop := CurrentTop + GeminiCachedContentLabel.Height + LabelGap;

  GeminiCachedContentEdit := TNewEdit.Create(ContextPage);
  GeminiCachedContentEdit.Parent := ContextPage.Surface;
  GeminiCachedContentEdit.Left := ContentLeft;
  GeminiCachedContentEdit.Top := CurrentTop;
  GeminiCachedContentEdit.Width := ContentWidth;
end;

procedure InitializeWizard;
begin
  InitializeGeneratedInstallerData;
  SkipVerificationRequested := False;
  LastVariantSelectionSyncDir := '';

  WizardForm.LicenseAcceptedRadio.Checked := True;

  WizardForm.WelcomeLabel2.Caption := CustomMessage('WelcomeBody');
  WizardForm.FinishedLabel.Caption := CustomMessage('FinishBody');

  InitialDetectedDir := DetectPotPlayerTranslateDir;
  WizardForm.DirEdit.Text := InitialDetectedDir;

  VariantPage := CreateInputOptionPage(wpSelectDir, CustomMessage('VariantTitle'), CustomMessage('VariantDescription'), '', True, False);
  VariantPage.Add(CustomMessage('WithContext'));
  VariantPage.Add(CustomMessage('WithoutContext'));
  VariantPage.Values[0] := True;
  VariantPage.Values[1] := False;

  InitializeConfigPage;

  DelayPage := CreateInputQueryPage(ConfigPage.ID, CustomMessage('DelayTitle'), CustomMessage('DelayDescription'), '');
  DelayPage.Add(CustomMessage('DelayLabel'), False);
  DelayPage.Values[0] := '500';

  RetryPage := CreateInputOptionPage(DelayPage.ID, CustomMessage('RetryTitle'), CustomMessage('RetryDescription'), '', True, False);
  RetryPage.Add(CustomMessage('RetryOff'));
  RetryPage.Add(CustomMessage('RetryOnce'));
  RetryPage.Add(CustomMessage('RetryUntil'));
  RetryPage.Add(CustomMessage('RetryDelayed'));
  RetryPage.Values[1] := True;

  HallucinationPage := CreateInputOptionPage(RetryPage.ID, CustomMessage('HallucinationTitle'), CustomMessage('HallucinationDescription'), '', False, False);
  HallucinationPage.Add(CustomMessage('HallucinationLabel'));
  HallucinationPage.Values[0] := False;

  InitializeContextPage;

  DebugPage := CreateInputOptionPage(ContextPage.ID, CustomMessage('DebugTitle'), CustomMessage('DebugDescription'), '', False, False);
  DebugPage.Add(CustomMessage('DebugLabel'));
  DebugPage.Values[0] := False;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  if Assigned(ContextPage) and (PageID = ContextPage.ID) then
    Result := not VariantPage.Values[0];
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ExistingTargets: String;
  NormalizedInstallDir: String;
  NormalizedApiUrl: String;
  SkipVerificationNow: Boolean;
begin
  Result := True;

  if CurPageID = wpSelectDir then
  begin
    NormalizedInstallDir := NormalizeSelectedInstallDir(WizardDirValue());
    if NormalizedInstallDir = '' then
    begin
      MsgBox(CustomMessage('PathNotDetected'), mbError, MB_OK);
      Result := False;
    end;
    if CompareText(LastVariantSelectionSyncDir, NormalizedInstallDir) <> 0 then
      LastVariantSelectionSyncDir := '';
    WizardForm.DirEdit.Text := NormalizedInstallDir;
  end
  else if CurPageID = VariantPage.ID then
  begin
    if not VariantPage.Values[0] and not VariantPage.Values[1] then
    begin
      MsgBox(CustomMessage('VariantWarning'), mbError, MB_OK);
      Result := False;
    end;
  end
  else if CurPageID = ConfigPage.ID then
  begin
    SkipVerificationNow := SkipVerificationRequested;
    SkipVerificationRequested := False;

    if Trim(ModelEdit.Text) = '' then
    begin
      MsgBox(CustomMessage('EmptyModel'), mbError, MB_OK);
      Result := False;
      exit;
    end;
    if Trim(ApiUrlEdit.Text) = '' then
    begin
      MsgBox(CustomMessage('EmptyApiUrl'), mbError, MB_OK);
      Result := False;
      exit;
    end;

    if TryResolveCallableChatApiUrl(Trim(ApiUrlEdit.Text), NormalizedApiUrl) then
      ApiUrlEdit.Text := NormalizedApiUrl
    else if not SkipVerificationNow then
    begin
      MsgBox(CustomMessage('ChatEndpointRequiredError'), mbError, MB_OK);
      Result := False;
      exit;
    end
    else
      ApiUrlEdit.Text := Trim(ApiUrlEdit.Text);

    if VerifiedConfigFingerprint <> BuildConfigFingerprint then
    begin
      if SkipVerificationNow then
      begin
        VerifiedConfigFingerprint := '';
      end
      else
        Result := RunVerification;
    end;
  end
  else if CurPageID = DelayPage.ID then
  begin
    Result := IsNonNegativeIntegerText(Trim(DelayPage.Values[0]));
    if not Result then
      MsgBox(CustomMessage('InvalidNumber'), mbError, MB_OK);
  end
  else if Assigned(ContextPage) and (CurPageID = ContextPage.ID) then
  begin
    Result := IsNonNegativeIntegerText(Trim(ContextSubtitleCountEdit.Text));
    if not Result then
      MsgBox(CustomMessage('InvalidNumber'), mbError, MB_OK);
  end
  else if CurPageID = wpReady then
  begin
    ExistingTargets := GetExistingTargetFilesText;
    if ExistingTargets <> '' then
      Result := MsgBox(CustomMessage('OverwritePrompt') + #13#10#13#10 + ExistingTargets, mbConfirmation, MB_YESNO) = IDYES;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if Assigned(VariantPage) and (CurPageID = VariantPage.ID) and
     (CompareText(LastVariantSelectionSyncDir, RemoveBackslashUnlessRoot(Trim(WizardDirValue()))) <> 0) then
    SyncVariantSelectionFromInstallDir(WizardDirValue());

  if Assigned(ConfigPage) and (CurPageID = ConfigPage.ID) then
    WizardForm.NextButton.Caption := CustomMessage('VerifyAndContinueButton')
  else if CurPageID = wpReady then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
  else if CurPageID = wpFinished then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
  else
    WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    if not PerformInstall then
      RaiseException(CustomMessage('InstallFailure') + #13#10 + LastInstallError);
  end;
end;
