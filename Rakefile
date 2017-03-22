# frozen_string_literal: true
# encoding: UTF-8

require 'bundler'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'pry'

RuboCop::RakeTask.new

desc 'Default: run specs'
task default: [ :start, :test, :lint, :stop ]

task test: :spec
task lint: :rubocop

task :pry do
  binding.pry
end

task :start do
  sh '.circleci/start.sh'
end

task :stop do
  sh '.circleci/stop.sh'
end

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--require ./spec/spec_helper.rb'
end

Bundler::GemHelper.install_tasks
