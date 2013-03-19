require_relative './helper'

class TestRuleSet < Test::Unit::TestCase
  module RuleSet
    extend Rusty::RuleSet
    def self.rules_for_mode(mode); super; end

    helper do
      def a_helper_method
      end
    end
    
    on "foo", "bar" do end
    after "foo", "baz" do end
    after "html, js, erlang" do end

    on "p a" do end
    on "a" do end
    on ".a" do end
  end
  
  def test_registration
    assert_equal ["foo", "bar", "p a", "a", ".a"], RuleSet.rules_for_mode(:on).keys
    assert_equal %w(foo baz html js erlang), RuleSet.rules_for_mode(:after).keys
  end
  
  def test_best_rule
    assert_equal "p a", RuleSet.best_rule(:on, node("a")).selector.name
    assert_equal ".a",  RuleSet.best_rule(:on, node("body")).selector.name
  end
  
  
  private
  
  def data
    @data ||= File.read(__FILE__).split(/__END__\n/).last
  end
  
  def document
    @document ||= begin
      Nokogiri.HTML(data)
    end
  end
  
  def node(selector)
    document.css(selector).first 
  end
  
end

__END__
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=iso-8859-1">
  </head>
  <body class="a b d">
    <div>
      <p>
      </p>
      <p>
        <a id="anchor" foo="bar"></a>
      </p>
    </div>
  </body>
</html>
