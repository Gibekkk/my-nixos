{
	services = {
		desktopManager = {
			plasma6.enable = true;
		};

		displayManager = {
			sddm = {
				enable = true;
				wayland = true;
			};
			defaultSession = "plasma";
		};
	};
}
