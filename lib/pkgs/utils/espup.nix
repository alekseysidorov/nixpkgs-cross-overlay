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
  version = "0.3.2";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-eXWfzttblp7NqqdmqqBSYex9WpGbJlEJ6FLW8p7L3FA=";
  };

  nativeBuildInputs = [ pkg-config perl ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  cargoSha256 = "sha256-zeodLRnUFgjO77oPLQnD5P62vM9HKR7jrq4ZBSGBWGk=";

  # thread 'tests::test_get_export_file' panicked at 'assertion failed: get_export_file(Some(home_dir)).is_err()', src/main.rs:542:9
  doCheck = false;

  meta = with lib; {
    description = "A linker proxy tool";
    homepage = "https://github.com/esp-rs/espup";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
