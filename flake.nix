{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.servant = {
    url = "github:haskell-servant/servant";
    flake = false;
  };

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
      }: lib.recursiveUpdate {
        formatter.${buildPlatform} = pkgs.nixpkgs-fmt;
        devShells.${buildPlatform}.default = inputs.self.devShells.${buildPlatform}.ghc96.gipfel-server;
      } (foreachAttrs { ghc = attrNames pkgs.haskell.packages; }
        ({ ghc
         , haskellPackages ? pkgs.haskell.packages.${ghc}.override {
             overrides = self: super: with pkgs.haskell.lib; trace "GHC version: ${super.ghc.version}"
               {
                gipfel-api = super.callCabal2nix "gipfel-api" ./gipfel-api { };
                gipfel-server = super.callCabal2nix "gipfel-server" ./gipfel-server { };
                haxl = doJailbreak (markUnbroken super.haxl);
                morpheus-graphql = super.morpheus-graphql_0_27_3;
                morpheus-graphql-app = super.morpheus-graphql-app_0_27_3;
                morpheus-graphql-client = super.morpheus-graphql-client_0_27_3;
                morpheus-graphql-code-gen = super.morpheus-graphql-code-gen_0_27_3;
                morpheus-graphql-code-gen-utils = super.morpheus-graphql-code-gen-utils_0_27_3;
                morpheus-graphql-core = super.morpheus-graphql-core_0_27_3;
                morpheus-graphql-server = super.morpheus-graphql-server_0_27_3;
                morpheus-graphql-subscriptions = super.morpheus-graphql-subscriptions_0_27_3;
                morpheus-graphql-tests = super.morpheus-graphql-tests_0_27_3;
                openapi3 = lib.pipe super.openapi3 [ dontCheck doJailbreak unmarkBroken ];
               } // lib.optionalAttrs (lib.versionAtLeast super.ghc.version "9.4") {
                relude = dontCheck (doJailbreak super.relude_1_2_0_0);
               } // lib.optionalAttrs (lib.versionAtLeast super.ghc.version "9.6") {
                fourmolu = super.fourmolu_0_12_0_0;
                modern-uri = doJailbreak super.modern-uri;
                req = doJailbreak super.req;
                servant = doJailbreak (self.callCabal2nix "servant" "${inputs.servant}/servant" {});
                servant-openapi3 = doJailbreak super.servant-openapi3;
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
        }))
    );
}
