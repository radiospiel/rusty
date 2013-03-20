# This file is part of the rusty ruby gem.
#
# Copyright (c) 2013 @radiospiel
# Distributed under the terms of the modified BSD license, see LICENSE.BSD

module Rusty::RuleSet
  include Rusty::Helpers

  # A rule combines a selector with a proc.
  class Rule < Struct.new(:selector, :proc)
  end

  # record a rule for any of these selectors.
  #
  # This rule will be activated when a node gets processed.
  def on(*selectors, &block)
    register_rule(:on, *selectors, &block)
  end

  # record a rule for any of these selectors.
  #
  # This rule will be activated when a node's processing is done.
  #
  # Note: The after method is similar to
  # 
  #  on "selector" do
  #    callback do
  #      do_something
  #    end
  #  end
  def after(*selectors, &block)
    register_rule(:after, *selectors, &block)
  end
  
  private
  
  # Return a hash of rules in a given mode.
  def rules_for_mode(mode)
    @rules ||= {}
    @rules[mode] ||= {}
  end

  # Register a rule for a number of selectors in a given mode.
  # Mode should be :on or :after
  def register_rule(mode, *selectors, &block)
    rules = rules_for_mode(mode)

    selectors.
      map  { |selector| selector.split(",").map(&:strip) }.
      flatten.
      each { |selector| 
        STDERR.puts "#{name}, in mode :#{mode}: redefining rule for #{selector}" if rules[selector]
        rules[selector] = Rule.new(Rusty::Selector.new(selector), block) 
      }
  end
  
  public
  
  # return the best matching rule for a given node
  # Mode should be :on or :after
  def best_rule(mode, node)
    rules_for_mode(mode).values.
      select  { |rule| rule.selector.match?(node) }.
      sort_by { |rule| rule.selector.weight }.
      last
  end

  private
  
  # returns the class for event scopes in this RuleSet. This is a subclass of
  # Rusty::CallbackBinding, which is named after the current modules name (i.e. if
  # RuleSet is extended into a Module Foo, the subclass will be named Rusty::
  # CallbackBinding::Foo) and which has all helpers correctly loaded. 

  def callback_binding_klass
    @callback_binding_klass ||= Rusty::CallbackBinding.subclass_with_name_and_helpers name, *helpers
  end

  public
  
  # transform a node, and return transformed data.
  def transform!(node, scope = nil)
    if node.is_a?(Nokogiri::XML::Document)
      node = node.root
    end

    scope ||= Rusty::Scope.new(node)

    # The callback scope for this node.
    callback_binding = callback_binding_klass.new(scope) 

    has_rule = false
    
    [ :on, :after ].each do |mode|
      # find explicit rule for this node. Warn if there is none.
      if rule = best_rule(mode, node)
        has_rule = true
        callback_binding.instance_eval(&rule.proc)
      end

      # in :on mode: process children, unless explicitely skipped.
      if mode == :on && !callback_binding.skip?
        node.children.each do |child|
          next if child.text? || child.cdata?
          next if child.comment?

          transform! child, Rusty::Scope.new(child, scope)
        end
      end

      # run callback
      if callback = callback_binding.callback
        callback_binding.instance_eval(&callback)
      end
    end
    
    unless has_rule
      path = node.self_and_parents.map(&:simplified_name).join(" > ")
      STDERR.puts "no rule registered: #{path}" 
    end

    scope
  end
end
