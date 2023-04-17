{ lib, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "ldproxy";
  version = "0.3.3";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-XLfa40eMkeUL544gDqZYbly2E5Mrogn7v24D8u/wjkg=";
  };


  cargoSha256 = "sha256-h7WOslRfu7cQ/af/b6C8gN2QrEt2SLxNnGeEv6bKj3E=";

  meta = with lib; {
    description = "A linker proxy tool";
    homepage = "https://github.com/esp-rs/embuild";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
