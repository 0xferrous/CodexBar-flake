# CodexBar flake

Nix flake for the Linux `codexbar` CLI from [steipete/CodexBar](https://github.com/steipete/CodexBar).

This repo packages the prebuilt upstream Linux release tarballs for:

- `x86_64-linux`
- `aarch64-linux`

## Usage

Run it directly:

```bash
nix run github:0xferrous/CodexBar-flake
```

Run from this checkout:

```bash
nix run .
```

Build it:

```bash
nix build .#codexbar-cli
```

Enter a shell with the package available:

```bash
nix develop
```

## Outputs

The flake exposes:

- `packages.default`
- `packages.codexbar-cli`
- `apps.default`
- `overlays.default`
- `devShells.default`

## Updating

Update manually:

```bash
./update-codexbar-release.nu
```

The updater script:

- checks the latest GitHub release from `steipete/CodexBar`
- updates `version`
- refreshes the `x86_64-linux` and `aarch64-linux` hashes

## Automation

GitHub Actions runs the updater once per day at `03:00 UTC` and opens or updates a pull request if a new upstream release is available.
