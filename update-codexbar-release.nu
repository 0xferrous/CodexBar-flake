#!/usr/bin/env nix-shell
#! nix-shell -i nu -p nushell nix nix-prefetch

const owner = "steipete"
const repo = "CodexBar"
const package_file = "codexbar-cli.nix"
const arches = {
  x86_64_linux: "linux-x86_64"
  aarch64_linux: "linux-aarch64"
}

def latest-release [] {
  http get $"https://api.github.com/repos/($owner)/($repo)/releases/latest" --headers {
    Accept: "application/vnd.github+json"
    User-Agent: "codexbar-flake-updater"
  }
  | get tag_name
  | str replace --regex '^v' ''
}

def prefetch-sri [url: string] {
  let raw_hash = (^nix-prefetch-url --type sha256 $url | str trim)
  ^nix hash to-sri --type sha256 $raw_hash | str trim
}

def replace-once [pattern: string, replacement: string] {
  let text = $in
  let updated = ($text | str replace --regex $pattern $replacement)
  if $updated == $text {
    error make { msg: $"Pattern not found: ($pattern)" }
  }
  $updated
}

def asset-url [version: string, suffix: string] {
  let asset_name = $"CodexBarCLI-v($version)-($suffix).tar.gz"
  $"https://github.com/($owner)/($repo)/releases/download/v($version)/($asset_name)"
}

def main [] {
  let version = (latest-release)
  let text = (open --raw $package_file)
  let current_version = (
    $text
    | parse --regex 'version = "(?<version>[^"]+)";'
    | get 0.version
  )

  if $current_version == $version {
    print $"Already up to date: ($version)"
    return
  }

  let x86_hash = (prefetch-sri (asset-url $version $arches.x86_64_linux))
  print $"Prefetched x86_64-linux: ($x86_hash)"

  let aarch64_hash = (prefetch-sri (asset-url $version $arches.aarch64_linux))
  print $"Prefetched aarch64-linux: ($aarch64_hash)"

  let updated = (
    $text
    | replace-once 'version = "[^"]+";' $"version = \"($version)\";"
    | replace-once '(x86_64-linux = \{\n\s+name = "CodexBarCLI-v\$\{version\}-linux-x86_64.tar.gz";\n\s+hash = ")[^"]+(";)' $"${1}($x86_hash)${2}"
    | replace-once '(aarch64-linux = \{\n\s+name = "CodexBarCLI-v\$\{version\}-linux-aarch64.tar.gz";\n\s+hash = ")[^"]+(";)' $"${1}($aarch64_hash)${2}"
  )

  $updated | save --force $package_file
  print $"Updated ($package_file) from ($current_version) to ($version)"
}
