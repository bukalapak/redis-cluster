# frozen_string_literal: true
# encoding: UTF-8

require 'bundler'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Default: run specs'
task default: [ :test, :lint ]

task test: :spec
task lint: :rubocop

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--require ./spec/spec_helper.rb'
end

Bundler::GemHelper.install_tasks
