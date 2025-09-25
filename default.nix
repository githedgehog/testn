{
  pkgs ? import <nixpkgs> { },
  stdenv ? pkgs.stdenv,
  compiler-lib ? pkgs.libgcc.libgcc,
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
      llvmPackages_21,
      rev ? get_version package,
    }:
    rustPlatform.buildRustPackage (final: {
      inherit src;
      RUSTFLAGS = "-C opt-level=3 -C codegen-units=1 -C lto=fat -C embed-bitcode=yes -C relro-level=full";
      pname = package;
      version = rev;
      nativeBuildInputs = [
        llvmPackages_21.clang
        llvmPackages_21.lld
      ];
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
        (fs.maybeMissing ./container)
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
  linux = pkgs.linuxManualConfig rec {
    version = "6.12.49";
    src = fetchTarball {
      url = "https://cdn.kernel.org/pub/linux/kernel/v${pkgs.lib.versions.major version}.x/linux-${version}.tar.xz";
      sha256 = "sha256:0nxbwcyb1shfw9s833agk32zh133xzqxpw7j4fzdskzl1x65jaws";
    };
    configfile = ./linux/kernel.config;
    inherit (pkgs.llvmPackages_21) stdenv;
  };
  n-it.bin = build_fn "n-it";
  n-vm.bin = build_fn "n-vm";
  p = pkgs;
  testn.container = pkgs.dockerTools.buildLayeredImage {
    name = "ghcr.io/githedgehog/testn/n-vm";
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
          mkdir -p $out/vm.root/${stdenv.cc.libc.out}
        '';
      })
      pkgs.virtiofsd
      pkgs.cloud-hypervisor
      n-vm.bin
      stdenv.cc.libc.out
      compiler-lib
      linux
      pkgs.libcap.out
      pkgs.busybox
    ];
    fakeRootCommands = ''
      #!${pkgs.busybox}/bin/sh
      set -euxo pipefail
      ${pkgs.busybox}/bin/mkdir -p \
        /vm \
        /vm.root/bin \
        /vm.root/dev \
        /vm.root/lib \
        /vm.root/lib64 \
        /vm.root/nix \
        /vm.root/proc \
        /vm.root/run \
        /vm.root/sys \
        /vm.root/tmp
      ${pkgs.rsync}/bin/rsync -rLhP ${stdenv.cc.libc.out}/ /vm.root/${stdenv.cc.libc.out}/
      ${pkgs.rsync}/bin/rsync -rLhP ${compiler-lib}/ /vm.root/${compiler-lib}/
      ${pkgs.rsync}/bin/rsync -rLhP ${compiler-lib.lib}/ /vm.root/${compiler-lib.lib}/
      ${pkgs.rsync}/bin/rsync -rLhP ${n-it.bin}/ /vm.root/${n-it.bin}/
      ${pkgs.busybox}/bin/ln -s ${n-it.bin}/bin/n-it /vm.root/bin/n-it
      # populate symlinks or we can't find the dynamic linker
      ${pkgs.rsync}/bin/rsync -rLhP /lib/ /vm.root/lib/
      ${pkgs.rsync}/bin/rsync -rLhP /lib64/ /vm.root/lib64/
      ${pkgs.busybox}/bin/ln -s . /vm.root/lib/x86_64-linux-gnu
      ${pkgs.libcap}/bin/setcap 'cap_net_admin+ep' ${pkgs.cloud-hypervisor}/bin/cloud-hypervisor
      ${pkgs.busybox}/bin/chmod -R a+x /vm.root/
    '';
  };

}
