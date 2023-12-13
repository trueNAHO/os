{
  config,
  lib,
  pkgs,
  ...
}: {
  options.modules.environment.systemPackages.os.enable =
    lib.mkEnableOption "os";

  config = lib.mkIf config.modules.environment.systemPackages.os.enable {
    environment.systemPackages = [
      (pkgs.stdenv.mkDerivation
        {
          installPhase = let
            manDirectory = "share/man";
            tmpDirectory = "tmp_share_man";
          in ''
            mkdir --parent "$out/${tmpDirectory}"

            trap "rm --force --recursive $out/${tmpDirectory}" EXIT

            ${pkgs.fd.pname} \
              --extension adoc \
              -X \
              ${pkgs.asciidoctor-with-extensions.meta.mainProgram} \
              --backend manpage \
              --destination-dir "$out/${tmpDirectory}"

            ${pkgs.fd.pname} --type file . "$out/${tmpDirectory}" |
              while read -r file; do
                filename="$(basename --suffix .gz "$file")"
                output_directory="$out/${manDirectory}/man''${filename##*.}"

                mkdir --parent "$output_directory"
                mv "$file" "$output_directory"
              done
          '';

          name = "os";
          nativeBuildInputs = with pkgs; [asciidoctor-with-extensions fd];
          src = ../../../..;
        })
    ];
  };
}
