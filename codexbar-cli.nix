{ lib, stdenvNoCC, fetchurl, autoPatchelfHook, curl, libxml2_13, sqlite, stdenv }:

let
  pname = "codexbar-cli";
  version = "0.56.1";

  assets = {
    x86_64-linux = {
      name = "CodexBarCLI-v${version}-linux-x86_64.tar.gz";
      hash = "sha256-Eft5qxoHYN/ueROgPR09+Pmf7H0IDC76y4i0UJ8t7a8=";
    };
    aarch64-linux = {
      name = "CodexBarCLI-v${version}-linux-aarch64.tar.gz";
      hash = "sha256-mx/B+9Deu1UTzaBXfVPyRdZAYWpGeR6NzBInCJAC09w=";
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
