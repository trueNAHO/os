{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.nixos.users.users.naho;
in {
  imports = [
    ../../../../agenix/nixosModules/default
    ../../../programs/hyprland
  ];

  options.modules.nixos.users.users.naho = {
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
      modules.agenix.nixosModules.default.enable = true;

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

    (lib.mkIf cfg.enableUserConfigurationRequirements (lib.mkMerge [
      {
        modules.nixos.programs.hyprland.enable = true;
      }

      {
        programs.dconf.enable = true;
      }

      {
        programs.fish.enable = true;
        users.users.naho.shell = pkgs.fish;
      }

      {
        programs.virt-manager.enable = true;
        users.users.naho.extraGroups = ["libvirtd"];
        virtualisation.libvirtd.enable = true;
      }

      {
        security.pam.services.swaylock = {};
      }

      {
        services.udisks2.enable = true;
      }
    ]))
  ]);
}
