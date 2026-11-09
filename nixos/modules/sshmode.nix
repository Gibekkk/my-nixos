{ config, lib, pkgs, ... }:
let
  cfg = config.services.sshmode;

  mkScript = name: deps:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = deps;
      text = builtins.readFile ./scripts/${name}.sh;
    };

  sshmode = mkScript "sshmode" (with pkgs; [ systemd coreutils gnugrep gawk iproute2 ]);
  sshmode-gui = mkScript "sshmode-gui" [ pkgs.kdePackages.kdialog sshmode ];
in
{
  options.services.sshmode.default = lib.mkOption {
    type = lib.types.enum [ "off" "tailscale" "public" ];
    default = "tailscale";
    description = "SSH mode applied at every boot.";
  };

  config = {
    services.openssh = {
      enable = true;
      startWhenNeeded = true;   # sshd.socket + per-connection sshd@
      openFirewall = true;      # exposure is decided by the socket, not the firewall
      settings = {
        PermitRootLogin = "no";
        AllowUsers = [ "gibekkk" ];   # gibets cannot log in over SSH
      };
    };

    systemd.sockets.sshd = {
      after = [ "tailscaled.service" ];
      partOf = [ "tailscaled.service" ];
      # boot default
      socketConfig = lib.mkIf (cfg.default == "tailscale") { BindToDevice = "tailscale0"; };
      wantedBy = lib.mkIf (cfg.default == "off") (lib.mkForce [ ]);
    };

    environment.etc."sshmode/default".text = cfg.default;

    environment.systemPackages = [
      sshmode
      sshmode-gui
      (pkgs.makeDesktopItem {
        name = "sshmode-gui";
        desktopName = "SSH Mode";
        exec = "sshmode-gui";
        icon = "network-server";
        categories = [ "Network" ];
      })
    ];
  };
}
