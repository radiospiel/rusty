# This file is part of the rusty ruby gem.
#
# Copyright (c) 2013 @radiospiel
# Distributed under the terms of the modified BSD license, see LICENSE.BSD
require "#{File.dirname(__FILE__)}/lib/rusty/version.rb"

Gem::Specification.new do |gem|
  gem.name     = "rusty"
  gem.version  = Rusty::VERSION
  
  gem.authors   = ["radiospiel"]
  gem.email     = ["eno@radiospiel.org"]
  gem.homepage  = "http://github.com/radiospiel/rusty"
  gem.summary   = "XML parsing without the hassle."
  
  gem.description = gem.summary

  gem.add_dependency "nokogiri"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
