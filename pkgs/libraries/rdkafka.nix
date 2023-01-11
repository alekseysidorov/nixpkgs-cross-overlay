{ lib
, stdenv
, fetchFromGitHub
, zlib
, zstd
, pkg-config
, python3
, openssl
, cmake
, lz4
, enableShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "rdkafka";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "edenhill";
    repo = "librdkafka";
    rev = "v${version}";
    sha256 = "sha256-G6rTvb2Z2O1Df5/6upEB9Eh049sx+LWhhDKvsZdDqsc=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ zlib zstd openssl ];

  cmakeFlags = [
    "-DRDKAFKA_BUILD_TESTS=0"
    "-DRDKAFKA_BUILD_EXAMPLES=0"
  ] ++ lib.optional (!enableShared) "-DRDKAFKA_BUILD_STATIC=1";

  meta = with lib; {
    description = "librdkafka - Apache Kafka C/C++ client library";
    homepage = "https://github.com/edenhill/librdkafka";
    license = licenses.bsd2;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ commandodev ];
  };
}
