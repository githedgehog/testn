{
  pkgs ? import <nixpkgs> { },
}:
let
  get_version =
    package:
    (builtins.fromTOML (builtins.readFile (./. + "/${package}/" + "/Cargo.toml"))).package.version;
  build-package =
    {
      package,
      src,
      rustPlatform,
      llvmPackages,
      rev ? get_version package,
    }:
    rustPlatform.buildRustPackage (final: {
      inherit src;
      pname = package;
      version = rev;
      nativeBuildInputs = [ llvmPackages.clang ];
      buildAndTestSubdir = package;
      doCheck = false;
      cargoLock = {
        lockFile = final.src + "/Cargo.lock";
      };
    });
  fs = pkgs.lib.fileset;
  src = fs.toSource {
    root = ./.;
    fileset = fs.difference ./. (
      fs.unions [
        (fs.maybeMissing ./target)
        (fs.maybeMissing ./result)
        (fs.maybeMissing ./result-2)
        (fs.fileFilter (file: file.hasExt "nix") ./.)
      ]
    );
  };
  build_fn =
    package:
    pkgs.callPackage build-package {
      inherit package src;
    };
in
{
  testnit = build_fn "testnit";
  testnvm = build_fn "testnvm";
}
