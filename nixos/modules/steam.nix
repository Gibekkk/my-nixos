{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.rocmPackages.clr.icd ];
  };

  boot.kernelParams = [
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
    "radeon.si_support=0"
    "radeon.cik_support=0"
  ];
}
