# CallbackBinding objects are used to provide name lookup for callbacks. 
# They are set up in such a way that unknown identifiers might traverse
# up the parents of a node to find a finally matching node. This allows
# the "top" node in the following callback to be refered by the name
# "top", like this:
#
#     on "top p" { top.attribute = "p" }
#
class Rusty::CallbackBinding < Object #BasicObject
  #
  # Create a subclass with a given name and a set of helper modules.
  def self.subclass_with_name_and_helpers(name, *helpers)
    name = name.split("::").last

    ::Class.new(self).tap do |klass|
      const_set name, klass
      klass.send :include, *helpers
    end
  end

  # create an event scope which wraps a node scope.
  def initialize(scope)
    @scope = scope
  end
  
  # -- special attributes -----------------------------------------------------
  
  # callback: set a callback proc which will be called after a node is 
  # processed completely.
  def callback(&block)
    @callback = block if block
    @callback
  end
  
  # skip!: allow to skip completely skip children.
  def skip!
    @skip = true
  end
  
  # Should children be skipped?
  def skip?
    !!@skip
  end
  
  # If the missing method is an identifier and has no arguments, this method 
  # looks in this node scope and its parent scopes for a scope with that name. 
  # If there is no such target scope, the message is forwarded to the 
  # node scope (which has its own set of magic, see Rusty::DX)
  def method_missing(sym, *args, &block)
    target = if !block && args.empty? && sym =~ /^[A-Za-z_][A-Za-z_0-9]*$/
      up_scope!(sym.to_s)
    end

    (target || @scope).send sym, *args, &block
  end
  
  private
  
  def up_scope!(name)
    @scope.up! do |scope| 
      return scope if scope.has_name?(name) 
    end

    nil
  end
end
