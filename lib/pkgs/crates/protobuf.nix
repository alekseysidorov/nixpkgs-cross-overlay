{ mkEnvHook
, pkgs
}:
let
  protobuf = pkgs.pkgsBuildHost.protobuf;
in
mkEnvHook {
  name = "cargo-audiopus_sys";

  propagatedBuildInputs = [
    # Protoc compiler
    protobuf
  ];

  envVariables = {
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
  };
}
