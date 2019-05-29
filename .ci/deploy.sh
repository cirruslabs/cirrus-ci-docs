#!/usr/bin/env sh

git remote set-url origin https://$DEPLOY_TOKEN@github.com/cirruslabs/cirrus-ci-docs/
mkdocs gh-deploy --force --remote-branch gh-pages
