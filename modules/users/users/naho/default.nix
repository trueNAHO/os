{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.users.users.naho;
in {
  imports = [../../../programs/hyprland];

  options.modules.users.users.naho = {
    enable =
      lib.mkEnableOption
      "${cfg.users.users.naho.description}'s user account";

    enableInsecurePassword = lib.mkEnableOption ''
      the insecure default initial hashed password for
      ${cfg.users.users.naho.description}'s user account. Do not use this option
      for online accounts.
    '';

    enableUserConfigurationRequirements = lib.mkEnableOption ''
      ${cfg.users.users.naho.description}'s user configuration requirements:
      https://github.com/trueNAHO/dotfiles
    '';
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      age.secrets.usersUsersNahoPasswordFile.file = ./passwordFile.age;

      users.users.naho = {
        description = "NAHO";
        extraGroups = ["wheel"];
        isNormalUser = true;
      };
    }

    (lib.mkIf cfg.enableInsecurePassword {
      users.users.naho.hashedPasswordFile =
        config.age.secrets.usersUsersNahoPasswordFile.path;
    })

    (lib.mkIf cfg.enableUserConfigurationRequirements {
      modules.programs.hyprland.enable = true;

      programs = {
        dconf.enable = true;
        fish.enable = true;
      };

      security.pam.services.swaylock = {};
      users.users.naho.shell = pkgs.fish;
    })
  ]);
}
