{
  node0 = { i = 0; region = "eu-central-1"; connectivity = { type = "core"; corePeers = [ 2 12 ]; coreRelayPeers = [ 1 ]; }; };
  node2 = { i = 2; region = "eu-west-1"; connectivity = { type = "core"; corePeers = [ 0 4 ]; coreRelayPeers = [ 3 ]; }; };
  node4 = { i = 4; region = "eu-west-2"; connectivity = { type = "core"; corePeers = [ 2 6 ]; coreRelayPeers = [ 5 ]; }; };
  node6 = { i = 6; region = "ap-southeast-1"; connectivity = { type = "core"; corePeers = [ 4 8 ]; coreRelayPeers = [ 7 ]; }; };
  node8 = { i = 8; region = "ap-southeast-2"; connectivity = { type = "core"; corePeers = [ 6 10 ]; coreRelayPeers = [ 9 ]; }; };
  node10 = { i = 10; region = "ap-northeast-1"; connectivity = { type = "core"; corePeers = [ 8 12 ]; coreRelayPeers = [ 11 ]; }; };
  node12 = { i = 12; region = "ap-northeast-2"; connectivity = { type = "core"; corePeers = [ 10 0 ]; coreRelayPeers = [ 13 ]; }; };
  node1 = { i = 1; region = "eu-central-1"; connectivity = { type = "core-relay"; corePeers = [ 0 ]; coreRelayPeers = [ 13 3 ]; pureRelayPeers = [  ]; }; };
  node3 = { i = 3; region = "eu-west-1"; connectivity = { type = "core-relay"; corePeers = [ 2 ]; coreRelayPeers = [ 1 5 ]; pureRelayPeers = [  ]; }; };
  node5 = { i = 5; region = "eu-west-2"; connectivity = { type = "core-relay"; corePeers = [ 4 ]; coreRelayPeers = [ 3 7 ]; pureRelayPeers = [  ]; }; };
  node7 = { i = 7; region = "ap-southeast-1"; connectivity = { type = "core-relay"; corePeers = [ 6 ]; coreRelayPeers = [ 5 9 ]; pureRelayPeers = [  ]; }; };
  node9 = { i = 9; region = "ap-southeast-2"; connectivity = { type = "core-relay"; corePeers = [ 8 ]; coreRelayPeers = [ 7 11 ]; pureRelayPeers = [  ]; }; };
  node11 = { i = 11; region = "ap-northeast-1"; connectivity = { type = "core-relay"; corePeers = [ 10 ]; coreRelayPeers = [ 9 13 ]; pureRelayPeers = [  ]; }; };
  node13 = { i = 13; region = "ap-northeast-2"; connectivity = { type = "core-relay"; corePeers = [ 12 ]; coreRelayPeers = [ 11 1 ]; pureRelayPeers = [  ]; }; };
}