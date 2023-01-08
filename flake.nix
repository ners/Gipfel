{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      haskellPackages = pkgs.haskellPackages.override {
        overrides = self: super: {
          gipfel = self.callCabal2nix "gipfel" ./. { };
        };
      };
    in
    {
      packages.default = haskellPackages.gipfel;
      devShells.default = haskellPackages.shellFor {
        packages = ps: [ ps.gipfel ];
        nativeBuildInputs = with haskellPackages; [
          cabal-install
          fourmolu
          hpack
          haskell-language-server
        ];
      };
    }
  );
}
