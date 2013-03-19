require_relative './helper'

class TestSelector < Test::Unit::TestCase
  DATA = File.read(__FILE__).split(/__END__\n/).last
  
  def __test_selectors(klass)
    document = Nokogiri.XML(DATA)

    # test matching selectors
    assert klass.new("foo").match?(document.css("foo").first)
    assert klass.new("fi fa foo").match?(document.css("foo").first)
    assert klass.new("fi bar").match?(document.css("bar").first)
    assert klass.new("fi bar").match?(document.css("bar").last)
    
    # test non-matching selectors
    assert_false klass.new("foox").match?(document.css("foo").first)
    assert_false klass.new("fix fa foo").match?(document.css("foo").first)
    assert_false klass.new("fix fa foo").match?(nil)
    
    # test "*" special case
    assert klass.new("*").match?(document.css("bar").last)
    assert_false klass.new("*").match?(nil)
  end

  def test_css
    __test_selectors Rusty::Selector::CSS
  end

  def test_cached_ss
    __test_selectors Rusty::Selector::CachedCSS
  end
  
  def test_weight
    assert Rusty::Selector::CSS.new("*").weight     < Rusty::Selector::CSS.new("a").weight
    assert Rusty::Selector::CSS.new("a b c").weight < Rusty::Selector::CSS.new("a b c d").weight
    assert Rusty::Selector::CSS.new("a b c").weight < Rusty::Selector::CSS.new("#a").weight
  end
end

__END__
<fi>
  <fa>
    <foo>
      <bar>baz</bar>
      <bar>baz</bar>
    </foo>
  </fa>
</fi>
