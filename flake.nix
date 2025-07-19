{
  description = "A Terminal UI to browse Hacker News";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "hackernews-tui";
          version = "0.13.5";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            openssl
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ];

          # Run tests
          doCheck = true;

          meta = with pkgs.lib; {
            description = "A Terminal UI to browse Hacker News";
            homepage = "https://github.com/aome510/hackernews-TUI";
            license = licenses.mit;
            maintainers = [ ];
            mainProgram = "hackernews_tui";
          };
        };

        # Alias for convenience
        packages.hackernews-tui = self.packages.${system}.default;

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust toolchain
            rustc
            cargo
            rustfmt
            clippy

            # Build dependencies
            pkg-config
            openssl

            # Development tools
            rust-analyzer
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ];

          # Environment variables for development
          RUST_BACKTRACE = "1";
          
          shellHook = ''
            echo "hackernews-tui development environment"
            echo "Available commands:"
            echo "  cargo build    - Build the project"
            echo "  cargo test     - Run tests"
            echo "  cargo run      - Run the application"
            echo "  cargo clippy   - Run linter"
            echo "  cargo fmt      - Format code"
          '';
        };

        # Apps for easy execution
        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          name = "hackernews_tui";
        };
      });
}