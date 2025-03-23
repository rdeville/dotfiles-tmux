{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "tmuxrc";
  src = ./.;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out;
    cp -r \
      *.md \
      LICENSE* \
      tmux.conf \
      config.sh \
      config \
      plugins \
      $out
  '';
}
