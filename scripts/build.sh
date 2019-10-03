#!/usr/bin/env bash

docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material:$(grep 'MKDOCS_VERSION:' .cirrus.yml | cut -d\  -f4) build
