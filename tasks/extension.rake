require "bundler/gem_helper"
require "rake/extensiontask"

# This gives us access to our gemspec that is managed by Bundler.
# This requires Bundler 1.1.0.
gem_helper = Bundler::GemHelper.new(Dir.pwd)
Rake::ExtensionTask.new("libssh2_ruby_c", gem_helper.gemspec) do |ext|
  ext.cross_compile = true
end
