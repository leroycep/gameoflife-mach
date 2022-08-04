{
  description = "Mach is a game engine & graphics toolkit for the future.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zig.url = "github:roarkanize/zig-overlay";
  };

  outputs = { self, zig, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = pkgs.lib;
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        packages = [
          # As of 2022-03-20, 0.10.x is only available in nightly builds.
          # Any build with 0.10.x is okay.
          zig.packages.x86_64-linux.master.latest
          pkgs.xorg.libX11
          pkgs.libGL
        ];
        LD_LIBRARY_PATH = "${lib.makeLibraryPath [ pkgs.libGL ]}:${lib.makeLibraryPath [ pkgs.vulkan-loader ]}";
      };
    };
}
