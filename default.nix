{
  pkgs ? import <nixpkgs> { },
  stdenv ? pkgs.stdenv,
  compiler-lib ? stdenv.cc.libc.libgcc,
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
rec {
  n-it.bin = build_fn "n-it";
  n-vm.bin = build_fn "n-vm";
  n-vm.container = pkgs.dockerTools.buildLayeredImage {
    name = "ghcr.io/githedgehog/testin/n-vm";
    tag = "latest";
    enableFakechroot = true;
    contents = [
      # this is a hack to make dockerTools calm down about a missing /sys.
      # We just toss in an largely vacant derivation with something we will need anyway
      (stdenv.mkDerivation {
        name = "_fhs";
        dontUnpack = true;
        src = null;
        installPhase = ''
          mkdir -p $out/vm_root/${stdenv.cc.libc.out}
        '';
      })
      n-vm.bin
      stdenv.cc.libc.out
      compiler-lib
    ];
    fakeRootCommands = ''
      #!${pkgs.busybox}/bin/sh
      ${pkgs.busybox}/bin/mkdir -p \
        /vm \
        /vm_root/bin \
        /vm_root/dev \
        /vm_root/lib \
        /vm_root/lib64 \
        /vm_root/nix \
        /vm_root/proc \
        /vm_root/run \
        /vm_root/sys \
        /vm_root/tmp
      ${pkgs.rsync}/bin/rsync -rLhP ${stdenv.cc.libc.out}/ /vm_root/${stdenv.cc.libc.out}}/
      ${pkgs.rsync}/bin/rsync -rLhP ${compiler-lib}/ /vm_root/${compiler-lib}/
      ${pkgs.rsync}/bin/rsync -rLhP ${n-it.bin}/ /vm_root/${n-it.bin}/
      ${pkgs.busybox}/bin/ln -s ${n-it.bin}/bin/n_it /vm_root/bin/n_it
      # populate symlinks or we can't find the dynamic linker
      ${pkgs.rsync}/bin/rsync -rlhP /lib/ /vm_root/lib/
      ${pkgs.rsync}/bin/rsync -rlhP /lib64/ /vm_root/lib64/
    '';
  };

}
