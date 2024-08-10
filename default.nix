{ lib, stdenv, bear, ctags, llvmPackages_latest, gdbHostCpuOnly
, dev ? false }:

stdenv.mkDerivation {
  name = "h1enc-parrot-p7";

  src = ./.;

  outputs = [ "bin" "out" "dev" ];

  nativeBuildInputs = [
    ctags
  ] ++ (lib.optionals dev [
    bear
    llvmPackages_latest.clang-tools
    gdbHostCpuOnly
  ]);

  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildPhase = ''
    runHook preBuild

    make -C linux_reference "''${makeFlags[@]}" parrot_p7
    make -C linux_reference/test/camstab "''${makeFlags[@]}" parrot_p7
    make -C linux_reference/test/h264 "''${makeFlags[@]}" parrot_p7

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$bin/bin" "$out/lib" "$dev"

    mv linux_reference/test/camstab/videostabtest "$bin/bin"
    mv linux_reference/test/h264/h264_testenc "$bin/bin"
    mv linux_reference/libh1enc${stdenv.hostPlatform.extensions.library} "$out/lib"
    mv inc "$dev/include"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hantro H1 video encoder driver for Parrot P7";
    # All the files headers contain the BSD-3 and a proprietary license, and it
    # isn't clear which applies. Let's just assume the best for now.
    license = licenses.bsd3;
    maintainers = with maintainers; [ lopsided98 ];
    platforms = [ "armv7l-linux" ];
  };
}
