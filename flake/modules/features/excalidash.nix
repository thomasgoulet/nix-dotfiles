# ExcaliDash, self hosted Excalidraw (https://github.com/zimengxiong/excalidash)
# running as two containers sharing a dedicated docker network.
{
  den,
  inputs,
  ...
}:
{
  den.aspects.excalidash = {
    includes = [
      den.aspects.docker
    ];

    nixos = {
      imports = [
        (inputs.import-tree ./excalidash)
      ];
    };
  };
}
