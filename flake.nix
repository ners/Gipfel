{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = inputs:
    with builtins;
    let
      lib = inputs.nixpkgs.lib;
      foreach = xs: f: lib.foldr lib.recursiveUpdate { } (map f xs);
      foreachAttrs = attrs: foreach (lib.cartesianProductOfSets attrs);
    in
    foreachAttrs { buildPlatform = attrNames inputs.nixpkgs.legacyPackages; } (
      { buildPlatform
      , pkgs ? inputs.nixpkgs.legacyPackages.${buildPlatform}
      }: {
        formatter.${buildPlatform} = pkgs.nixpkgs-fmt;
      } // foreachAttrs { ghc = attrNames pkgs.haskell.packages; }
        ({ ghc
         , haskellPackages ? pkgs.haskell.packages.${ghc}.override {
             overrides = self: super: with pkgs.haskell.lib; trace "GHC version: ${super.ghc.version}"
               {
                 gipfel-server = super.callCabal2nix "gipfel-server" ./gipfel-server { };
               } // lib.optionalAttrs (lib.versionAtLeast super.ghc.version "9.6") {
               fourmolu = super.fourmolu_0_12_0_0;
               vector = dontCheck (doJailbreak (super.vector_0_13_0_0));
               vector-algorithms = super.vector-algorithms_0_9_0_1;
             };
           }
         }: {
          packages.${buildPlatform}.${ghc} = haskellPackages;

          devShells.${buildPlatform}.${ghc} = mapAttrs (name: package:
            haskellPackages.shellFor {
              packages = _: [ package ];
              nativeBuildInputs = with haskellPackages; [
                cabal-install
                fourmolu
                haskell-language-server
                pkgs.nixpkgs-fmt
              ];
            }
          ) haskellPackages;
        })
    );
}
