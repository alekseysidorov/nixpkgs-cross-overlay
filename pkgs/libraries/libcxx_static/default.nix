{ lib
, stdenv
, cmake
, llvmPackages
}:

stdenv.mkDerivation {
  name = "libcxx-static";
  src = ./.;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    llvmPackages.libcxx
    llvmPackages.libcxxabi
  ];

  installPhase = ''
    ${stdenv.cc.targetPrefix}ar t libc++_static.a
    mkdir -p $out/lib
    install -m755 -D libc++_static.a $out/lib/libc++_static.a
  '';
}
