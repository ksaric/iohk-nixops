# TODO: get rid of this duplication between config.nix and modules/cardano-node.nix
# XXX: rename this file:  cardano-node-config vs. cardano-nodes-config is CRUEL
with (import ./../lib.nix);

testIndex: region: connectivity:
  { pkgs, nodes, ...}: {
    imports = [
      ./common.nix
    ];

    services.cardano-node =
    let
      nodeName = "node${toString testIndex}";
      nodeById = i: let xs = filter (n: n.config.services.cardano-node.testIndex == i) (attrValues nodes);
                    in if xs != [] then builtins.elemAt xs 0
                       else throw "nodeById: no node with ID ${toString i}.";
      nodePublicIP = n: let ip = n.config.services.cardano-node.publicIP;
                        in if ip != null then ip
                           else throw "nodePublicIP: node #${toString n.config.services.cardano-node.testIndex} has no public IP configured.";
      nodeIdToPublicIP = i: nodePublicIP (nodeById i);
      type    = builtins.trace "${nodeName}: role '${connectivity.type}'" connectivity.type;
      peerIds = with connectivity;
       (      if type == "core"       then {
        staticPeerIds          = corePeers ++ coreRelayPeers;
        initialKademliaPeerIds = [];
       } else if type == "core-relay" then {
        staticPeerIds          = corePeers;
        initialKademliaPeerIds = coreRelayPeers ++ pureRelayPeers;
       } else if type == "pure-relay" then {
        staticPeerIds          = [];
        initialKademliaPeerIds = coreRelayPeers ++ pureRelayPeers;
       } else
        throw "Invalid connectivity.type '${connectivity.type}' for ${nodeName}, must be one of: 'core', 'core-relay' and 'pure-relay'.");
      staticPeers          = map nodeIdToPublicIP peerIds.staticPeerIds;
      initialKademliaPeers = map nodeIdToPublicIP peerIds.initialKademliaPeerIds;
      sep                  = ", ";
    in {
      enable = true;
      testIndex = testIndex;
      port = cconf.nodePort;
      inherit (cconf) enableP2P genesisN slotDuration networkDiameter mpcRelayInterval;
      inherit (cconf) totalMoneyAmount bitcoinOverFlat productionMode systemStart richPoorDistr;
      staticPeers          = builtins.trace "${nodeName}: static peer ids: ${concatStringsSep sep (map toString peerIds.staticPeerIds)}, IPs: ${concatStringsSep sep staticPeers}"
                             staticPeers;
      initialKademliaPeers = builtins.trace "${nodeName}: initial Kademlia peer ids: ${concatStringsSep sep (map toString peerIds.initialKademliaPeerIds)}, IPs: ${concatStringsSep sep initialKademliaPeers}"
                             initialKademliaPeers;
    };
  }
