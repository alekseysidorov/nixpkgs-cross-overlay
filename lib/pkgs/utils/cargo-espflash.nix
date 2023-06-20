{ lib
, rustPlatform
, fetchCrate
, pkg-config
, udev
, stdenv
, darwin
, openssl
, perl
, curl
, libgit2
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-espflash";
  version = "2.0.0-rc.4";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-ILz33pwKeH867gJrFrZzJK945cxTyAXl4Pvvqha05WE=";
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

  cargoSha256 = "sha256-SpXxTTs1re8PPqZurm+K7mPFJ2X2Jjl0j9/SmKaX1Y0=";

  meta = with lib; {
    description = "Cargo subcommand for flashing Espressif devices over serial";
    homepage = "https://github.com/esp-rs/espflash";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
