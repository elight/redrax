require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList["specs/**_spec.rb"]
end

require 'yard'
require_relative 'lib/yard_extensions'

YARD::Rake::YardocTask.new
  
task :default => :test
