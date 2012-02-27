# coding: UTF-8
require 'spec_helper'

describe Sherpa::Preprocessor do
  let(:preprocessor) {Sherpa::Preprocessor}

  describe "Removing unmatched brackets" do
    # The code under test is copied from AntCat, so
    # these tests are minimal
    it "should removed unmatched opening brackets" do
      preprocessor.preprocess('[a').should == 'a'
    end
    it "should leave a normal string alone" do
      preprocessor.preprocess('a').should == 'a'
    end
    it "should leave a normal string alone" do
      preprocessor.preprocess('[a]').should == '[a]'
    end
  end

  it "should remove a trailing comma" do
    preprocessor.preprocess('Isis (Oken), 1833, 523,').should == 'Isis (Oken), 1833, 523'
  end

  it "should correct 'Conch,' to 'Conch.'" do
    preprocessor.preprocess('Conch,').should == 'Conch.'
  end

  it "should fix incorrect ending brackets" do
    preprocessor.preprocess('[<em>vero propius</em> 1847)').should == '[<em>vero propius</em> 1847]'
  end

  it "should fix misspelled strings" do
    for test in [['pi. 1', 'pl. 1']]
      preprocessor.preprocess(test[0]).should == test[1]
    end
  end

end
