{
  pkgs ? import <nixpkgs> { },
}:
let
  build-package =
    {
      package,
      src,
      rustPlatform,
      llvmPackages,
      rev ? "0.0.0",
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
  testn_init = build_fn "testn_init";
  testn_invm = build_fn "testn_invm";
}
