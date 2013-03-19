require 'bundler'
Bundler.setup(:default, :development)

require 'ruby-debug'
require 'simplecov'
require 'test/unit'
SimpleCov.start do
  add_filter "test/helper.rb"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rusty'

class Test::Unit::TestCase
end

