#!/bin/bash
#
# Prerequisite set-up script for Drake on Ubuntu 16.04.

set -euo pipefail

die () {
    echo "$@" 1>&2
    trap : EXIT  # Disable line number reporting; the "$@" message is enough.
    exit 1
}

at_exit () {
    echo "${me} has experienced an error on line ${LINENO}" \
        "while running the command ${BASH_COMMAND}"
}

me="The Drake prerequisite set-up script"

trap at_exit EXIT

[[ "${EUID}" -eq 0 ]] || die "${me} must run as root. Please use sudo."

apt update
apt install --no-install-recommends lsb-release

[[ "$(lsb_release -sc)" == "xenial" ]] || die "${me} only supports Ubuntu 16.04."

# Install the APT dependencies.
apt install --no-install-recommends $(tr '\n' ' ' <<EOF

bash-completion
binutils
bison
clang-4.0
clang-format-4.0
cmake
cmake-curses-gui
coinor-libclp-dev
coinor-libipopt-dev
diffstat
doxygen
flex
g++
g++-5
g++-5-multilib
gcc
gcc-5
gcc-5-multilib
gdb
git
graphviz
libblas-dev
libboost-all-dev
libbz2-dev
libexpat1-dev
libfreetype6-dev
libgflags-dev
libglib2.0-dev
libglu1-mesa-dev
libhdf5-dev
libjpeg8-dev
libjsoncpp-dev
liblapack-dev
liblz4-dev
libnetcdf-cxx-legacy-dev
libnetcdf-dev
libnlopt-dev
libogg-dev
libpng-dev
libprotobuf-dev
libqt5multimedia5
libqt5opengl5-dev
libqt5x11extras5-dev
libtheora-dev
libtiff5-dev
libtinyxml-dev
libtinyxml2-dev
libtool
libxml2-dev
libxt-dev
libyaml-cpp-dev
lldb-4.0
make
openjdk-8-jdk
patchelf
patchutils
pkg-config
protobuf-compiler
python-dev
python-gtk2
python-lxml
python-matplotlib
python-numpy
python-protobuf
python-pygame
python-scipy
python-sphinx
python-tk
python-yaml
valgrind
wget
zip
zlib1g-dev

EOF
    )

dpkg_install_from_wget() {
  package="$1"
  version="$2"
  url="$3"

  # Skip the install if we're already at the exact version.
  installed=$(dpkg-query --showformat='${Version}\n' --show "${package}" 2>/dev/null || true)
  if [[ "${installed}" == "${version}" ]]; then
    echo "${package} is already at the desired version ${version}"
    return
  fi

  # If installing our desired version would be a downgrade, ask the user first.
  if dpkg --compare-versions "${installed}" gt "${version}"; then
    echo "This system has ${package} version ${installed} installed."
    echo "Drake suggests downgrading to version ${version}, our supported version."
    read -r -p "Do you want to downgrade? [Y/n] " reply
    if [[ ! "${reply}" =~ ^([yY][eE][sS]|[yY])*$ ]]; then
      echo "Skipping ${package} ${version} installation."
      return
    fi
  fi

  # Download and verify.
  tmpdeb="/tmp/${package}_${version}-amd64.deb"
  wget -O "${tmpdeb}" "${url}"

  # Install.
  dpkg -i "${tmpdeb}"
  rm "${tmpdeb}"
}

# Install Bazel.
dpkg_install_from_wget \
  bazel 0.10.1 \
  https://github.com/bazelbuild/bazel/releases/download/0.10.1/bazel_0.10.1-linux-x86_64.deb \
  5012d064a6e95836db899fec0a2ee2209d2726fae4a79b08c8ceb61049a115cd

# Install IBEX, a dReal dependency.  See
# https://launchpad.net/~dreal/+archive/ubuntu/dreal
# for more information. To rebuild IBEX, add the PPA `ppa:dreal/dreal` and then
# run `apt source libibex-dev` to get the sources.
dpkg_install_from_wget \
  ibex 2.6.3 \
  https://drake-apt.csail.mit.edu/pool/main/libi/libibex-dev/libibex-dev_2.6.3.20171215122721.git2275df8f465a9db6a42d497ca322011ff2c6f8f7~16.04_amd64.deb

# Install dReal. See
# https://github.com/dreal/dreal4/blob/master/README.md#build-debian-package for
# build instructions.
dpkg_install_from_wget \
  dreal 4.17.12.3 \
  https://dl.bintray.com/dreal/dreal/dreal_4.17.12.3_amd64.deb \
  72e878e2af14b1509b8d3a2943d7e7c824babfa755f4928cc3618e1fe85695c9

# Remove deb that we used to generate and install, but no longer need.
if [ -L /usr/lib/ccache/bazel ]; then
  apt purge ccache-bazel-wrapper
fi

trap : EXIT  # Disable exit reporting.
echo "install_prereqs: success"
