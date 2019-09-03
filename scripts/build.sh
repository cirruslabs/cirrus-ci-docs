#!/usr/bin/env bash

docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:4.4.2 build
