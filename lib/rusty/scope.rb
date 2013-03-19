#
# A Rusty output scope, is related to a input node, 
# and might or might not have a parent.
class Rusty::Scope < Rusty::DX
  attr :node, true
  private :node=

  def initialize(node, parent=nil)
    @node, @parent = node, parent
  end
  
  # Does this scope matches a given name?
  def has_name?(name)
    return @parent.nil? if name == "document"

    node.name == name || node.has_class?(name)
  end

  # yields all nodes starting at self up to the top.
  def up!(&block)
    yield(self)
    @parent.up!(&block) if @parent
  end
end
