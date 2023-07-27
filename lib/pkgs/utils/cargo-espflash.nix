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
  version = "2.0.1";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-VWL1qQPJYpl/KWrcgsr4/f6jjo36XsF0bkCVTxqfl20=";
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

  cargoSha256 = "sha256-tO4etRYwbVZ66VtwVz5XhREhUXzXbyzK5Jk1hlGs8Iw=";

  meta = with lib; {
    description = "Cargo subcommand for flashing Espressif devices over serial";
    homepage = "https://github.com/esp-rs/espflash";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
