#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="franklin"
BINARY_NAME="franklin"

fail() { echo -e "\e[31mFail:\e[m $*" >&2; exit 1; }

list_all_versions() {
  local curl_opts=(-sL)
  [[ -n "${GITHUB_TOKEN:-}" ]] && curl_opts+=(-H "Authorization: token $GITHUB_TOKEN")
  curl "${curl_opts[@]}" "https://api.github.com/repos/tlienart/Franklin.jl/releases" 2>/dev/null | \
    grep -o '"tag_name": "[^"]*"' | sed 's/"tag_name": "v\?//' | sed 's/"$//' | sort -V
}

download_release() {
  local version="$1" download_path="$2"
  mkdir -p "$download_path"
  echo "$version" > "$download_path/VERSION"
}

install_version() {
  local install_type="$1" version="$2" install_path="$3"

  mkdir -p "$install_path/bin"

  # Create wrapper script
  cat > "$install_path/bin/franklin" << 'WRAPPER'
#!/usr/bin/env bash
julia -e "using Pkg; Pkg.activate(temp=true); Pkg.add(name="Franklin", version="__VERSION__"); using Franklin; Franklin.serve()"
WRAPPER
  sed -i "s/__VERSION__/$version/" "$install_path/bin/franklin"
  chmod +x "$install_path/bin/franklin"
}
