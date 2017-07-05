{ mkDerivation, async, base, bytestring, containers, data-fix
, directory, fetchgit, filepath, Glob, hnix, monad-parallel
, optparse-applicative, process, SafeSemaphore, stdenv, temporary
, text, yaml
}:
mkDerivation {
  pname = "stack2nix";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/input-output-hk/stack2nix.git";
    sha256 = "0hk46128mp7sdbr4r6a231hyw12akiwhzzj26vpw7ba83rpd6d2f";
    rev = "b36a78d561c839db7f30ab3622acf788f52d40d6";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    async base bytestring containers data-fix directory filepath Glob
    hnix monad-parallel process SafeSemaphore temporary text yaml
  ];
  executableHaskellDepends = [ base optparse-applicative ];
  doCheck = false;
  description = "Convert stack.yaml files into Nix build instructions.";
  license = stdenv.lib.licenses.bsd3;
}
