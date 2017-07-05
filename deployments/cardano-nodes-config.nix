{ nodeLimit, ... }:

with (import ./../lib.nix);

filterAttrs (name: node: node.i < nodeLimit)

(import ./../cluster.nix)
