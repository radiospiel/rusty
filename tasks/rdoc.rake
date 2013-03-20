# This file is part of the rusty ruby gem.
#
# Copyright (c) 2013 @radiospiel
# Distributed under the terms of the modified BSD license, see LICENSE.BSD

$:.unshift File.expand_path("../lib", __FILE__)

require 'rdoc/task'

RDoc::Task.new do |rdoc|
  require_relative "../lib/rusty/version"
  version = Rusty::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rusty #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
