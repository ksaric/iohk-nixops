{ ... }:

let

  connectivity = {
    type = "pure-relay"; corePeers = [ 1 3 5 7 9 11 13 ];
  };

in
with (import ./../lib.nix);
{
  network.description = "Cardano Explorer";

  sl-explorer = {
    imports = [
      # A node with 1) index 40, 2) no region and 3) in outer tier:
      (import ./../modules/cardano-node-config.nix 40 "" connectivity)
      ./../modules/cardano-explorer.nix
    ];
  };
}
