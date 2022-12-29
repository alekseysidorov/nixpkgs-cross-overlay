# Fix dprint rust checks on Linux
{ stdenv
, buildFHSUserEnv
}:
buildFHSUserEnv
{
  name = "dprint-fhs";
  targetPkgs = pkgs: ([ pkgs.dprint-unwrapped ]);
}
