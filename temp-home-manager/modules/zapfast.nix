{ inputs, ... }: {
  imports = [ inputs.zapfast.homeManagerModules.default ];

  programs.zapfast = {
    enable = true;
    settings = {
      check_for_updates = false;
      theme = "dark";
    };
  };
}
