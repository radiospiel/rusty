# encoding: UTF-8
require_relative './helper'

class TestSelector < Test::Unit::TestCase
  module RuleSet
    extend Rusty::RuleSet

    helper do
      def a_helper_method
      end
    end
    
    helper Rusty::Helpers::Text
  end

  def test_helpers
    assert_equal 2, RuleSet.helpers.length
  end
  
  def test_callback_binding_klass_includes_helpers
    callback_binding_klass = RuleSet.send(:callback_binding_klass)
    assert callback_binding_klass.public_instance_methods.include?(:a_helper_method)
    assert callback_binding_klass.public_instance_methods.include?(:text) # from Rusty::Helpers::Text
  end

  def test_text
    helper = {}.extend(Rusty::Helpers::Text)
    data = File.read(__FILE__).split(/__END__\n/).last

    document = Nokogiri.XML(data)

    assert_equal "1hr 40min - Rated Ohne Altersbeschränkung", helper.text(document.css("top span").first)
  end
end

__END__
<top>
  <span>&#8206;1hr 40min&#8206;&#8206; - Rated Ohne Altersbeschränkung&#8206;</span>
</top>
