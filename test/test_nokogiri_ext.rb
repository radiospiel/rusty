require_relative './helper'

class TestNokogiriExt < Test::Unit::TestCase
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
  
  def test_classes
    body = node("body")
    assert_equal %w(a b d), body.classes
    assert_true body.has_class?("a")
    assert_true body.has_class?("b")
    assert_false body.has_class?("c")
  end
  
  def test_attributes_hash
    assert_equal({"id" => "anchor", "foo" => "bar"}, node("a").attributes_hash)
    assert_equal({}, node("div").attributes_hash)
  end
  
  def test_parents
    assert_equal ["html", "body", "div", "p", "a"], node("a").self_and_parents.map(&:name)
    assert_equal ["html", "body", "div", "p"], node("a").parents.map(&:name)

    assert_equal ["html"], node("html").self_and_parents.map(&:name)
    assert_equal [], node("html").parents.map(&:name)
  end
  
  def test_simplified_name
    assert_equal "body.a.b.d", node("body").simplified_name
    assert_equal "a#anchor", node("a").simplified_name
  end
  
  def test_meta_encoding
    html4 = "<html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head></html>"
    html5 = "<html><head><meta charset='UTF-8'></head></html>"

    assert_equal "UTF-8", Nokogiri.HTML(html4).meta_encoding
    assert_equal "UTF-8", Nokogiri.HTML(html5).meta_encoding
  end
  
  def test_with_meta_encoding
    doc = Nokogiri::HTML.with_meta_encoding data
    assert_equal("iso-8859-1", doc.meta_encoding)
    assert_equal("iso-8859-1", doc.encoding)
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
