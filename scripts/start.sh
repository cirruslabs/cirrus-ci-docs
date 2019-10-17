#!/usr/bin/env bash

docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material:$(grep 'MKDOCS_VERSION:' .cirrus.yml | cut -d\  -f4)
