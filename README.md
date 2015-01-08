# Pargser

The ruby way to write CLI tools without headache of parsing command line options. Let you not to
spend time on it and focus on functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pargser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pargser

## Usage

Very straightforward

    p = Pargser.new.key('-f', '--fantastic') {
      @fantastic = true
    }
    .key('--omit-me', doc: 'the description is optional') {
      @omit = true
    }
    .key('--this-is', '-t', needs_value: true, doc: 'you should specify it!') { |value|
      # Note that this key has no default, e.g. required
      @this_is = value
    }
    .key('--pargser', '-p', default: 'rules!') { |value|
      # There is a default so it is ok to omit it in CL
      @pargser = value
    }

    # Parse, and return non-key arguments as array in order of appearance
    command_line = %w|-f --this-is just_fine foo bar|
    p.parse(command_line).should == ['foo', 'bar']

    # or you can use it with blocks if you prefer to:
    args = []
    p.parse(command_line) { |file|
      args << file
    }
    args.should == ['foo', 'bar']

    # values now are set as requested:
    @fantastic.should be_truthy
    @omit.should be_falsey
    @this_is.should == 'just_fine'
    @pargser.should == 'rules!'

    # It can easily generate also specifications:

    expected_docs = <<END
	-f,--fantastic
	--omit-me
		the description is optional
	--this-is,-t value (optional)
		you should specify it!
	--pargser,-p value (default: rules!)
    END

    p.keys_doc.should == expected_docs

For details please consult documentation:

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pargser/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
