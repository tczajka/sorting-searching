#!/bin/bash
set -e
bundle exec jekyll serve --drafts # --incremental
bundle exec jekyll serve --drafts --incremental
