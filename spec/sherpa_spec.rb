# coding: UTF-8
require 'spec_helper'
require 'citrus'

describe Sherpa do

  describe Sherpa::Parser do
    let(:parser) {Sherpa::Parser}

    def run_spec citation, title, series_volume_issue, date, pages
      parser.parse(citation).should == {citations: [{
        title: title, date: date, series_volume_issue: series_volume_issue, pages: pages
      }]}
    end

    describe "Parsing different kinds of title" do
      it "should handle a title ending with an abbreviated word" do
        run_spec 'Suppl. Ent. Syst. 1798, 435', 'Suppl. Ent. Syst.', nil, '1798', '435',
      end
      it "should handle a title ending with an unabbreviated word" do
        run_spec 'Gen. Sp. Ins. Geer, 1783, 32.', 'Gen. Sp. Ins. Geer', nil, '1783', '32'
      end
      it "handle an abbreviation that's not a roman number" do
        run_spec 'F. Boica, I. 1798, 542', 'F. Boica', 'I.', '1798', '542'
      end
      it "should handle a parenthesized phrase before the volume" do
        run_spec 'Nat. Ins. (Käfer) II. 1789, 53', 'Nat. Ins. (Käfer)', 'II.', '1789', '53'
      end
    end

    #describe "Combinations" do
      #it "should handle bracketed page without date" do
        #run_spec 'Exot. Schmett. 1978, 23', 'Exot. Schmett.', 'II.', nil, '[23]'
      #end
    #end

    describe "Series, volume, issue" do
      it "should handle a journal with a volume" do
        run_spec 'Danske Atlas, I 1763, 621', 'Danske Atlas', 'I', '1763', '621'
      end
      it "should handle a journal with a volume" do
        run_spec 'Mant. I. 1787, 164', 'Mant.', 'I.', '1787', '164'
      end
      it "should handle roman numeral volume numbers" do
        for number in ['III', 'I', 'II', 'IV', 'V']
          run_spec "Mant. #{number}. 1787, 164", 'Mant.', number + '.', '1787', '164'
        end
      end
      it "should handle a journal with a volume and a series" do
        run_spec 'Uitl. Kapellen, I (8) 1776, 146', 'Uitl. Kapellen', 'I (8)', '1776', '146'
      end
      it "should handle any number in the issue" do
        run_spec 'Uitl. Kapellen, I (43) 1776, 146', 'Uitl. Kapellen', 'I (43)', '1776', '146'
      end
      it "should handle an edition" do
        run_spec 'Syst. Nat., ed. 13, I. 1789, 1900', 'Syst. Nat.', 'ed. 13, I.', '1789', '1900'
      end
      it "should handle an issue without a volume" do
        run_spec 'Ency. Méth. (Vers) (2) 1792, 750', 'Ency. Méth. (Vers)', '(2)', '1792', '750'
      end
      it "should handle a placeholder, when it's just a hyphen" do
        run_spec 'Ins. Afr. Amer. (-) 1806, 18', 'Ins. Afr. Amer.', '(-)', '1806', '18'
      end
      it "should handle a placeholder, even when it's UTF-16" do
        run_spec 'Ins. Afr. Amer. (—) 1806, 18', 'Ins. Afr. Amer.', '(—)', '1806', '18'
      end
      #it "should handle 'Tab.' as part of the series/volume/issue" do
        #run_spec 'Exot. Schmett. II. Tab. [23]', 'Exot. Schmett.', 'II. Tab.', nil, '[23]'
      #end
    end

    describe "Date" do
      it "should handle a year range" do
        run_spec 'Ins. Afr. Amér. (—) 1813-20, 168', 'Ins. Afr. Amér.', '(—)', '1813-20', '168'
      end
      it "should handle a missing date" do
        run_spec 'Exot. Schmett. II. 1784, 23', 'Exot. Schmett.', 'II.', '1784', '23'
      end
    end

    describe "Multipart citations" do
      it "should handle it when both parts are complete" do
        parser.parse('Danske Atlas, I. 1763, 621 ; & Danischer Atlas, I. 1765, 401.').should == {
          citations: [
            {
              title: 'Danske Atlas',
              series_volume_issue: 'I.',
              date: '1763',
              pages: '621',
            },
            {
              title: 'Danischer Atlas',
              series_volume_issue: 'I.',
              date: '1765',
              pages: '401',
            }
          ]
        }
      end
    end

  end

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

  describe Sherpa::Comparer do
    let(:comparer) {Sherpa::Comparer}
    it "should return no matches if there aren't any" do
      citation = {citations: []}
      comparer.compare_us_and_them(citation).should == {}
    end
    it "should return a match if there is one" do
      citation = {citations: [{title: 'Ants'}], them: {title: 'Ants'}}
      comparer.compare_us_and_them(citation).should == {
        comparison: {title: :same}
      }
    end
    it "should return a difference if there is one" do
      citation = {citations: [{title: 'Ants'}], them: {title: 'Bees'}}
      comparer.compare_us_and_them(citation).should == {
        comparison: {title: :different}
      }
    end
    it "should handle all the regular fields" do
      citation = {citations: [{title: 'Ants', date:'1980'}], them: {title: 'Bees', date: '1980'}}
      comparer.compare_us_and_them(citation).should == {
        comparison: {title: :different, date: :same}
      }
    end
    describe "comparing series/volume/issue" do
      it "should return a match if there is one" do
        citation = {citations: [{series_volume_issue: 'I'}], them: {volume: 'I'}}
        comparer.compare_us_and_them(citation).should == {
          comparison: {series_volume_issue: :same}
        }
      end
      it "should return a difference if the volume differs" do
        citation = {citations: [{series_volume_issue: 'I'}], them: {volume: 'II'}}
        comparer.compare_us_and_them(citation).should == {
          comparison: {series_volume_issue: :different}
        }
      end
      it "should return a difference if the number differs" do
        citation = {citations: [{series_volume_issue: 'I'}], them: {number: 'II'}}
        comparer.compare_us_and_them(citation).should == {
          comparison: {series_volume_issue: :different}
        }
      end
    end
  end

  describe Sherpa::Formatter do
    let(:formatter) {Sherpa::Formatter}
    citations = [{citations: [{series_volume_issue: 'I'}], them: {number: 'II'}}]
    it "should work" do
      formatter.format_comparisons citations
    end
  end
end
