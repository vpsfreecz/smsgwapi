{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc863" }:
nixpkgs.haskell.packages.${compiler}.callPackage ./smsgwapi.nix { }
