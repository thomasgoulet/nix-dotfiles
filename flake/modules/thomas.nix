{ den, ... }:
{
  den.aspects.thomas = {
    includes = [ den.aspects.developer den.aspects.sysops ];

    homeManager =
      { self', inputs', ... }:
      {
        home.stateVersion = "25.11";
        programs.home-manager.enable = true;

        home.username = "thomas";
        home.homeDirectory = "/home/thomas";

        home.packages = [
          self'.packages.backlog-md
          self'.packages.oasdiff
          inputs'.nu-mcp.packages.default
        ];

        programs.git = {
          enable = true;
          settings = {
            credential.helper = "store";
            push.autoSetupRemote = true;

            core.pager = "delta";
            diff.colorMoved = "default";
            interactive.diffFilter = "delta --color-only";
            merge.conflictstyle = "diff3";

            delta = {
              dark = true;
              line-numbers = true;
              navigate = true;
              side-by-side = true;
              syntax-theme = "Catppuccin Mocha";
              blame-palette = "#1e1e2e #181825 #313244";
              hunk-header-style = "omit";
              file-style = "white";
            };
          };
        };
      };
  };
}
