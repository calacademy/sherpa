# coding: UTF-8
require 'spec_helper'
require 'citrus'

describe Sherpa do
  before() {@parser = Sherpa}

  def run_spec citation, title, series_volume_issue, year, pages
    @parser.parse(citation).should == {
      title: title, year: year, series_volume_issue: series_volume_issue, pages: pages, text: citation
    }
  end

  describe "Parsing different kinds of title" do
    it "should handle a title ending with an abbreviated word" do
      run_spec 'Suppl. Ent. Syst. 1798, 435', 'Suppl. Ent. Syst.', nil, '1798', '435',
    end
    it "should handle a title ending with an unabbreviated word" do
      run_spec 'Gen. Sp. Ins. Geer, 1783, 32.', 'Gen. Sp. Ins. Geer', nil, '1783', '32'
    end
  end

  describe "Series, volume, issue" do
    it "should handle a journal with a volume" do
      run_spec 'Danske Atlas, I 1763, 621', 'Danske Atlas', 'I', '1763', '621'
    end
    it "should handle a journal with a volume" do
      run_spec 'Mant. I. 1787, 164', 'Mant.', 'I', '1787', '164'
    end
  end

end
