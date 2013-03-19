# Nokogiri extensions as used by rusty

# ---------------------------------------------------------------------

class Nokogiri::XML::Node
  # returns a nodes attributes as a hash
  def attributes_hash
    attributes.inject({}) do |hash, (name, attr)|
      hash.update name => attr.value
    end 
  end

  # returns an array of classes as Strings
  def classes
    return [] unless classes = self["class"]
    classes.strip.split(/\s+/)
  end

  # does this node has a class with a given name?
  def has_class?(name)
    @class_syms ||= classes.map(&:to_sym)
    @class_syms.include?(name.to_sym)
  end

  def parents
    return [] if parent == document
    self_and_parents(parent)
  end
  
  # return a list of all parent nodes, up until and excluding the document node.
  def self_and_parents(node=self)
    [ ].tap do |parents|
      while node.parent != node.document
        parents.unshift(node)
        node = node.parent
      end
      parents.unshift node
    end
  end

  # returns the debug node name for this node; which is a simplified CSS node name
  # name{#id}{.class}{.class}
  def simplified_name
    simplified_name = name
    if id = self["id"]
      simplified_name += "##{id}"
    end
    classes.each do |klass|
      simplified_name += ".#{klass}"
    end
    simplified_name.gsub(/^div([\.\#])/, "\\1")
  end
end

class Nokogiri::HTML::Document
  # returns the encoding as defined in the meta[http-equiv=content-type]
  # node. Available only in HTML documents.
  def meta_encoding
    # HTML5
    css("meta[charset]").each do |meta|
      next unless charset = meta.attribute("charset")

      return charset.value
    end
    
    # HTML4
    css("meta[http-equiv=content-type]").each do |meta|
      next unless content = meta.attribute("content") 
      next unless content.value.split("; ").last =~ /^charset=(.*)/

      return $1
    end

    nil
  end
end

module Nokogiri::HTML
  # loads a document from \a data. If the encoding as determined by Nokogiri
  # does not match the meta_encoding, tries to reload the data with that 
  # encoding.
  def self.with_meta_encoding(data)
    doc = Nokogiri.HTML(data)
    
    meta_encoding = doc.meta_encoding
    return doc unless meta_encoding && doc.encoding != meta_encoding
    
    # try to reread with meta_encoding
    doc2 = Nokogiri.HTML(data, nil, meta_encoding)
    return doc2 if doc2.encoding == meta_encoding

    # rereading failed, return original document
    doc
  end
end

