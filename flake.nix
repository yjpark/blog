{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-darwin"
          ]
          (
            system:
            f {
              pkgs = nixpkgs.legacyPackages.${system};
              inherit system;
            }
          );

      dodecaVersion = "0.13.0";

      dodecaSources = {
        x86_64-linux = {
          url = "https://github.com/bearcove/dodeca/releases/download/v${dodecaVersion}/dodeca-x86_64-unknown-linux-gnu.tar.xz";
          hash = "sha256-l6vXPKLr/qQ4dOAGWZCZafq/LsvAjL74W5GnxiBO8xY=";
        };
        aarch64-darwin = {
          url = "https://github.com/bearcove/dodeca/releases/download/v${dodecaVersion}/dodeca-aarch64-apple-darwin.tar.xz";
          hash = "sha256-FPVOe5YeSCzjOglIRSAOAT0w5W3OPrUteYI0XHpdC1U=";
        };
      };

      mkDodeca =
        { pkgs, system }:
        pkgs.stdenv.mkDerivation {
          pname = "dodeca";
          version = dodecaVersion;

          src = pkgs.fetchurl dodecaSources.${system};

          sourceRoot = ".";

          nativeBuildInputs = [ pkgs.autoPatchelfHook ];
          buildInputs = [
            pkgs.stdenv.cc.cc.lib
          ];

          installPhase = ''
            mkdir -p $out/bin
            cp ddc ddc-cell-* $out/bin/
            chmod +x $out/bin/*
          '';
        };
    in
    {
      devShells = forAllSystems (
        { pkgs, system }:
        {
          default = pkgs.mkShell {
            packages = [
              (mkDodeca { inherit pkgs system; })
            ];
          };
        }
      );
    };
}
