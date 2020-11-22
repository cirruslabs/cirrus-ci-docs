#!/usr/bin/env bash

docker run --pull --rm -it -p 8000:8000 -v ${PWD}:/docs ghcr.io/squidfunk/mkdocs-material:latest
