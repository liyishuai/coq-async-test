<!---
This file was generated from `meta.yml`, please do not edit manually.
Follow the instructions on https://github.com/coq-community/templates to regenerate.
--->
# Asynchronous Test

[![Docker CI][docker-action-shield]][docker-action-link]

[docker-action-shield]: https://github.com/liyishuai/coq-async-test/workflows/Docker%20CI/badge.svg?branch=master
[docker-action-link]: https://github.com/liyishuai/coq-async-test/actions?query=workflow:"Docker%20CI"




From interaction trees to asynchronous tests.

## Meta

- Author(s):
  - Yishuai Li [<img src="https://zenodo.org/static/img/orcid.svg" height="14px" alt="ORCID logo" />](https://orcid.org/0000-0002-5728-5903)
- License: [Mozilla Public License 2.0](LICENSE)
- Compatible Coq versions: 8.14 or later
- Additional dependencies:
  - [Coq JSON](https://github.com/liyishuai/coq-json)
  - [ITreeIO](https://github.com/Lysxia/coq-itree-io)
  - [QuickChick](https://github.com/QuickChick/QuickChick/)
- Coq namespace: `AsyncTest`
- Related publication(s):
  - [Testing by Dualization](https://repository.upenn.edu/handle/20.500.14332/32046) doi:[20.500.14332/32046](https://doi.org/20.500.14332/32046)

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



