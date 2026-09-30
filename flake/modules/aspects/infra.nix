{ den, ... }:
{
  den.aspects.infra = {

    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.argocd
        pkgs.dyff
        pkgs.hl-log-viewer
        pkgs.kubecolor
        pkgs.kubectl
        pkgs.kubelogin
        pkgs.kustomize
        pkgs.tenv

        (pkgs.azure-cli.withExtensions [
          pkgs.azure-cli.extensions.ssh
          pkgs.azure-cli.extensions.azure-devops
        ])
      ];

      home.sessionVariables = {
        KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code";
      };

      xdg.configFile."hl/config.toml" = {
        source = (pkgs.formats.toml { }).generate "hl-settings.toml" {
          ascii = "auto";
          fields = {
            hide = [
              "ecs.version"
              "process.pid"
              "process.thread"
              "service.name"
            ];
            ignore = [
              "_*"
            ];
            predefined = {
              caller = {
                names = [
                  "caller"
                  "CALLER"
                  "Caller"
                ];
              };
              caller-file = {
                names = [ ];
              };
              caller-line = {
                names = [ ];
              };
              level = {
                show = "always";
                variants = [
                  {
                    names = [
                      "level"
                      "LEVEL"
                      "Level"
                      "log.level"
                    ];
                    values = {
                      debug = [
                        "debug"
                      ];
                      error = [
                        "error"
                        "err"
                        "fatal"
                        "critical"
                        "panic"
                      ];
                      info = [
                        "info"
                        "information"
                      ];
                      trace = [
                        "trace"
                      ];
                      warning = [
                        "warning"
                        "warn"
                      ];
                    };
                  }
                  {
                    names = [
                      "PRIORITY"
                    ];
                    values = {
                      debug = [
                        7
                      ];
                      error = [
                        3
                        2
                        1
                      ];
                      info = [
                        6
                      ];
                      warning = [
                        5
                        4
                      ];
                    };
                  }
                ];
              };
              logger = {
                names = [
                  "logger"
                  "LOGGER"
                  "Logger"
                  "span.name"
                  "log.logger"
                ];
              };
              message = {
                names = [
                  "msg"
                  "message"
                  "MESSAGE"
                  "Message"
                ];
              };
              time = {
                names = [
                  "ts"
                  "TS"
                  "time"
                  "TIME"
                  "Time"
                  "timestamp"
                  "Timestamp"
                  "TIMESTAMP"
                  "_SOURCE_REALTIME_TIMESTAMP"
                  "__REALTIME_TIMESTAMP"
                  "@timestamp"
                ];
                show = "always";
              };
            };
          };
          formatting = {
            expansion = {
              mode = "auto";
            };
            flatten = "always";
            message = {
              format = "delimited";
            };
            prettify-field-keys = true;
            punctuation = {
              array-separator = " ";
              caller-name-file-separator = " @ ";
              field-key-value-separator = "=";
              hidden-fields-indicator = "...";
              input-name-clipping = {
                ascii = "..";
                unicode = "··";
              };
              input-name-common-part = {
                ascii = "..";
                unicode = "··";
              };
              input-name-left-separator = "";
              input-name-right-separator = {
                ascii = " | ";
                unicode = " │ ";
              };
              input-number-left-separator = "";
              input-number-prefix = "#";
              input-number-right-separator = {
                ascii = " | ";
                unicode = " │ ";
              };
              level-left-separator = "[";
              level-right-separator = "]";
              logger-name-separator = ":";
              message-delimiter = {
                ascii = "::";
                unicode = "›";
              };
              source-location-separator = {
                ascii = "-> ";
                unicode = "→ ";
              };
              string-closing-quote = "'";
              string-opening-quote = "'";
            };
          };
          input-info = "auto";
          pager = {
            candidates = [
              {
                env = {
                  delimiter = "HL_PAGER_DELIMITER";
                  follow = "HL_FOLLOW_PAGER";
                  pager = "HL_PAGER";
                };
                profiles = true;
              }
              {
                env = "PAGER";
              }
              {
                profile = "less";
              }
            ];
            profiles = [
              {
                args = [
                  "-R"
                  "--mouse"
                ];
                command = "less";
                env = {
                  LESSCHARSET = "UTF-8";
                };
                modes = {
                  follow = {
                    args = [
                      "+F"
                    ];
                    enabled = false;
                  };
                };
                name = "less";
              }
            ];
          };
          theme = "classic-plus";
          theme-overlays = [
            "@accent-italic"
          ];
          time-format = "%m-%d %T.%3N";
          time-zone = "UTC";
        };
      };

    };
  };
}
