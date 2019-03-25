{ mkDerivation, base, binary, bytestring, config-ini, cryptonite
, directory, filepath, hxt, lens, memory, mtl, random, stdenv, text
, time, wreq
}:
mkDerivation {
  pname = "smsgwapi";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base binary bytestring config-ini cryptonite directory filepath hxt
    lens memory mtl random text time wreq
  ];
  executableHaskellDepends = [ base text ];
  homepage = "https://github.com/sorki/smsgwapi";
  description = "SMS gateway API client";
  license = stdenv.lib.licenses.bsd3;
}
