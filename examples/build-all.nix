# Build all cross packages supported by this overlay
{ mkShell
, pkgs
}:

mkShell {
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
}
