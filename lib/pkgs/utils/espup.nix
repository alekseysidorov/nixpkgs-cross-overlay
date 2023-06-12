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
  version = "0.4.1";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-VqeUG2gyAnzedzuCqwlGI9F5FL+z7OuaR2pv8J5J39M=";
  };

  nativeBuildInputs = [ pkg-config perl ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  cargoSha256 = "sha256-GYhF6VDBAieZbu4x9EiQVVJkmx0aRYK0xwGGP0nuVGc=";

  # thread 'tests::test_get_export_file' panicked at 'assertion failed: get_export_file(Some(home_dir)).is_err()', src/main.rs:542:9
  doCheck = false;

  meta = with lib; {
    description = "A linker proxy tool";
    homepage = "https://github.com/esp-rs/espup";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
