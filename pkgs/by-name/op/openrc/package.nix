{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  meson,
  cmake,
  ninja,
  pkg-config,
  audit,
  linux-pam,
  libcap,
  libselinux,
}:

stdenv.mkDerivation rec {
  pname = "openrc";
  version = "0.55.1";

  src = fetchFromGitHub {
    owner = "OpenRC";
    repo = "openrc";
    rev = version;
    hash = "sha256-jINVP7Hr0v25tCWz4kKSFixpj0+WmtEqkIBW+D7YAFs=";
  };

  # meson_runleve.sh really wants to link scripts into runlevels in /etc.
  # We don't have any runlevels and can't write to /etc anyway.
  postPatch = ''
    echo "#!/bin/sh" > tools/meson_runlevels.sh
  '';

  # openrc doesn't respect prefix in this version
  preConfigure = ''
    mesonFlagsArray+=(-Drootprefix=$out)
  '';

  # DESTDIR is required for some reason.
  DESTDIR = "/";

  # Normally meson_runlevels.sh would try to do this
  postInstall = ''
    ln -s $out/lib/rc/sh/functions.sh $out/etc/init.d/functions.sh
  '';

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    audit
    linux-pam
    libcap
    libselinux
  ];

  meta = with lib; {
    description = "OpenRC init system";
    homepage = "https://wiki.gentoo.org/wiki/OpenRC";
    license = licenses.bsd2;
    platforms = platforms.unix;
    maintainers = with maintainers; [ artemist ];
  };
}
