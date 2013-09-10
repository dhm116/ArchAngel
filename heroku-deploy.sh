#!/bin/bash
git push heroku `git subtree split --prefix brunch-app heroku_deploy`:master --force