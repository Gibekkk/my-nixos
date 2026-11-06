{ pkgs, ... }:
{
  programs.firefox = {
    #configPath = ".mozilla/firefox";
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;
      # path = "xxxxxxxx.default";  # see the warning below

      settings = {
        # lets userChrome.css be loaded
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # web page text
        "browser.display.use_document_fonts" = 0;
        "font.default.x-western" = "sans-serif";
        "font.name.sans-serif.x-western" = "Biscuit Glitch";
        "font.name.serif.x-western" = "Biscuit Glitch";
        "font.name.monospace.x-western" = "JetBrains Mono";
      };

      # Firefox's own interface (tabs, menus, URL bar)
      userChrome = ''
        :root {
          font-family: "Biscuit Glitch", sans-serif !important;
        }
      '';
    };
  };
}
