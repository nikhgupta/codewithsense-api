#!/usr/bin/env rackup
# frozen_string_literal: true

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path('config/boot.rb', __dir__)

use Rack::Attack
use Rack::Parser, content_types: { 'application/json' => proc { |body| ::MultiJson.decode body } }

run Padrino.application
