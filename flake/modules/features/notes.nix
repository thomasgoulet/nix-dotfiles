# Note taking with zk (https://zk-org.github.io/zk).
{
  den,
  ...
}:
{
  den.aspects.notes = { ... }: {

    includes = [
      # zk's pager and fzf preview call bat and less.
      den.aspects.terminal
    ];

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        home.packages = [
          pkgs.tuxedo
        ];

        home.sessionVariables = {
          TODO_DIR = "${config.home.homeDirectory}/notebook";
          TODO_FILE = "${config.home.homeDirectory}/notebook/tasks.txt";
          ZK_NOTEBOOK_DIR = "${config.home.homeDirectory}/notebook";
          ZK_SHELL = "/bin/bash";
        };

        programs.zk = {
          enable = true;
          settings = {
            note = {
              language = "en";
              default-title = "untitled";
              filename = "{{format-date now '%Y-%m-%d'}}-{{slug title}}";
              template = "default.md";
              exclude = [ "drafts/*" ];
              id-charset = "numbers";
              id-length = 5;
            };

            extra = {
              id = "{{id}}";
            };

            format.markdown = {
              link-format = "wiki";
              hashtags = true;
              colon-tags = true;
              multiword-tags = false;
            };

            tool = {
              pager = "less -FIRX";
              fzf-preview = "bat -p --color always {-1}";
            };

            lsp.diagnostics = {
              wiki-title = "none";
              dead-link = "error";
              self-link = "error";
              missing-backlink = {
                level = "hint";
                position = "bottom";
              };
            };

            alias = {
              config = "hx $ZK_NOTEBOOK_DIR/.zk/config.toml ~/.config/zk/config.toml";
              e = "zk edit -i $@";
              last = "zk edit --limit 1 --sort modified- $@";
              list = "zk list -q -f oneline $@";
            };
          };
        };
      };
  };
}
