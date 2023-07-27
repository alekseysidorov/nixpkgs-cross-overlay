{ lib
, fetchCrate
, rustPlatform
, darwin
, stdenv
, pkg-config
, perl
, openssl
, curl
, libgit2
, udev
}:

rustPlatform.buildRustPackage rec {
  pname = "espflash";
  version = "2.0.1";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-pk/oDBUcnz4ELRlASvNBjE1m2uys+1KItM4lsdFcoLg=";
  };

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    openssl
    curl
    libgit2
  ] ++ lib.optionals stdenv.isLinux [
    udev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  cargoSha256 = "sha256-RpLhhrcvfWGy/u0ytXL5waLN0ebyklU7cS8vXOWFh4A=";

  # Failed to get partition table
  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for flashing Espressif devices over serial";
    homepage = "https://github.com/esp-rs/espflash";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
