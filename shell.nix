{
  pkgs ? import <nixpkgs> { },
}:
(pkgs.buildFHSEnv {
  name = "testn-shell";
  targetPkgs =
    pkgs:
    (with pkgs; [
      # for nix
      nil
      nix-prefetch-git
      nixd

      # for dev
      bash
      docker-client
      llvmPackages.clang
      llvmPackages.lld
      stdenv.cc.libc.dev
      glibc.dev
      glibc.out
      libgcc.libgcc
      cargo
      rust-analyzer-unwrapped
      rustup
    ]);
  runScript = ''bash'';
}).env
