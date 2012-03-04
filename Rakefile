require 'bundler'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'

include Rake::DSL

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color']
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress -x"
  t.fork = false
end

task default: [:spec, :features]
