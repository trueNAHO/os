{
  config,
  lib,
  ...
}: {
  options.modules.nixos.services.openssh.enable =
    lib.mkEnableOption
    "the OpenSSH secure shell daemon, which allows secure remote logins.";

  config = lib.mkIf config.modules.nixos.services.openssh.enable {
    services.openssh = {
      enable = true;

      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
    };
  };
}
