{ config, lib, pkgs, ... }:
let
  nvmSrc = pkgs.fetchFromGitHub {
    owner = "jorgebucaran";
    repo = "nvm.fish";
    rev = "85cadd56f71b11574566dbd6c32e0027e361d085";
    hash = "sha256-SI30Md3OKCN5qZ3pT/ZcweB8njGZ9okJFnCLqmfmL44=";
  };

  # Global npm packages. Edit here.
  nodeGlobals = [ "typescript" "pnpm" "yarn" "yoinks" ];

  setup = pkgs.writeText "node-setup.fish" ''
    set -g nvm_default_packages ${lib.concatStringsSep " " nodeGlobals}
    set fish_function_path ${nvmSrc}/functions $fish_function_path
    source ${nvmSrc}/conf.d/nvm.fish
    nvm install lts; or echo "node setup: offline, skipping"
    set -q nvm_current_version; or exit 0
    npm install --global --no-fund --no-audit --prefer-offline $nvm_default_packages
    ln -sfn $nvm_data/$nvm_current_version $HOME/.local/share/node-current
  '';
in {
  programs.fish = {
    plugins = [ { name = "nvm"; src = nvmSrc; } ];
    interactiveShellInit = ''
      set -g nvm_default_version lts
      set -g nvm_default_packages ${lib.concatStringsSep " " nodeGlobals}
      set -q nvm_current_version; or nvm use --silent lts
    '';
  };

  # Auto install LTS on every hms. Failure never blocks the switch.
  home.activation.installNode = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH=${lib.makeBinPath (with pkgs; [ curl gnutar gzip coreutils gawk gnused gnugrep ])}:$PATH
    ${pkgs.fish}/bin/fish --no-config ${setup} || echo "node setup failed, continuing"
  '';

  # Stable symlink gives every session Node: scripts, cron, GUI apps.
  home.sessionPath = [ "$HOME/.local/share/node-current/bin" ];
  xdg.configFile."environment.d/10-node.conf".text = ''
    PATH=$HOME/.local/share/node-current/bin:$PATH
  '';
}