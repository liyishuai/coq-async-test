<!---
This file was generated from `meta.yml`, please do not edit manually.
Follow the instructions on https://github.com/coq-community/templates to regenerate.
--->
# Asynchronous Test

[![CircleCI][circleci-shield]][circleci-link]

[circleci-shield]: https://circleci.com/gh/liyishuai/coq-async-test.svg?style=svg
[circleci-link]:   https://circleci.com/gh/liyishuai/coq-async-test




From interaction trees to asynchronous tests.

## Meta

- Author(s):
  - Yishuai Li
- License: [Mozilla Public License 2.0](LICENSE)
- Compatible Coq versions: 8.14 or later
- Additional dependencies:
  - [Coq JSON](https://github.com/liyishuai/coq-json)
  - [ITreeIO](https://github.com/Lysxia/coq-itree-io)
  - [QuickChick](https://github.com/QuickChick/QuickChick/)
- Coq namespace: `AsyncTest`
- Related publication(s): none

## Building and installation instructions

The easiest way to install the latest released version of Asynchronous Test
is via [OPAM](https://opam.ocaml.org/doc/Install.html):

```shell
opam repo add coq-released https://coq.inria.fr/opam/released
opam install coq-async-test
```

To instead build and install manually, do:

``` shell
git clone https://github.com/liyishuai/coq-async-test.git
cd coq-async-test
make   # or make -j <number-of-cores-on-your-machine> 
make install
```



