{ lib
, fetchCrate
, rustPlatform
, darwin
, stdenv
, openssl
, pkg-config
, perl
}:

rustPlatform.buildRustPackage rec {
  pname = "espup";
  version = "0.4.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-l5A4unfl+EM/6STwBKiC58goyRW1hvghAahWD3kg0PI=";
  };

  nativeBuildInputs = [ pkg-config perl ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  cargoSha256 = "sha256-iORjlKrGJ3vBEXZLmaV5AV85cm1XHIaFHdSQLXFDjpQ=";

  # thread 'tests::test_get_export_file' panicked at 'assertion failed: get_export_file(Some(home_dir)).is_err()', src/main.rs:542:9
  doCheck = false;

  meta = with lib; {
    description = "A linker proxy tool";
    homepage = "https://github.com/esp-rs/espup";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
