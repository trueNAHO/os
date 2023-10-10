{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.users.users.naho;
in {
  options.modules.users.users.naho = {
    enable =
      lib.mkEnableOption
      "${cfg.users.users.naho.description}'s user account";

    insecurePassword = lib.mkEnableOption ''
      the insecure default initial hashed password for
      ${cfg.users.users.naho.description}'s user account. Do not use this option
      for online accounts.
    '';
  };

  config = lib.mkIf cfg.enable {
    age.secrets.usersUsersNahoPasswordFile.file = ./passwordFile.age;
    programs.fish.enable = true;

    users.users.naho = lib.mkMerge [
      {
        description = "NAHO";
        extraGroups = ["networkmanager" "wheel"];
        isNormalUser = true;
        shell = pkgs.fish;
      }

      (lib.mkIf cfg.insecurePassword {
        hashedPasswordFile = config.age.secrets.usersUsersNahoPasswordFile.path;
      })
    ];
  };
}
