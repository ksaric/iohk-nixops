import <nixpkgs/nixos/tests/make-test.nix> ({ pkgs, ... }: {
  name = "simple-node";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [ (import ../modules/cardano-node-config.nix 0 "") ];
      services.cardano-node = {
        autoStart = true;
        initialKademliaPeers = [];
      };
    };
  };
  testScript = ''
    startAll
    $machine->waitForUnit("cardano-node.service");
    # TODO, implement sd_notify?
    $machine->waitForOpenPort(3000);
  '';
})
