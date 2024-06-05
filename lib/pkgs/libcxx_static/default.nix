{ stdenv
, cmake
, llvmPackages
}:

stdenv.mkDerivation {
  name = "libcxx-static";
  src = ./.;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    llvmPackages.libcxx
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp libc++_static.a $out/lib/libc++_static.a

    runHook postInstall
  '';
}
