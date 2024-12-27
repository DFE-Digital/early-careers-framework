#!/bin/bash

echo "Updating RubyGems..."
gem update --system -N

echo "Installing dependencies..."
gem install bundler -v 2.4.14 # Must be explicitly specified or we get an error on the subsequent bundle install.
bundle install
yarn install
yarn build
yarn build:css

echo "Creating database..."
bin/rails db:create db:schema:load 

echo "Seeding database..."
bin/rails db:seed 

echo "Installing documentation dependencies..."
cd docs
gem install bundler -v 2.6.2 # Must be explicitly specified or we get an error on the subsequent bundle install.
bundle install

echo "Building documentation..."
bundle exec middleman build --build-dir=../public/api-reference

echo "Done!"
