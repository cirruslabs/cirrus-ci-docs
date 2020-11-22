#!/usr/bin/env bash

docker run --pull --rm -it -v ${PWD}:/docs ghcr.io/squidfunk/mkdocs-material:latest build
