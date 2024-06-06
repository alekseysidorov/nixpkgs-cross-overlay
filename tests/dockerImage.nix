{ dockerTools
, hello
}:

dockerTools.buildLayeredImage {
  name = "test-docker-tools";
  tag = "latest";

  contents = [
    # Certificates
    dockerTools.usrBinEnv
    dockerTools.binSh
    dockerTools.caCertificates
    dockerTools.fakeNss
    # Service
    hello
  ];

  config.Cmd = [ "/bin/hello" ];
}
