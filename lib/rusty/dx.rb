require "forwardable"

# A flexible data object which may act either as a hash or an array.
# It automatically initialises as array or hash, when used in a context
# which requires one or the other usage.
class Rusty::DX
  
  # -- set up storage ---------------------------------------------------------

  # The hash storage implementation.
  class Dict < Hash
    DELEGATE_METHODS  = [:[], :[]=, :key?]
    module Delegator
      extend Forwardable
      delegate DELEGATE_METHODS => :@storage
    end

    def initialize
      super { |hash, key| hash[key] = Rusty::DX.new }
    end
  end

  # The array storage implementation.
  class List < Array
    DELEGATE_METHODS = [:[], :[]=, :<<, :first]
    module Delegator
      extend Forwardable
      delegate DELEGATE_METHODS => :@storage
    end
  end

  def inspect
    "<#{@storage ? @storage.inspect : "nil"}>"
  end

  private
  
  def __storage(klass)
    if @storage
      raise ArgumentError, "Cannot change type to #{klass}" unless @storage.is_a?(klass)
      @storage
    else
      extend klass::Delegator
      @storage = klass.new
    end
  end

  ## -- test mode, convert to ruby objects ------------------------------------

  public
  
  # Is this object in hash mode?
  def dict?; @storage.is_a?(Dict); end

  # Is this object in list mode?
  def list?; @storage.is_a?(List); end

  
  def self.to_ruby(object)
    object.is_a?(Rusty::DX) ? object.to_ruby : object
  end
  
  # convert into a ruby object
  def to_ruby
    case @storage
    when Dict
      items = @storage.inject([]) do |ary, (k, v)| 
        ary << k << Rusty::DX.to_ruby(v) 
      end
      Hash[*items]
    when List
      @storage.map { |v| Rusty::DX.to_ruby(v) }
    end
  end
  
  # -- method missing magic ---------------------------------------------------
  
  public
  
  # method_missing automatically sets up storage, and matches method names
  # with hash keys (when in Dict mode)
  #
  # When setting up storage for this object the storage type is determined
  # by these conditions:
  #
  # - identifiers, as getters (i.e. with no arguments), result in Dict storage 
  # - identifiers, as setters (i.e. with one argument, ending in '='), result
  #   in Dict storage
  # - the [] and []= operators result in List storage, if the argument is
  #   an integer, else in Dict storage.
  # - Methods that are only implemented in the List or Dict storage determine
  #   the storage type accordingly. These are set up automatically by evaluating
  #   {List/Dict}::DELEGATE_METHODS. For example, you cannot push (<<) into a
  #   Hash, nor you can't ask an array for existence of a key?
  EXCLUSIVE_LIST_METHODS = List::DELEGATE_METHODS - Dict::DELEGATE_METHODS
  EXCLUSIVE_DICT_METHODS = Dict::DELEGATE_METHODS - List::DELEGATE_METHODS
  
  def method_missing(sym, *args, &block)
    # A number of missing methods try to initialize this object either as
    # a hash or an array, and then forward the message to storage.
    case sym
    when :[], :[]=
      raise "#{self.class.name}##{sym}: Missing argument" unless args.length >= 1
      return __storage(args.first.is_a?(Integer) ? List : Dict).send(sym, *args)
    when /^([_A-Za-z][_A-Za-z0-9]*)$/
      if args.length == 0 && block.nil?
        return __storage(Dict)[sym.to_s]
      end
    when /^([_A-Za-z][_A-Za-z0-9]*)=$/
      if args.length == 1 && block.nil?
        return __storage(Dict)[$1] = args.first
      end
    else
      return __storage(List).send sym, *args, &block  if EXCLUSIVE_LIST_METHODS.include?(sym)
      return __storage(Dict).send sym, *args, &block  if EXCLUSIVE_DICT_METHODS.include?(sym)
    end

    # -- we could not set up nor delegate to storage; run super instead
    #    (this will raise a unknown method exception.)
    super
  end
end
