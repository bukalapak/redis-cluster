# frozen_string_literal: true
# encoding: UTF-8

require 'simplecov'
require 'coveralls'

require_relative 'helper/fake_redis_cluster'

SimpleCov.formatter =
  if ENV['CI']
    Coveralls::SimpleCov::Formatter
  else
    SimpleCov::Formatter::HTMLFormatter
  end

SimpleCov.start
