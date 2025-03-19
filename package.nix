{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "tmuxdata";
  src = ./.;
  installPhase = ''
    mkdir -p $out;
    cp -r \
      tmux.conf \
      hosts \
      templates \
      $out
  '';
}
