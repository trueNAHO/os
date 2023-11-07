{
  config,
  lib,
  ...
}: {
  options.modules.nixos.sound.enable = lib.mkEnableOption "sound";

  config = lib.mkIf config.modules.nixos.sound.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };

    sound.enable = true;
  };
}
