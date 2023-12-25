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
            man = "$man/share/man";
            tmp = ".${man}";
          in ''
            mkdir --parent "$out" "${man}" "${tmp}"

            trap "rm --force --recursive ${tmp}" EXIT

            ${pkgs.fd.pname} \
              --extension adoc \
              -X \
              ${pkgs.asciidoctor-with-extensions.meta.mainProgram} \
              --backend manpage \
              --destination-dir "${tmp}"

            ${pkgs.fd.pname} --type file . "${tmp}" |
              while read -r file; do
                filename="$(basename --suffix .gz "$file")"
                output_directory="${man}/man''${filename##*.}"

                mkdir --parent "$output_directory"
                mv "$file" "$output_directory"
              done

          '';

          name = "os";
          nativeBuildInputs = with pkgs; [asciidoctor-with-extensions fd];
          outputs = ["out" "man"];
          src = ../../../..;
        })
    ];
  };
}
