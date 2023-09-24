{ lib
, fetchCrate
, rustPlatform
, darwin
, stdenv
, bluez
, pkg-config
, dbus
}:

rustPlatform.buildRustPackage rec {
  pname = "blendr";
  version = "1.2.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-lpAune7VUZLA+nTouK3UKEkPcj2Kr67vZ+ppCuRqvDU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optionals stdenv.isLinux [
    bluez.dev
    dbus.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreBluetooth
  ];

  cargoSha256 = "sha256-mkNFoO6aXsn56EScYHBuhcwUAgIc6vwcbObn9XeQWGU=";

  doCheck = true;

  meta = with lib; {
    description = "The hacker's BLE (bluetooth low energy) browser terminal app";
    homepage = "https://github.com/dmtrKovalenko/blendr";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
