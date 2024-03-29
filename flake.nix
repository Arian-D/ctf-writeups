{
  description = "My write-up website";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.emacs-overlay.url = "github:nix-community/emacs-overlay";

  outputs = { self, nixpkgs, flake-utils, emacs-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ emacs-overlay.overlays.package ];
        };
        emacsWithOxHugo = pkgs.emacsWithPackages (epkgs: [ epkgs.ox-hugo ]);
        deps = [ pkgs.hugo emacsWithOxHugo ];
      in rec {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "writeups";
          version = "0.0.1";
          src = ./.;
          installPhase = ''
            mkdir -p $out
            cp -r public $out
          '';
          buildPhase = ''
            emacs --batch \
                  --eval "(require 'ox-hugo)" \
                  --eval "(setq org-confirm-babel-evaluate nil)" \
                  --file ./build.org \
                  --funcall org-babel-execute-buffer
          '';
          nativeBuildInputs = deps;
        };
      });
}
