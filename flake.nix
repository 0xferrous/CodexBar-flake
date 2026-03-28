{
  description = "Nix flake for the CodexBar CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        codexbar-cli = pkgs.callPackage ./codexbar-cli.nix { };
      in
      {
        packages = {
          inherit codexbar-cli;
          default = codexbar-cli;
        };

        apps.default = {
          type = "app";
          program = "${codexbar-cli}/bin/codexbar";
        };

        devShells.default = pkgs.mkShell {
          packages = [ codexbar-cli ];

          shellHook = ''
            echo "CodexBar CLI shell"
            echo "Run: codexbar --help"
          '';
        };
      }
    )
    // {
      overlays.default = final: _prev: {
        codexbar-cli = final.callPackage ./codexbar-cli.nix { };
      };
    };
}
