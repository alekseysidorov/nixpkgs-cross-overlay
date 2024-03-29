{ lib, writeTextFile, makeSetupHook }:

{ name
, env ? { }
, substitutions ? { }
  # hooks go in nativeBuildInput so these will be nativeBuildInput
, propagatedBuildInputs ? [ ]
  # these will be buildInputs
, depsTargetTargetPropagated ? [ ]
, passthru ? { }
}:
let
  exportList = lib.mapAttrsToList (name: value: "export ${name}=${builtins.toString value}") env;

  shellScript = writeTextFile {
    name = "env-hook";
    executable = true;
    text = lib.concatStringsSep "\n" exportList;
  };
in
makeSetupHook
{
  inherit name
    propagatedBuildInputs
    depsTargetTargetPropagated
    substitutions
    passthru;
}
  shellScript
