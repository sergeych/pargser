require 'pargser'
require 'set'

# The Ruby-Style (e,g, nice and laconic) command line parser that easily supports:
#
# * --keys
#   optional keys with any number of aliases aliases
#
# * -name value
#   key that wants value (next agrument), optionally with default value
#
# * --
#   no more keys past double dash
#
# and regular (all other) arguments.
#
# Also supports automatic documentation generation
#
class Pargser

  VERSION = "0.1.2"

  # The pargser errors, e.g. wrong usage or command line does not fit specified
  # keys ocnstraints.
  class Error < ArgumentError;
  end

  # Create parser instance with a list of arguments. Otherwise, arguments can
  # be passed to #parse call.
  #
  # @param args [Array] optional command line arguments. Usually it is more convenient
  #     to pass them to #parse
  def initialize args=[]
    @args     = args
    @keys     = {}
    @required = Set.new
    @docs     = []
  end

  # Register a new key handler. When #parse fonds a key (or an alias) the blocks will be called.
  # Invocation order is same as in the command line.
  #
  # @param name [String] key name
  #
  # @param aliases [Array(String)] any number of aliases for the key
  #
  # @param needs_value [Boolean]  if set then the parser wants a value argument after the
  #   key which will be passed to block as an argument. if default param is not set and
  #   the key will not be detected, Pargser::Error will be raised
  #
  # @param default [String] default value. if set, needs_value parameter can be omitted -
  #   the handler block will be invoked with either this value or with one from args.
  #
  # @param doc [String] optional documentation string that will be used in #keys_doc
  #
  # @return [Pargser] self
  #
  # @yield block if the key is found with optional value argument
  #
  def key name, *aliases, needs_value: false, doc: nil, ** kwargs, &block
    k = name.to_s

    default_set = false
    default = nil
    if kwargs.include?(:default)
      default = kwargs[:default]
      needs_value = true
      default_set = true
    end

    @keys.include?(k) and raise Error, "Duplicate key registration #{k}"
    data = @keys[k] = OpenStruct.new required:    false,
                                     needs_value: needs_value,
                                     block:       block,
                                     doc:         doc,
                                     key:         k,
                                     aliases:     aliases,
                                     default:     default,
                                     default_set: default_set
    @docs << data
    aliases.each { |a| @keys[a.to_s] = data }
    @required.add(data) if needs_value
    self
  end

  # Process command line and call key handlers in the order of
  # appearance. Then call handlers that keys which need values
  # and were not called and have defaults, or raise error.
  #
  # The rest of arguments (non-keys) are either yielded or returned
  # as an array.
  #
  # You can optionally set other arguments than specified in constructor
  #
  # @param args [Array(String)]  to parse. If specified, arguments passed to constructor
  #                will be ignored and lost
  # @return [Array] non-keys arguments (keys after '--' or other arguments)
  # @yield [String] non keys arguments in order of appearance (same as returned)
  def parse args=nil
    @args = args.clone if args
    no_more_keys = false
    rest         = []
    required_keys = @required.clone

    while !@args.empty?
      a = @args.shift
      case
        when no_more_keys
          rest << a
        when (data = @keys[a])
          required_keys.delete data
          if data.needs_value
            value = @args.shift or raise "Value needed for key #{a}"
            data.block.call value
          else
            data.block.call
          end
        when a == '--'
          no_more_keys = true
        when a[0] == '-'
          raise Error, "Unknown key #{a}"
        else
          rest << a
      end
    end
    required_keys.each { |data|
      raise Error, "Required key is missing: #{data.key}" if !data.default_set
      data.block.call data.default
    }
    block_given? and rest.each { |a| yield a }
    rest
  end

  # Generate keys documentation multiline text
  def keys_doc
    res = []
    @docs.each { |d|
      keys = [d.key] + d.aliases
      str = "\t#{keys.join(',')}"
      if d.needs_value
        str += " value"
        if d.default
          str += " (default: #{d.default})" if d.default
        else
          str += ' (optional)'
        end
      end
      res << str
      d.doc and d.doc.split("\n").each { |l| res << "\t\t#{l}" }
    }
    res.join("\n")+"\n"
  end

end

