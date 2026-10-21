{
  den,
  inputs,
  lib,
  ...
}:
let
  prompts = {
    docs = "You research documentation. Use the Context7 MCP to search official documentation, then answer the user's prompt based on what you find. Never guess — always search. Do not edit any file.";
    review = "You review the current branch against master (or main) branch. Structure your feedback in three sections: High-Level Architecture Decisions, Good Practices, Code Smells (nit & bugs). Indicate if the feedback is positive (+) or negative (-). Delegate documentation research (docs agent) when required to clarify library usage. Do not edit any file.";
  };

  mcp-servers = {
    context7 = {
      command = "context7-mcp";
    };
    nu-mcp = {
      command = "nu-mcp";
      args = [
        "--tools-dir"
        "/home/thomas/.config/nushell/tools"
        "--enable-nu"
      ];
    };
  };

  skills =
    ./_ai/skills
    |> lib.filesystem.listFilesRecursive
    |> map (file: {
      "${(lib.removeSuffix ".md" (baseNameOf file))}" = file;
    })
    |> lib.attrsets.mergeAttrsList;
in
{
  den.aspects.ai = {

    homeManager =
      {
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        pkgs-stable = inputs'.nixpkgs-stable.legacyPackages;
      in
      {
        imports = [
          (import ./_ai/opencode.nix {
            inherit
              lib
              mcp-servers
              prompts
              skills
              ;
          })
        ];

        home.packages = [
          # mcp servers
          pkgs.context7-mcp
          inputs'.nu-mcp.packages.default

          # tools
          pkgs-stable.pdf-oxide
        ];

        programs.mcp = {
          enable = true;
          servers = mcp-servers;
        };
      };
  };
}
