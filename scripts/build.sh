#!/usr/bin/env bash

docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:{cat theme/.material-version.cfg} build
