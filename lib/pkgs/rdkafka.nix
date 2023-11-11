# More fresh rkdafka version, because rust-rdkafka wants to use the newest system library
{ lib, stdenv, fetchFromGitHub, zlib, zstd, pkg-config, python3, openssl, which, cmake, lz4 }:

stdenv.mkDerivation rec {
  pname = "rdkafka";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "confluentinc";
    repo = "librdkafka";
    rev = "v${version}";
    sha256 = "sha256-F67aKmyMmqBVG5sF8ZwqemmfvVi/0bDjaiugKKSipuA=";
  };

  nativeBuildInputs = [ pkg-config python3 which cmake ];

  buildInputs = [ zlib zstd openssl lz4 ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=strict-overflow";

  cmakeFlags = [
    "-DRDKAFKA_BUILD_TESTS=0"
    "-DRDKAFKA_BUILD_EXAMPLES=0"
  ] ++ lib.optional stdenv.targetPlatform.isStatic "-DRDKAFKA_BUILD_STATIC=1";

  postPatch = ''
    patchShebangs .
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "librdkafka - Apache Kafka C/C++ client library";
    homepage = "https://github.com/confluentinc/librdkafka";
    license = licenses.bsd2;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ commandodev ];
  };
}
