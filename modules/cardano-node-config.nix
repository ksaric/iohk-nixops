# TODO: get rid of this duplication between config.nix and modules/cardano-node.nix
# XXX: rename this file:  cardano-node-config vs. cardano-nodes-config is CRUEL
with (import ./../lib.nix);

let
    nodeIdToAddress = i: "node${toString i}";  # XXX: this is a stub
in

testIndex: region: connectivity:
  { pkgs, ...}: {
    imports = [
      ./common.nix
    ];

    services.cardano-node = {
      enable = true;
      testIndex = testIndex;
      port = cconf.nodePort;
      inherit (cconf) enableP2P genesisN slotDuration networkDiameter mpcRelayInterval;
      inherit (cconf) totalMoneyAmount bitcoinOverFlat productionMode systemStart richPoorDistr;
    }   //
     (      if connectivity.type == "core"       then with connectivity; {
        staticPeers          = map nodeIdToAddress (corePeers ++ coreRelayPeers);
        initialKademliaPeers = [];
     } else if connectivity.type == "core-relay" then with connectivity; {
        staticPeers          = map nodeIdToAddress (corePeers);
        initialKademliaPeers = map nodeIdToAddress (coreRelayPeers ++ pureRelayPeers);
     } else if connectivity.type == "pure-relay" then with connectivity; {
        staticPeers          = [];
        initialKademliaPeers = map nodeIdToAddress (coreRelayPeers ++ pureRelayPeers);
     } else
        throw "Invalid connectivity.type '${connectivity.type}' for node ${toString testIndex}, must be one of: 'core', 'core-relay' and 'pure-relay'.");
  }
