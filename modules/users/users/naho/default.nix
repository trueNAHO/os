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

    insecureInitialHashedPassword = lib.mkEnableOption ''
      the insecure default initial hashed password for
      ${cfg.users.users.naho.description}'s user account. Do not use this option
      for online accounts.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;

    users.users.naho = lib.mkMerge [
      {
        description = "NAHO";
        extraGroups = ["networkmanager" "wheel"];
        isNormalUser = true;
        shell = pkgs.fish;
      }

      (lib.mkIf cfg.insecureInitialHashedPassword {
        initialHashedPassword = "$y$j9T$YJDW55iEpE5Fro9oJYwqQ.$.B4KpKNRq9JkDO1GKtlVq/78CJJboZ1GjEt4uvQbvm6";
      })
    ];
  };
}
