# Ever wanted to parse XML, but hated all the hassle?

Rusty is here to help. Lets start with a small example:

    require "rusty"
    
    # A simple RSS parser
    module SimpleRSS
      extend Rusty::RuleSet
      helper Rusty::Helpers::Text

      on "*"                  do end
      on "rss channel *"      do rss[node.name] = text(node) end
      on "rss channel item"   do rss.items << item end
      on "rss channel item *" do item[node.name] = text(node) end
    end

    doc = Nokogiri.XML File.read("stressfaktor.xml")
    data = SimpleRSS.transform! doc
    p data.rss.to_ruby

Interested? Read on.

## Transforming nodes

Each XML and HTML document, after being parsed by Nokogiri, is represented as a tree of nodes.
A transformation would visit all the nodes in the input document and do something with the data
in it. A trivial 1:1 transformation would recreate the tree with the same data. This is obviously
not what you want; what you want is probably to build a *different* tree, with some information, 
and/or to do something else entirely.

rusty is here to help you.

It **let you define procedures to run on nodes, specified by CSS selectors**, and it **provides a simple name lookup when in fact creating a data structure**.

## Defining callbacks

Rusty knows two different kind of callbacks. The `on` callback, which is run before processing a node's children, and the `after` callback, which is run once all children have been visited.

    module SimpleRSS
      extend Rusty::RuleSet

      on "rss channel item"       do puts "Hu! An item node" end
      on "rss channel item *"     do puts "A child of an item" end
      after "rss channel item"    do puts "Now I have seen all of the item's children" end
    end

There is an additional way to define a callback, which makes some sense if you need both an "on" and an "after" callback for the same nodes, and probably want to share some information between these:
  
    module SimpleRSS
      extend Rusty::RuleSet

      on "rss channel item"       do 
        puts "Hu! An item node" 
        callback do
          puts "Now I have seen all of the item's children" end
        end
      end
    end

## Defining callbacks

Rusty knows two different kind of callbacks. The `on` callback, which is run before processing a node's children, and the `after` callback, which is run once all children have been visited.

    module SimpleRSS
      extend Rusty::RuleSet

      on "rss channel item"       do puts "Hu! An item node" end
      on "rss channel item *"     do puts "A child of an item" end
      after "rss channel item"    do puts "Now I have seen all of the item's children" end
    end

There is an additional way to define a callback, which makes some sense if you need both an "on" and an "after" callback for the same nodes, and probably want to share some information between these:
  
    module SimpleRSS
      extend Rusty::RuleSet

      on "rss channel item"       do 
        puts "Hu! An item node" 
        callback do
          puts "Now I have seen all of the item's children" end
        end
      end
    end

`after` and `callback` callbacks can coexist.

## Creating output data

One case to parse XML is to recreate some kind of data structure which resembles some or all of the XML's input. To support this mode of operation rusty "mirrors" input nodes with output data nodes. To further help you rusty comes with a nimble name lookup scheme in its callbacks. Whenever you use an undeclared name in a callback, rusty goes up to the parent of the document to find a node with a matching name:

    module SimpleRSS
      extend Rusty::RuleSet

      on "rss" do
        rss.item_count = 0
        callback do
          puts "There are #{rss.item_count} items in the input"
        end
      end
      
      on "rss channel item" do 
        rss.count += 1
      end
    end

What happens with the resulting data is up to you. By default rusty throws away all resulting data except what belongs to the top node of the document. In the above example SimpleRSS.transform! would return a hash 

    { count => <some_number> }

If you want to keep a node's data you must put it somewhere, as in the following example:

    on "rss channel item"   do rss.items << item end

## Rusty data nodes

A Rusty data node (of type Rusty::DX), is a mongrel of a `Hash`, an `Array`, and `nil`. Unless set to something - i.e. as long as being `nil` - it might turn into an Array or a Hash-like structure, depending on what you do to them.

The following makes `rss` a hash:

    rss.key?(:foo)
    rss.item_count = 0 # Hash entries are automatically created

while the following makes it an array

    rss << 1
    rss[5] = 25

To get back a stupid ruby object use the `.to_ruby` method, i.e.

    rss.to_ruby # => [ 1, nil, nil, nil, nil, 5 ]

## ..or something else?

Of course you are free to do whatever. After all, each callback is just a piece of ruby code.

    module SimpleRSS
      extend Rusty::RuleSet
      helper Rusty::Helpers::Text
      
      on "rss channel item *"     do item[node.name] = text(node) end
      after "rss channel item"    do puts "Found an item: #{item.to_ruby}" end
    end

## Helpers and the callback scope

Note that callbacks get a special scope. This scope - a Rusty::CallbackBinding - is responsible for looking up names up the node tree. The only value defined there - apart from things like `object_id`, `class`, etc. is `node`, which refers to the input node.

If you need special functionality you should define helper methods and modules, as in the following example:

    module SimpleRSS
      extend Rusty::RuleSet
      helper Rusty::Helpers::Text
      helper do
        def a_helper_method(*args)
        end
      end
      on "rss channel item *"     do a_helper_method 1, 2, 3  end
    end

Rusty comes with the Rusty::Helpers::Text module, which provides a single helper method, `text`, which returns a node's text after cleaning it up.

# That is all.

Rusty does have a number of shortcomings.

- It does not support namespaces,
- it's CSS selector matching could be faster, 
- the selector weighting could be more correct,

Don't hesitate to fork away and send pull requests!
