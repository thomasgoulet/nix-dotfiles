{
  config,
  lib,
  pkgs,
  ...
}:
let
  drydock = pkgs.rustPlatform.buildRustPackage rec {
    pname = "drydock";
    version = "1.1.4";

    src = pkgs.fetchFromGitHub {
      owner = "yetidevworks";
      repo = "drydock";
      tag = "v${version}";
      hash = "sha256-23b8UEw8Lo9dj3JFKV36eXUhbzjfRRbXoe9xminIzVg=";
    };
    nativeCheckInputs = [ pkgs.git ];

    cargoHash = "sha256-IA+CKBw0P6uRPg9f41nZxERSVmY4FRV8vlyutuXhoHE=";

    meta = {
      description = "Live dashboard for a fleet of git repos: what's uncommitted, unpushed, and unreleased, at a glance";
      homepage = "https://github.com/yetidevworks/drydock";
      license = lib.licenses.mit;
      mainProgram = "drydock";
    };
  };
in
{
  home.packages = [ drydock ];

  home.file."${config.home.homeDirectory}/.config/drydock/config.toml" = {
    source = (pkgs.formats.toml { }).generate "drydock-settings.toml" {
      exclude = [ ];
      follow_nested_repos = false;
      follow_symlinks = false;
      max_depth = 4;
      prune = [ ];
      refresh = {
        debounce = "1s";
        interval = "5m";
        watch = true;
      };
      release = {
        changelog_files = [
          "CHANGELOG.md"
          "CHANGELOG"
          "changelog.md"
        ];
        max_subjects = 30;
        read_changelog = true;
        tag_pattern = "*[0-9]*";
      };
      remote = {
        concurrency = 2;
        fetch = true;
        interval = "30m";
        timeout = "20s";
      };
      roots = [
        "~/repos"
      ];
      status = {
        max_age = "1h";
        max_files = 200;
        untracked = "normal";
      };
      ui = {
        columns = [
          "group"
          "repo"
          "branch"
          "state"
          "fetched"
          "age"
          "changes"
          "ahead"
          "behind"
          "tag"
          "release"
        ];
        default_filters = [ ];
        default_since = "";
        default_sort = "activity";
        editor_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
        file_manager_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
        git_client_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
        terminal_command = [
          "herdr"
          "workspace"
          "create"
          "--cwd"
          "{path}"
          "--focus"
        ];
      };
      visibility = {
        concurrency = 4;
        enabled = false;
        interval = "24h";
        timeout = "10s";
      };
    };
  };
}
