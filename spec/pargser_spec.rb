require 'spec_helper'
require 'pargser'
require 'ostruct'

describe 'pargser' do
  
  it 'should parse keys' do
    parser = Pargser.new "-a -b -v value! other data".split
    parser.key('-a', doc: 'flag to perform a action') {
      @a_called = true
    }
        .key('-c', '-b') {
      @b_called = true
    }
        .key('--some', default: 'test') { |v|
      @defvalue = v
    }
        .key('-v', needs_value: true) { |v|
      @v = v
    }
    expect(-> { parser.key('-a') }).to raise_error(Pargser::Error)
    
    passed = []
    rest   = parser.parse { |a| passed << a }
    rest.should == passed
    rest.should == ['other', 'data']
    
    @a_called.should be_truthy
    @b_called.should be_truthy
    @v.should == 'value!'
    @defvalue.should == 'test'
    
    doc = "\t-a\n\t\tflag to perform a action\n\t-c,-b\n\t--some value (default: test)\n\t-v value (optional)\n"
    parser.keys_doc.should == doc
  end
  
  it 'should detect required keys' do
    parser = Pargser.new ['hello']
    parser.key('-c', needs_value: true) {}
    expect(-> { parser.parse }).to raise_error(Pargser::Error, 'Required key is missing: -c')
  end
  
  it 'should detect strange keys' do
    parser = Pargser.new '-l hello'.split
    expect(-> { parser.parse }).to raise_error(Pargser::Error, 'Unknown key -l')
  end
  
  it 'should pass data that looks like keys' do
    res = Pargser.new('-- -a --b'.split).parse
    res.should == ['-a', '--b']
  end
  
  it 'should provide empty defaults' do
    parser = Pargser.new('hello'.split)
    @t == 'wrong'
    parser.key('-t', default: nil) { |val|
      @t = val
    }
    parser.key('-q', default: false) { |val|
      @q = val
    }
    parser.parse.should == ['hello']
    @t.should == nil
    @q.should == false
  end

  it 'should run usage example' do

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

  end

end
