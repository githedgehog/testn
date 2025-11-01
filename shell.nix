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
      rust-analyzer-unwrapped
      rustup
    ]);
  runScript = ''bash'';
}).env
