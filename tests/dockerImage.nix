{ dockerTools
, buildEnv
, hello
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
      hello
    ];
  };

  config.Cmd = [ "/bin/hello" ];
}
