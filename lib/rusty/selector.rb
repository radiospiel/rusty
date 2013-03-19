# -- selector engines ---------------------------------------------------------

# A selector is an object which is created based on a selector string, and
# which implements the `weight` and `match?` methods.
module Rusty::Selector
  # A simple, nokogiri based CSS matcher.
  class CSS
    attr :matcher, :name

    # Create selector
    def initialize(selector)
      @name = @selector = selector

      # == special case: "*"
      #
      # The "*" selector matches all nodes, and Nokogiri::XML::Node#css returns 
      # a huge array of nodes, which R::S::CSS#match? would have to walk through.
      # Implementing that special case speeds up things by ~10% in the google 
      # example, and reduces memory load.
      #
      # Note: by defining it directly on <self> this special case implementation
      # also overrides match? methods defined in subclasses.
      if @selector == "*"
        def self.match?(node); !node.nil?; end
      end
    end

    # The weight of the selector; is close to, but not exactly as
    # CSS's weight definition.
    def weight
      @weight ||= @selector.split(/\s+/).inject(0) do |weight, part|
          weight += case part
            when /#/          then 1_000_000 # part with an ID, much much weight
            when /\./         then     1_000 # selector with a class
            when /^[a-zA-Z_]/ then     1_000 # node name
            else                           1
            end
        end
    end

    # Does this selector matches a specific node?
    def match?(node)
      return false unless node
      
      node.document.css(@selector).include?(node)
    end
  end

  # A cached CSS selector, caches matching nodes within a document.
  class CachedCSS < CSS
    # Does this selector matches a specific node?
    def match?(node)
      return false unless node
      
      cache_document(node.document)
      @matching_nodes.include?(node)
    end


    private

    def cache_document(document)
      return if @cached_document && @cached_document == document

      @cached_document = document
      @matching_nodes = document.css(@selector)
    end
  end

  # You probably want cached selectors, especially when working with 
  # larger documents. If these eat to much memory, try to use
  #
  # DEFAULT_SELECTOR = Rusty::Selector::CSS
  #
  # but expect exploding runtimes: this increases O(m+n) -> O(m*n).
  DEFAULT_SELECTOR = Rusty::Selector::CachedCSS

  # Create a Selector object for a given `selector` string.
  def self.new(selector)
    DEFAULT_SELECTOR.new selector
  end
end
