require 'rubygems'
require 'puppet_blacksmith/rake_tasks'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

exclude_paths = [
  "vendor/**/*",
]

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

PuppetSyntax.exclude_paths = exclude_paths

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

task :tests do
  Rake::Task[:lint].invoke
  Rake::Task[:validate].invoke
end

