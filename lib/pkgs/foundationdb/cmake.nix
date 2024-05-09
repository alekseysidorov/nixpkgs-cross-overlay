# This builder is for FoundationDB CMake build system.

{ lib
, fetchFromGitHub
, cmake
, ninja
, python3
, openjdk8
, mono
, pkg-config
, msgpack-cxx
, toml11
, darwin

, gccStdenv
, llvmPackages
, stdenv
, useClang ? true
, ...
}:

let
  stdenv = if useClang then llvmPackages.libcxxStdenv else gccStdenv;
  dylib_suffix = stdenv.hostPlatform.extensions.sharedLibrary;

  # Only even numbered versions compile on aarch64; odd numbered versions have avx enabled.
  avxEnabled = version:
    let
      isOdd = n: lib.trivial.mod n 2 != 0;
      patch = lib.toInt (lib.versions.patch version);
    in
    isOdd patch;

  makeFdb =
    { version
    , hash
    , rev ? "refs/tags/${version}"
    , officialRelease ? false
    , patches ? [ ]
    , boost
    , ssl
    }: stdenv.mkDerivation {
      pname = "foundationdb";
      inherit version;

      src = fetchFromGitHub {
        owner = "apple";
        repo = "foundationdb";
        inherit rev hash;
      };

      buildInputs = [ ssl boost msgpack-cxx toml11 ]
        ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Foundation ]
      ;

      nativeBuildInputs = [ pkg-config cmake ninja python3 openjdk8 mono ];

      separateDebugInfo = true;
      dontFixCmake = false;

      cmakeFlags = [
        (lib.optionalString officialRelease "-DFDB_RELEASE=TRUE")

        # Disable CMake warnings for project developers.
        "-Wno-dev"

        # CMake Error at fdbserver/CMakeLists.txt:332 (find_library):
        # >   Could not find lz4_STATIC_LIBRARIES using the following names: liblz4.a
        "-DSSD_ROCKSDB_EXPERIMENTAL=FALSE"

        # FoundationDB's CMake is hardcoded to pull in jemalloc as an external
        # project at build time.
        "-DUSE_JEMALLOC=FALSE"
        # FIXME: why can't openssl be found automatically?
        "-DOPENSSL_USE_STATIC_LIBS=FALSE"
        "-DOPENSSL_CRYPTO_LIBRARY=${ssl.out}/lib/libcrypto${dylib_suffix}"
        "-DOPENSSL_SSL_LIBRARY=${ssl.out}/lib/libssl${dylib_suffix}"
      ];

      hardeningDisable = [ "fortify" ];

      env.NIX_CFLAGS_COMPILE = toString [
        # Needed with GCC 12
        "-Wno-missing-template-keyword"
        # Needed to compile on aarch64
        (lib.optionalString stdenv.isAarch64 "-march=armv8-a+crc")
      ];

      inherit patches;

      # the install phase for cmake is pretty wonky right now since it's not designed to
      # coherently install packages as most linux distros expect -- it's designed to build
      # packaged artifacts that are shipped in RPMs, etc. we need to add some extra code to
      # cmake upstream to fix this, and if we do, i think most of this can go away.
      postInstall = ''
        mv $out/sbin/fdbmonitor $out/bin/fdbmonitor
        mkdir $out/libexec && mv $out/usr/lib/foundationdb/backup_agent/backup_agent $out/libexec/backup_agent
        mv $out/sbin/fdbserver $out/bin/fdbserver

        rm -rf $out/etc $out/lib/foundationdb $out/lib/systemd $out/log $out/sbin $out/usr $out/var

        # move results into multi outputs
        mkdir -p $dev $lib
        mv $out/include $dev/include
        mv $out/lib $lib/lib

        # java bindings
        mkdir -p $lib/share/java
        mv lib/fdb-java-*.jar $lib/share/java/fdb-java.jar
      '';

      outputs = [ "out" "dev" "lib" ];

      meta = with lib; {
        description = "Open source, distributed, transactional key-value store";
        homepage = "https://www.foundationdb.org";
        license = licenses.asl20;
        platforms = [ "x86_64-linux" ]
          ++ lib.optionals (!(avxEnabled version)) [ "aarch64-linux" "aarch64-darwin" ];
        maintainers = with maintainers; [ thoughtpolice lostnet ];
      };
    };
in
makeFdb
