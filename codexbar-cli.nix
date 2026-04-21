{ lib, stdenvNoCC, fetchurl, autoPatchelfHook, curl, libxml2_13, sqlite, stdenv }:

let
  pname = "codexbar-cli";
  version = "0.22";

  assets = {
    x86_64-linux = {
      name = "CodexBarCLI-v${version}-linux-x86_64.tar.gz";
      hash = "sha256-8zBAbEIe736aCxmfDxuuztEs/6IGy6875F9dAN7z0hc=";
    };
    aarch64-linux = {
      name = "CodexBarCLI-v${version}-linux-aarch64.tar.gz";
      hash = "sha256-n3LnDvWvaHSLvgBXDdgtxWL1hWYHyY6UnAhGoOE+04E=";
    };
  };

  asset = assets.${stdenvNoCC.hostPlatform.system}
    or (throw "${pname} is only packaged for x86_64-linux and aarch64-linux");
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v${version}/${asset.name}";
    hash = asset.hash;
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = map lib.getLib [ curl libxml2_13 sqlite ] ++ [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 CodexBarCLI $out/bin/CodexBarCLI
    install -Dm755 codexbar $out/bin/codexbar
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/codexbar --help > /dev/null
  '';

  meta = {
    description = "CLI tool to track Codex, Claude, Cursor, Gemini, and other AI provider usage limits";
    homepage = "https://github.com/steipete/CodexBar";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "codexbar";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
