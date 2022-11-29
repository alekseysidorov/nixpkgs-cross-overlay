# Build all cross packages supported by this overlay
{ mkShell
, pkgs
}:

pkgs.stdenv.mkDerivation {
  name = "cross-packages-all";
  allowSubstitutes = false;
  strictDeps = true;

  buildInputs = with pkgs; [
    rdkafka
    rocksdb
    libopus
    bash
    bashInteractive
    coreutils

    rustCrossHook
    rustBuildHostDependencies
  ]
  # Build also all cargo deps
  ++ cargoDeps.all;

  # Make it buildable, to make it possible to upload it to cache
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    echo "''${buildInputs}"        > $out/inputs.txt
  '';
}
