# This file is part of the rusty ruby gem.
#
# Copyright (c) 2013 @radiospiel
# Distributed under the terms of the modified BSD license, see LICENSE.BSD

# Helper support for Rusty.
module Rusty::Helpers
  # return all helpers
  def helpers
    @helpers ||= []
  end
  
  # set up a helper. Examples:
  #
  #  module MyParser
  #    extend Rusty::RuleSet
  #
  #    helper Rusty::Helpers::Text
  #
  #    helper do 
  #      def foo
  #        "bar"
  #      end
  #    end
  #  end
  #
  def helper(*mods, &block)
    helpers.concat mods
    helpers << Module.new.tap { |mod| mod.class_eval(&block) } if block
  end
end

# Some Text helpers.
module Rusty::Helpers::Text
  #
  # Returns a cleaned version of a node's text.
  def text(node)
    node.text.gsub(/\u200e/, "").strip
  end
end
