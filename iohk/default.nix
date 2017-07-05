{ mkDerivation, aeson, base, bytestring, cassava, containers, lens
, lens-aeson, mtl, optional-args, safe, stdenv, system-filepath
, text, turtle, utf8-string, vector, yaml
, amazonka, amazonka-core, amazonka-ec2
}:
mkDerivation {
  pname = "iohk-ops";
  version = "0.1.0.0";
  src = ./..;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bytestring cassava containers lens lens-aeson mtl
    optional-args safe system-filepath text turtle utf8-string vector
    yaml
    amazonka amazonka-core amazonka-ec2
  ];
  license = stdenv.lib.licenses.bsd3;
}
