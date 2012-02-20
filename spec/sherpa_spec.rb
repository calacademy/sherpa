# coding: UTF-8
require 'spec_helper'
require 'citrus'

describe Sherpa do
  before() {@parser = Sherpa}

  def run_spec citation, title, year, pages
    @parser.parse(citation).should == {
      title: title, year: year, pages: pages, text: citation
    }
  end

  describe "Parsing different kinds of title" do
    it "should handle a title ending with an abbreviated word" do
      run_spec 'Suppl. Ent. Syst. 1798, 435', 'Suppl. Ent. Syst.',  '1798', '435',
    end
    it "should handle a title ending with an unabbreviated word" do
      run_spec 'Gen. Sp. Ins. Geer, 1783, 32.', 'Gen. Sp. Ins. Geer', '1783', '32'
    end
  end

  #it "should handle a journal with a series/volume/issue" do
    #Sherborn.parse('Uitl. Kapellen, I (8) 1776, 146').value.should == {
      #title: 'Uitl. Kapellen',
      #series_volume_issue: 'I (8)',
      #year: '1776',
      #pages: '146',
    #}
  #end

  #it "requires an abbreviated word to begin with a capital letter" do
    #-> {Sherborn.parse('rt.', root: :abbreviated_word)}.should raise_error Citrus::ParseError
  #end

  #it "requires an abbreviated word to end with a period" do
    #-> {Sherborn.parse('Rt', root: :abbreviated_word)}.should raise_error Citrus::ParseError
  #end

end
