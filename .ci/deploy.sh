#!/usr/bin/env sh

git config --global user.name "Cirrus CI"
git config --global user.name "hello@cirruslabs.org"
git remote set-url origin https://$DEPLOY_TOKEN@github.com/cirruslabs/cirrus-ci-docs/
mkdocs --verbose gh-deploy --force --remote-branch gh-pages
