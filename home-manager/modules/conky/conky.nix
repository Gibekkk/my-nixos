{ pkgs, ... }:

{
  services.conky = {
    enable = true;
    # Config lives in its own file, so conky's ${...} syntax needs no Nix escaping
    extraConfig = builtins.readFile ./conky.conf;
  };

  # The config uses JetBrains Mono
  home.packages = [ pkgs.jetbrains-mono ];
}
