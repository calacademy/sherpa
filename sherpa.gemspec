# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sherpa/version"

Gem::Specification.new do |s|
  s.name        = "sherpa"
  s.version     = Sherpa::VERSION
  s.authors     = ["Mark Wilden"]
  s.email       = ["mark@mwilden.com"]
  s.homepage    = ""
  s.summary     = %q{The SHEborn PArser}
  s.description = %q{Parses the citations in Index Animalium}

  s.rubyforge_project = "sherpa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('aruba')
  s.add_development_dependency('citrus')
  s.add_development_dependency('lll')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('rake','~> 0.9.2')
  s.add_development_dependency('rspec')
  s.add_dependency('methadone')
end
