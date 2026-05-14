{ inputs, ... }:
{
  perSystem = { system, ... }: {
    packages.backlog-md = inputs.backlog-md.packages.${system}.default;
  };
}
