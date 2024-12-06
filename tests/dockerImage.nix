{ dockerTools
, buildEnv
, bashInteractive
, extraPkgs ? [ ]
}:

dockerTools.buildImage {
  name = "test-docker-tools";
  tag = "latest";

  copyToRoot = buildEnv {
    name = "image-root";
    pathsToLink = [ "/bin" ];
    paths = [
      # Certificates
      dockerTools.usrBinEnv
      dockerTools.binSh
      dockerTools.caCertificates
      dockerTools.fakeNss
      # Service
      bashInteractive
    ] ++ extraPkgs;
  };

  config.Cmd = [ "/bin/bash" ];
}
