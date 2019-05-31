#!/usr/bin/env bash

docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:4.3.1 build
