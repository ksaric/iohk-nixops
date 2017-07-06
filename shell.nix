{ ghcVer   ? "ghc802"
, lib      ? import ./lib.nix
, nixpkgs  ? lib.fetchNixPkgs
, pkgs     ? import nixpkgs {}
, iohkpkgs ? import ./default.nix { inherit pkgs; }
}: let

compiler      = pkgs.haskell.packages."${ghcVer}";

ghcOrig       = import ./default.nix { inherit pkgs compiler; };

githubSrc     =      repo: rev: sha256:       pkgs.fetchgit  { url = "https://github.com/" + repo; rev = rev; sha256 = sha256; };
overC         =                               pkgs.haskell.lib.overrideCabal;
overCabal     = old:                    args: overC old (oldAttrs: (oldAttrs // args));
overGithub    = old: repo: rev: sha256: args: overC old ({ src = githubSrc repo rev sha256; }     // args);
overHackage   = old: version:   sha256: args: overC old ({ version = version; sha256 = sha256; } // args);

stack2NixSrc  = builtins.fromJSON (builtins.readFile ./stack2nix-src.json);

ghc           = ghcOrig.override (oldArgs: {
  overrides = with pkgs.haskell.lib; new: old:
  let parent = (oldArgs.overrides or (_: _: {})) new old;
  in with new; parent // {
      # intero         = overGithub  old.intero "commercialhaskell/intero"
      #                  "e546ea086d72b5bf8556727e2983930621c3cb3c" "1qv7l5ri3nysrpmnzfssw8wvdvz0f6bmymnz1agr66fplazid4pn" { doCheck = false; };
    };
  });

###
###
###
drvf =
{ mkDerivation, stdenv
,   aeson, base, cassava, jq, lens-aeson, nix-prefetch-git, safe, turtle, utf8-string, vector, yaml
,   stack2nix, cabal2nix, cabal-install, intero
,   iohk-ops
,   amazonka, amazonka-core, amazonka-ec2
}:
mkDerivation {
  pname = "iohk-shell-env";
  version = "0.0.1";
  src = ./iohk;
  isLibrary = false;
  isExecutable = true;
  doHaddock = false;
  executableHaskellDepends = [
    aeson  base  cassava  jq  lens-aeson  nix-prefetch-git  safe  turtle  utf8-string  vector  yaml
    stack2nix  cabal2nix  cabal-install  intero
    pkgs.stack
    iohk-ops
    amazonka amazonka-core amazonka-ec2
  ];
  shellHook =
  ''
    export NIX_PATH=nixpkgs=${nixpkgs}
    echo   NIX_PATH set to $NIX_PATH >&2
  '';
  license      = stdenv.lib.licenses.mit;
};

drv = ghc.callPackage drvf { inherit (iohkpkgs) stack2nix iohk-ops amazonka amazonka-core amazonka-ec2; };

in if pkgs.lib.inNixShell then drv.env else drv
