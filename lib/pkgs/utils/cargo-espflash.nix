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
  version = "2.0.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-Z2I+bV6YOWBKClVX3Q9vD9Vu1+kD1w0zcxOmrvkIEJ0=";
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

  cargoSha256 = "sha256-Wc8tc2CF/B6yPoSPry6tBSeJZzoXd3pfzijOiBnXnHA=";

  meta = with lib; {
    description = "Cargo subcommand for flashing Espressif devices over serial";
    homepage = "https://github.com/esp-rs/espflash";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
