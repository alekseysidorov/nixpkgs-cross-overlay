{ lib
, fetchCrate
, rustPlatform
, darwin
, stdenv
, bluez
}:

rustPlatform.buildRustPackage rec {
  pname = "bluerepl";
  version = "0.1.7";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-LYWs8VjOCdjoc+A6tklVmkg0eW8m8lNIRCwZ1u7HrDc=";
  };

  buildInputs = lib.optionals stdenv.isLinux [ bluez ]
    ++
    lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.CoreBluetooth
    ];

  cargoSha256 = "sha256-BbgAVdkH3LiFVyWwRl/dE5SReDSOayZjX3Rw9vJ49Q0=";

  doCheck = true;

  meta = with lib; {
    description = "A ble client running in the terminal";
    homepage = "https://github.com/Yohannfra/bluerepl";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
