# coding: UTF-8
require 'spec_helper'

describe Sherpa do

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
  end

  # This code is changing too rapidly, in an untestable way
  describe Sherpa::Formatter do
    let(:formatter) {Sherpa::Formatter}
    citations = [{citations: [{volume: 'I'}], them: {volume: 'II'}}]
    it "should work" do
      formatter.format_comparisons citations
    end
  end

end
