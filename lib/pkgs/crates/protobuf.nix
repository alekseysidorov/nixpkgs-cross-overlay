{ mkEnvHook
, pkgs
}:
let
  protobuf = pkgs.pkgsBuildHost.protobuf;
in
mkEnvHook {
  name = "protobuf";

  propagatedBuildInputs = [
    # Protoc compiler
    protobuf
  ];

  env = {
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
  };
}
