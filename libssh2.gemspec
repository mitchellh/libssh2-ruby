# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "libssh2/version"

Gem::Specification.new do |s|
  s.name        = "libssh2"
  s.version     = LibSSH2::VERSION
  s.authors     = ["Mitchell Hashimoto"]
  s.email       = ["mitchell.hashimoto@gmail.com"]
  s.homepage    = ""
  s.summary     = "libssh2 Ruby bindings."
  s.description = "libssh2 Ruby bindings."

  s.rubyforge_project = "libssh2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "mini_portile", "~> 0.2.2"
  s.add_development_dependency "rake-compiler", "~> 0.8.0"
  s.add_development_dependency "yard", "~> 0.7.5"
  # s.add_runtime_dependency "rest-client"
end
