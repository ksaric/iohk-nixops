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
      nodeById = i: let xs = filter (n: n.config.services.cardano-node.testIndex == i) (attrValues nodes);
                    in if xs != [] then builtins.elemAt xs 0
                       else throw "nodeById: no node with ID ${toString i}.";
      nodePublicIP = n: let ip = n.config.services.cardano-node.publicIP;
                        in if ip != null then ip
                           else throw "nodePublicIP: node #${toString n.config.services.cardano-node.testIndex} has no public IP configured.";
      nodeIdToPublicIP = i: let ip = nodePublicIP (nodeById i);
                            in builtins.trace "resolved node id #${toString i} -> ${ip}" ip;
    in {
      enable = true;
      testIndex = testIndex;
      port = cconf.nodePort;
      inherit (cconf) enableP2P genesisN slotDuration networkDiameter mpcRelayInterval;
      inherit (cconf) totalMoneyAmount bitcoinOverFlat productionMode systemStart richPoorDistr;
    }   //
     (      if connectivity.type == "core"       then with connectivity; {
        staticPeers          = map nodeIdToPublicIP (corePeers ++ coreRelayPeers);
        initialKademliaPeers = [];
     } else if connectivity.type == "core-relay" then with connectivity; {
        staticPeers          = map nodeIdToPublicIP (corePeers);
        initialKademliaPeers = map nodeIdToPublicIP (coreRelayPeers ++ pureRelayPeers);
     } else if connectivity.type == "pure-relay" then with connectivity; {
        staticPeers          = [];
        initialKademliaPeers = map nodeIdToPublicIP (coreRelayPeers ++ pureRelayPeers);
     } else
        throw "Invalid connectivity.type '${connectivity.type}' for node ${toString testIndex}, must be one of: 'core', 'core-relay' and 'pure-relay'.");
  }
