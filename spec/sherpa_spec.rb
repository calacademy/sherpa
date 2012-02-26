# coding: UTF-8
require 'spec_helper'
require 'citrus'

describe Sherpa do

  describe Sherpa::Preprocessor do
    let(:preprocessor) {Sherpa::Preprocessor}
    # Code under test is copied from AntCat
    it "should removed unmatched opening brackets" do
      preprocessor.preprocess('[a').should == 'a'
    end
    it "should leave a normal string alone" do
      preprocessor.preprocess('a').should == 'a'
    end
    it "should leave a normal string alone" do
      preprocessor.preprocess('[a]').should == '[a]'
    end
    it "should leave a normal string alone" do
      preprocessor.preprocess('Isis (Oken), 1833, 523,').should == 'Isis (Oken), 1833, 523'
    end
  end

  describe Sherpa::Formatter do
    let(:formatter) {Sherpa::Formatter}
    citations = [{citations: [{volume: 'I'}], them: {volume: 'II'}}]
    it "should work" do
      formatter.format_comparisons citations
    end
  end

end
