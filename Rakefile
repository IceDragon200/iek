#!/usr/bin/env rake
require 'rake'
require 'rake/task'
require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = []
end

task default: :yard
