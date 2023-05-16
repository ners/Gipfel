{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nix-filter.url = "github:numtide/nix-filter";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.servant = {
    url = "github:haskell-servant/servant";
    flake = false;
  };
  inputs.bsb-http-chunked = {
    url = "github:sjakobi/bsb-http-chunked";
    flake = false;
  };
  inputs.wai = {
    url = "github:yesodweb/wai";
    flake = false;
  };

  outputs = inputs:
    with builtins;
    let
      lib = inputs.nixpkgs.lib;
      nix-filter = inputs.nix-filter.lib;
      hs-filter = root: nix-filter {
        inherit root;
        include = [
          "app"
          "assets"
          "src"
          "test"
          (nix-filter.matchExt "cabal")
          "CHANGELOG.md"
          "LICENCE"
        ];
      };
      foreach = xs: f: lib.foldr lib.recursiveUpdate { } (map f xs);
      foreachAttrs = attrs: foreach (lib.cartesianProductOfSets attrs);
    in
    foreachAttrs { buildPlatform = attrNames inputs.nixpkgs.legacyPackages; } (
      { buildPlatform
      , pkgs ? inputs.nixpkgs.legacyPackages.${buildPlatform}
      }: lib.recursiveUpdate
        {
          formatter.${buildPlatform} = pkgs.nixpkgs-fmt;
          devShells.${buildPlatform}.default = inputs.self.devShells.${buildPlatform}.ghc96;
        }
        (foreachAttrs { ghc = attrNames pkgs.haskell.packages; }
          ({ ghc
           , haskellPackages ? pkgs.haskell.packages.${ghc}.override {
               overrides = self: super: with pkgs.haskell.lib; trace "GHC version: ${super.ghc.version}"
                 {
                   gipfel-api = super.callCabal2nix "gipfel-api" (hs-filter ./gipfel-api) { };
                   gipfel-server = super.callCabal2nix "gipfel-server" (hs-filter ./gipfel-server) { };
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
                 auto-update = self.callCabal2nix "auto-update" "${inputs.wai}/auto-update" { };
                 bsb-http-chunked = self.callCabal2nix "bsb-http-chunked" inputs.bsb-http-chunked { };
                 fourmolu = super.fourmolu_0_12_0_0;
                 http2 = super.http2_4_1_2;
                 mime-types = self.callCabal2nix "mime-types" "${inputs.wai}/mime-types" { };
                 modern-uri = doJailbreak super.modern-uri;
                 monad-metrics = doJailbreak super.monad-metrics;
                 recv = self.callCabal2nix "recv" "${inputs.wai}/recv" { };
                 req = doJailbreak super.req;
                 servant = doJailbreak (self.callCabal2nix "servant" "${inputs.servant}/servant" { });
                 servant-openapi3 = doJailbreak super.servant-openapi3;
                 servant-server = dontCheck (doJailbreak (super.servant-server));
                 time-manager = self.callCabal2nix "time-manager" "${inputs.wai}/time-manager" { };
                 vector = dontCheck (doJailbreak (super.vector_0_13_0_0));
                 vector-algorithms = super.vector-algorithms_0_9_0_1;
                 wai = self.callCabal2nix "wai" "${inputs.wai}/wai" { };
                 wai-app-static = self.callCabal2nix "wai-app-static" "${inputs.wai}/wai-app-static" { };
                 wai-conduit = self.callCabal2nix "wai-conduit" "${inputs.wai}/wai-conduit" { };
                 wai-extra = self.callCabal2nix "wai-extra" "${inputs.wai}/wai-extra" { };
                 wai-http2-extra = self.callCabal2nix "wai-http2-extra" "${inputs.wai}/wai-http2-extra" { };
                 wai-websockets = self.callCabal2nix "wai-websockets" "${inputs.wai}/wai-websockets" { };
                 warp = dontCheck (self.callCabal2nix "warp" "${inputs.wai}/warp" { });
                 warp-quic = self.callCabal2nix "warp-quic" "${inputs.wai}/warp-quic" { };
                 warp-tls = self.callCabal2nix "warp-tls" "${inputs.wai}/warp-tls" { };
               };
             }
           }: {
            packages.${buildPlatform}.${ghc} = haskellPackages;

            devShells.${buildPlatform}.${ghc} = haskellPackages.shellFor {
              packages = ps: [ ps.gipfel-api ps.gipfel-server ];
              nativeBuildInputs = with haskellPackages; [
                cabal-install
                fourmolu
                haskell-language-server
                pkgs.nixpkgs-fmt
              ];
              withHoogle = true;
            };
          }))
    );
}
