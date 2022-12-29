# Fix dprint rust checks on Linux
{ stdenv
, buildFHSUserEnv
, dprint
}:
buildFHSUserEnv
{
  name = "dprint-fhs";
  targetPkgs = pkgs: ([ pkgs.dprint ]);
}
