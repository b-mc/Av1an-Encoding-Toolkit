# Av1an encoding toolkit for Ubuntu 24.04+
The script builds and installs Av1an and the following components from source:
* zimg
* VapourSynth
* l-smash
* l-smash-works
* ffms2
* SVT-AV1
* aomenc
* ssimulacra2

Among the prerequisite packages, the following notable components are installed:
* rust (via rustup)
* Python virtual environment
* VapourSynth (Python module) - built from source with wheel, as no Linux .whl files are available on PyPI for R68

For most of the components, the latest release is downloaded with the help of Github/Gitlab API on each run, so the script enables updating them, in an inefficient way though. The script was tested on a daily build of the amd64 Ubuntu 24.04 [cloud image](https://cloud-images.ubuntu.com/noble/current/).

# Usage
Install with `bash av1an_encoding_toolkit.sh`. Enter the Python virtual environment where the `av1an` command is available.
```shell
bmc@ubt:~$ source ~/.venv/av1an/bin/activate
(av1an) bmc@ubt:~$ av1an --version
av1an 0.4.1-unstable (rev VERGEN_IDEMPOTENT_OUTPUT) (Release)

* Compiler
  rustc 1.79.0 (LLVM 18.1)

* Target Triple
  x86_64-unknown-linux-gnu

* Date Info
  Commit Date:  VERGEN_IDEMPOTENT_OUTPUT

* VapourSynth Plugins
  systems.innocent.lsmas : Found
  com.vapoursynth.ffms2  : Found
  com.vapoursynth.dgdecodenv : Not found
  com.vapoursynth.bestsource : Not found
```

# Sources
Adapted / extended from:
* [reddit](https://www.reddit.com/r/AV1/comments/109jts0/guide_installing_av1an_on_ubuntu_2204/)
* [x266.mov #1](https://wiki.x266.mov/blog/av1-encoding-for-dummies)
* [x266.mov #2](https://wiki.x266.mov/docs/encoders/aomenc)