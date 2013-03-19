require_relative './helper'

class TestScope < Test::Unit::TestCase
  def test_scope_names
    named = Rusty::Scope.new node("named")
    assert named.has_name?("named")
    assert named.has_name?("x")
    assert !named.has_name?("a")

    top = Rusty::Scope.new node("top")
    assert top.has_name?("top")
    assert top.has_name?("document")
  end
  
  def test_one_step_delegation
    top = Rusty::Scope.new node("top")
    mid = Rusty::Scope.new node("mid"), top
    bot = Rusty::Scope.new node("bot"), mid

    e_top = Rusty::EventScope.new(top)
    e_mid = Rusty::EventScope.new(mid)
    e_bot = Rusty::EventScope.new(bot)

    object_ids = []

    # one step delegation
    #
    # When evaluated in the context of e_mid, top must refer to
    # the top Rusty::Scope
    e_mid.instance_eval do
      object_ids = [top.object_id]
    end
    assert_equal(object_ids, [top.object_id])
  end
  
  def test_two_step_delegation
    top = Rusty::Scope.new node("top")
    mid = Rusty::Scope.new node("mid"), top
    bot = Rusty::Scope.new node("bot"), mid

    e_top = Rusty::EventScope.new(top)
    e_mid = Rusty::EventScope.new(mid)
    e_bot = Rusty::EventScope.new(bot)

    # When evaluated in the context of e_bot, 
    # top must refer to the top Rusty::Scope
    # mid must refer to the mid Rusty::Scope
    # and mid.top must not refer to the top Rusty::Scope,
    # but to a DX which belongs to mid.
    object_ids = []
    dx = nil
    e_bot.instance_eval do
      object_ids = [top.object_id, mid.object_id]
      dx = mid.top
    end
    assert_equal(object_ids, [top.object_id, mid.object_id])
    assert_kind_of(Rusty::DX, dx)
  end

  def test_setting_attributes
    top = Rusty::Scope.new node("top")
    mid = Rusty::Scope.new node("mid"), top
    bot = Rusty::Scope.new node("bot"), mid

    e_bot = Rusty::EventScope.new(bot)

    e_bot.instance_eval do
      top.name = "top"
      mid.name = "mid"
      mid.top.name = "mid.top"
      bot.name = "bot"
    end
    
    assert_equal({"name" => "top"}, top.to_ruby)
    assert_equal({"name" => "mid", "top" => {"name" => "mid.top"}}, mid.to_ruby)
    assert_equal({"name" => "bot"}, bot.to_ruby)
  end
  
  def document
    @document ||= begin
      data = File.read(__FILE__).split(/__END__\n/).last
      Nokogiri.XML(data)
    end
  end
  
  def node(name)
    document.css(name).first
  end
end
__END__
<top>
  <mid>
    <bot>
    </bot>
  </mid>
  <named class="x y z"></named>
</top>
