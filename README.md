## Bootstrap repository

This repository contains a small, modular framework to bootstrap a macOS machine with the tools and configuration you want. The framework is intentionally simple and designed around these principles:

- Keep module logic and configuration colocated: each module has its own directory under `scripts/modules/` with an `install.sh` and any repo-side config templates.
- Let modules declare where their configuration files live on the system (so the repo doesn't need to hardcode paths for every module).
- Safe updates: `update_configs.sh` reads the declared config paths (but does not source install scripts) and copies system files back into the repo for review/commit.
- Portability: scripts avoid Bash features not available in macOS' default Bash (e.g. no reliance on `readarray`), so they work out-of-the-box.

**What the scripts do**

- `bootstrap.sh` (at repository root): orchestrates the installation by discovering modules in `scripts/modules/` and running each module's `install.sh` in turn.
- `update_configs.sh` (at repository root): discovers modules, reads the `CONFIG_FILES=(...)` array from each module's `install.sh` (or falls back to a legacy `CONFIG_FILE` assignment), expands the paths, and copies the system files into the corresponding file(s) in the module directory (using the basename).
- `scripts/lib/utils.sh`: shared helpers (logging, checks, and a `get_modules()` helper that lists module directories containing `install.sh`).

**Design decisions**

- Config declaration lives in the module `install.sh`: each module should declare `CONFIG_FILES=("$HOME/..." ...)` so the module itself knows where its system config files belong. This keeps module-specific knowledge colocated with the installation logic.
- `update_configs.sh` parses (but does not source) the `install.sh` to extract `CONFIG_FILES`. Parsing avoids executing install logic while still letting the module declare config paths.
- The scripts take a conservative approach: the install scripts copy files from the repo into the system only if the repo-side file exists; the update script copies system files into the repo so you can review and commit changes.
- Portability: the scripts avoid Bash features missing from macOS default Bash and use portable patterns for reading lists and expanding variables.

**How modules are discovered**

- Modules live in `scripts/modules/` and must be directories containing an executable `install.sh`.
- A helper function `get_modules()` (in `scripts/lib/utils.sh`) returns the names of module directories that include `install.sh`.

**How to add a new module**

- Create a new directory under `scripts/modules/your_module_name`.
- Add an `install.sh` script (make it executable). The script should perform the installation tasks for the module and, if it manages configuration files, declare them with a `CONFIG_FILES` array. Example:

```
#!/bin/bash
MODULE_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Install package (example)
brew install somepackage

# Declare repo -> system config mappings. Repo files should be present
# at `scripts/modules/your_module_name/<basename>` and will be copied to
# the corresponding system path when the module runs.
CONFIG_FILES=(
  "$HOME/.config/somepackage/config.toml"
)

for cfg in "${CONFIG_FILES[@]}"; do
  repo_file="$MODULE_DIR/$(basename "$cfg")"
  if [[ -f "$repo_file" ]]; then
    mkdir -p "$(dirname "$cfg")"
    cp "$repo_file" "$cfg"
  fi
done

```

- Add any repo-side config templates (for example, `starship.toml`, `.zsh_plugins.txt`, or `config`) into the module directory with the same basename as the final system file.
- Make sure `install.sh` is executable: `chmod +x scripts/modules/your_module_name/install.sh`.

**Running**

- To perform the bootstrap installation:

```
bash bootstrap.sh
```

- To pull existing system configs into the repo for review:

```
bash update_configs.sh
```

After running `update_configs.sh` use `git status` and `git diff` to review the copied files before committing.

For starters, the following should be installed:

- XCode, in support of Homebrew
- [Homebrew](https://brew.sh/)
- [Antidote](https://github.com/mattmc3/antidote), via Homebrew
- [Starship](https://starship.rs/), via Homebrew
- [Ghostty](https://ghostty.org/docs/install/binary#macos), via Homebrew
- [fastfetch](https://github.com/fastfetch-cli/fastfetch), via Homebrew
- [Karabiner Elements](https://github.com/pqrs-org/Karabiner-Elements), via Homebrew
- [Obsidian](https://obsidian.md/), via Homebrew
- [Keka](https://www.keka.io/en/), via Homebrew
- [Rectangle](https://rectangleapp.com/), via Homebrew