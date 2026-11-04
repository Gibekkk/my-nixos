{ pkgs , ... }:
let
    mkScript = name: deps:
        pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = deps;
            text = builtins.readFile ./scripts/${name}.sh;
        };
in
{
    environment.systemPackages = [
        (mkScript "gpush" [ pkgs.git ])
	(mkScript "nshell" [ ])
    ];
}
