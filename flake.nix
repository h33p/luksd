{
  description = "luksd";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{self, nixpkgs, parts, rust-overlay }: parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" ];

    flake = {};

    perSystem = { system, ... }: {
      devShells.default = let
        pkgs = import nixpkgs { inherit system; overlays = [(import rust-overlay)]; };
      in
        pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.tpm2-tools
            # Rust toolchain
            (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
          ];
        };
    };
  };
}
