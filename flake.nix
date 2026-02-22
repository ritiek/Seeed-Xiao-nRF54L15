{
  description = "nRF54L15 Zephyr dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, zephyr-nix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      zephyr = zephyr-nix.packages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          # ARM Cortex-M33 toolchain (nRF54L15 is ARM)
          (zephyr.sdk.override {
            targets = [ "arm-zephyr-eabi" ];
          })
          zephyr.pythonEnv
          zephyr.hosttools-nix

          pkgs.cmake
          pkgs.ninja
          pkgs.pyocd
        ];

        shellHook = ''
          export ZEPHYR_BASE=$(pwd)/.zephyr
          export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
          export ZEPHYR_SDK_INSTALL_DIR=${zephyr.sdk.override { targets = [ "arm-zephyr-eabi" ]; }}

          echo ""
          echo "Quick start:"
          echo "  $ west update"
          echo "  $ west build -b xiao_nrf54l15/nrf54l15/cpuapp <example> -p"
          echo "  $ sudo west flash"
        '';
      };
    };
}
