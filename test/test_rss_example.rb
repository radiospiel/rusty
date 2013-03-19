require_relative './helper'

class TestRssExample < Test::Unit::TestCase
  module SimleRSS
    extend Rusty::RuleSet
    helper Rusty::Helpers::Text

    on "*"                  do end
    on "rss channel *"      do rss[node.name] = text(node) end
    on "rss channel item"   do rss.items << item end
    on "rss channel item *" do item[node.name] = text(node) end
  end

  def test_rss
    raw = File.read(__FILE__).split(/__END__\n/).last
    data = SimleRSS.transform! Nokogiri.XML(raw)
    
    expected = {
      "rss"=> {
        "title"=>"The Title", 
        "link"=>"http://the.link", 
        "description"=>"The description", 
        "language"=>"de-de", 
        "pubDate"=>"1363099965", 
        "items"=>[
          {"title"=>"Item 1", "description"=>"description 1", "link"=>"http://the.first.link"}, 
          {"title"=>"Item 2", "description"=>"description 2", "link"=>"http://the.second.link"}
        ]
      }
    }

    assert_equal(expected, data.to_ruby)
  end
end
__END__
<?xml version="1.0" encoding="ISO-8859-1" ?>
<rss version="2.0">
<channel>

<title>The Title</title>
<link>http://the.link</link>
<description>The description</description>
<language>de-de</language>
<pubDate>1363099965</pubDate>

    <item>
    <title>Item 1</title> 
    <description>   description 1    </description>
    <link>http://the.first.link</link>    
    </item>

    <item>
    <title>Item 2</title> 
    <description>   description 2    </description>
    <link>http://the.second.link</link>    
    </item>
</channel>
</rss>
