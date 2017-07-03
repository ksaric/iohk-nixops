{ accessKeyId, ... }:

with (import ./../lib.nix);
{
  network.description = "Cardano SL";

  report-server = { config, pkgs, resources, ... }: {
    imports = [
      ./../modules/amazon-base.nix
    ];

    deployment.route53.accessKeyId = accessKeyId;
    deployment.route53.hostName = "report-server.aws.iohkdev.io";

    deployment.ec2.accessKeyId = accessKeyId;
  };
}
