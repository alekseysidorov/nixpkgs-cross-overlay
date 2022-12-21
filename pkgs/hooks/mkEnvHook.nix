{ lib, writeTextFile, makeSetupHook }:

{ name, envVariables ? { }, substitutions ? { }, deps ? [ ] }:
let
  exportList = lib.mapAttrsToList (name: value: "export ${name}=${builtins.toString value}") envVariables;

  shellScript = writeTextFile {
    name = "env-hook";
    executable = true;
    text = lib.concatStringsSep "\n" exportList;
  };
in
makeSetupHook { inherit name deps substitutions; } shellScript
