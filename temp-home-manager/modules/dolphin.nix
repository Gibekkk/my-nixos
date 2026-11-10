{
  xdg.dataFile."kio/servicemenus/FormatUSB.desktop".source = ./dolphin/servicemenus/FormatUSB.desktop;
  xdg.dataFile."kio/servicemenus/open-as-root.desktop".source = ./dolphin/servicemenus/open-as-root.desktop;
  programs.plasma.configFile.dolphinrc = {
    General.RememberOpenedTabs = false;
    MainWindow.MenuBar = "Disabled";

    "KFileDialog Settings" = {
      "Places Icons Auto-resize" = false;
      "Places Icons Static Size" = 22;
    };

    PreviewSettings.Plugins = "imagethumbnail,kraorathumbnail,svgthumbnail,windowsexethumbnail,exrthumbnail,appimagethumbnail,ebookthumbnail,djvuthumbnail,windowsimagethumbnail,audiothumbnail,opendocumentthumbnail,cursorthumbnail,comicbookthumbnail,jpegthumbnail,directorythumbnail,fontthumbnail,blenderthumbnail,ffmpegthumbs,mobithumbnail,mltpreview,rawthumbnail,gsthumbnail";
  };
}
