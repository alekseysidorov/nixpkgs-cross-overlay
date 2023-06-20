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
  version = "2.0.0-rc.4";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-BMGKFDkgme2rnrU2mrk/OLnCg5GigTcg7EGEE1zJ1E8=";
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

  cargoSha256 = "sha256-QD74VpOtkp17g4gW8Q70V2aa6RGEuEPsT2urZKFeK2g=";

  # Failed to get partition table
  doCheck = false;

  meta = with lib; {
    description = "A command-line tool for flashing Espressif devices over serial";
    homepage = "https://github.com/esp-rs/espflash";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
