<!---
This file was generated from `meta.yml`, please do not edit manually.
Follow the instructions on https://github.com/coq-community/templates to regenerate.
--->
# Asynchronous Test

[![Docker CI][docker-action-shield]][docker-action-link]

[docker-action-shield]: https://github.com/liyishuai/coq-async-test/actions/workflows/docker-action.yml/badge.svg?branch=master
[docker-action-link]: https://github.com/liyishuai/coq-async-test/actions/workflows/docker-action.yml




From interaction trees to asynchronous tests.

## Meta

- Author(s):
  - Yishuai Li [<img src="https://zenodo.org/static/images/orcid.svg" height="14px" alt="ORCID logo" />](https://orcid.org/0000-0002-5728-5903)
- License: [Mozilla Public License 2.0](LICENSE)
- Compatible Rocq/Coq versions: 8.14 or later
- Additional dependencies:
  - [Coq JSON](https://github.com/liyishuai/coq-json)
  - [ITreeIO](https://github.com/Lysxia/coq-itree-io)
  - [QuickChick](https://github.com/QuickChick/QuickChick/)
- Rocq/Coq namespace: `AsyncTest`
- Related publication(s):
  - [Testing by Dualization](https://repository.upenn.edu/handle/20.500.14332/32046) doi:[20.500.14332/32046](https://doi.org/20.500.14332/32046)

## Building and installation instructions

The easiest way to install the latest released version of Asynchronous Test
is via [OPAM](https://opam.ocaml.org/doc/Install.html):

```shell
opam repo add rocq-released https://rocq-prover.org/opam/released
opam install coq-async-test
```

To instead build and install manually, you need to make sure that all the
libraries this development depends on are installed.  The easiest way to do that
is still to rely on opam:

``` shell
git clone https://github.com/liyishuai/coq-async-test.git
cd coq-async-test
opam repo add rocq-released https://rocq-prover.org/opam/released
opam install --deps-only .
make   # or make -j <number-of-cores-on-your-machine> 
make install
```



