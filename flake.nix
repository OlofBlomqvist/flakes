{
  description = "AN EPIC FLAKE";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [ 
              "dotnet-sdk-6.0.428" 
              "dotnet-sdk-7.0.410" 
            ];
          };
          overlays = [];
        };

        dotnetEnv = pkgs.symlinkJoin {
          name = "dotnet-env";
          paths = [ (with pkgs.dotnetCorePackages; combinePackages [
            sdk_6_0
            sdk_7_0
            sdk_8_0
            sdk_9_0
            sdk_10_0
          ]) ];
        };

        mkxShell = { name, env }: pkgs.mkShell {
          inherit name;
          buildInputs = [
            env
            pkgs.lsof
            pkgs.powershell
          ];
          shellHook = ''
            export PATH="~/.dotnet/tools:$PATH"
            export DOTNET_ROOT="${env}"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
          '';
        };

      in {

        packages.dotnet678910 = dotnetEnv;

        devShells.default = mkxShell {
          name = "DOTNET COMBO-FLAKE";
          env = with pkgs.dotnetCorePackages; combinePackages [
            sdk_6_0
            sdk_7_0
            sdk_8_0
            sdk_9_0
            sdk_10_0
          ];
        };

        devShells.build = pkgs.mkShell {
          name = "build-shell";
          buildInputs = [
            dotnetEnv
            pkgs.powershell
          ];
          shellHook = ''
            export DOTNET_ROOT="${dotnetEnv}"
            dotnet build
          '';
        };
      }
    );
}
