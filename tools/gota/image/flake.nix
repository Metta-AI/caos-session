{
  # The worker image behind `tools/gota`: std/bash's script interpreter (its
  # /worker fetches `worker1` and runs it with bash) plus what the Softmax CLIs
  # need — python 3.12, uv, CA certificates and curl.
  #
  # python312, not `python3`: coworld requires >=3.11,<3.13, and `python3` in
  # nixos-unstable moves past that. uv is told never to download an interpreter
  # (UV_PYTHON_DOWNLOADS) so a mismatch fails loudly instead of fetching one.
  #
  # Only the image lives here. The script is curried on by ../.caos-expr, so
  # editing it does not rebuild this.
  description = "caos worker image for the Softmax coworld/softmax CLIs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forSystem =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          workerRoot = pkgs.runCommand "gota-worker-root" { } ''
            mkdir -p $out
            install -m 755 ${./worker} $out/worker
          '';
        in
        pkgs.dockerTools.buildLayeredImage {
          name = "gota";
          tag = "latest";
          contents = [
            workerRoot
            pkgs.bash
            pkgs.coreutils
            pkgs.diffutils
            pkgs.gnugrep
            pkgs.findutils
            pkgs.jq
            pkgs.curl
            pkgs.cacert
            pkgs.python312
            pkgs.uv
          ];
          config = {
            Env = [
              "PATH=/bin"
              "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
              "UV_PYTHON=python3.12"
              "UV_PYTHON_DOWNLOADS=never"
            ];
          };
        };
    in
    {
      packages = builtins.listToAttrs (
        map
          (system: {
            name = system;
            value = {
              caosImage = forSystem system;
            };
          })
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
      );
    };
}
