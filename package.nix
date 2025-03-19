{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "tmuxrc";
  src = ./.;
  installPhase = ''
    mkdir -p $out;
    cp -r \
      *.md \
      LICENSE* \
      tmux.conf \
      config.sh \
      plugins \
      $out
  '';
}
