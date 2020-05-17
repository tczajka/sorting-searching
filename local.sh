#!/bin/bash
set -e
bundle exec jekyll build --drafts
bundle exec jekyll serve --drafts --incremental
