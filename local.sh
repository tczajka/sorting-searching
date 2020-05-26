#!/bin/bash
set -e
bundle exec jekyll build --drafts # --incremental
bundle exec jekyll serve --drafts --incremental
