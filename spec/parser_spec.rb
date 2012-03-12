# coding: UTF-8
require 'spec_helper'

describe Sherpa::Parser do
  let(:parser) {Sherpa::Parser}

  def parse_and_check citation, title, volume, date, pages
    parser.parse(citation).should == {citations: [{
      title: title, date: date, volume: volume, pages: pages
    }]}
  end

=begin
  Tricky ones
  Is (Cambr. 1845) part of the issue or the date? 15 Rept. Brit. Assoc. (Cambr. 1845) 1846, 282
=end

  describe "Exemplars" do

    it "should handle Linnaeus" do
      parse_and_check 'Linn. Syst. Nat., ed. 13, I. 1789, 1849.', 'Linn. Syst. Nat.', 'ed. 13, I.', '1789, 1849', nil
    end
    it "should handle TITLE VOLUME DATE, PAGE" do
      parse_and_check 'Ent. Syst. IV. 1794, 262', 'Ent. Syst.', 'IV.', '1794', '262'
    end
    it "should handle TITLE VOLUME, DATE" do
      parse_and_check 'Exot. Schmett. II. Tab. [168], 18—', 'Exot. Schmett.', 'II. Tab. [168]', '18-', nil
    end
    it "should handle TITLE, DATE, PAGE (no volume; title does not end in a period)" do
      parse_and_check 'Gen. Sp. Ins. Geer, 1783, 32.', 'Gen. Sp. Ins. Geer', nil, '1783', '32'
    end
    it "should handle TITLE VOLUME (ISSUE) DATE, PAGE" do
      parse_and_check 'Uitl. Kapellen, I. (8) 1776, 146', 'Uitl. Kapellen', 'I. (8)', '1776', '146'
    end
    it "should handle TITLE (TITLE) (ISSUE) DATE, PAGE" do
      parse_and_check 'Ency. Méth. (Vers) (2) 1792, 750', 'Ency. Méth. (Vers) (2)', nil, '1792', '750'
    end
    it "should handle TITLE VOLUME" do
      parse_and_check 'Exot. Schmett. II. Tab. [103]', 'Exot. Schmett.', 'II. Tab. [103]', nil, nil
    end
    it "should handle TITLE DATE" do
      parse_and_check 'Classif. Batrach. 1838', 'Classif. Batrach.', nil, '1838', nil
    end
    it "should handle a bracketed year range without a trailing comma followed by a plate section in parentheses" do
      parse_and_check "Ill. Indian Zool. I (—) [1830-2] (pl. 17)", 'Ill. Indian Zool.', 'I (-)', '[1830-2]', '(pl. 17)'
    end
    it "should handle an exotic Schmett" do
      parse_and_check 'Exot. Schmett. II. Tab. Hamadryas amphinosa', 'Exot. Schmett.', 'II. Tab. Hamadryas amphinosa', nil, nil
    end
    it "should handle the Atlas..Adour" do
      parse_and_check 'Atlas to Conch, foss. tert. Adour, 1840-46 [vero propius 1847] Turbinellus, pl. iii.',
        'Atlas to Conch. foss. tert. Adour', nil, '1840-46 [vero proprius 1847]', 'Turbinellus, pl. iii'
    end
    it "should handle this one by doing its best, then putting the rest in :unparsed" do
      parser.parse("Revue Entom. I (—) 1833, Descr. d'esp. nouv., [no. 9").should == {
        citations: [
          {title: 'Revue Entom.', volume: 'I (-)', date: '1833', pages: nil, unparsed: "Descr. d'esp. nouv., no. 9"},
        ]
      }
    end
    it "should handle multipart citations where both parts are complete" do
      parser.parse('Danske Atlas, I. 1763, 621 ; & Danischer Atlas, I. 1765, 401.').should == {
        citations: [
          {title: 'Danske Atlas', volume: 'I.', date: '1763', pages: '621'},
          {title: 'Danischer Atlas', volume: 'I.', date: '1765', pages: '401'},
        ]
      }
    end
    it "should handle a multipart citation with ex" do
      parser.parse('Classif. Batrach. 1838,-ex Mém. Soc. Sci. Nat. Neuchâtel, II. 1839 [1840], 59').should == {
        citations: [
          {title: 'Classif. Batrach.', volume: nil, date: '1838', pages: nil},
          {title: 'Mém. Soc. Sci. Nat. Neuchâtel', volume: 'II.', date: '1839 [1840]', pages: '59'},
        ]
      }
    end
  end

  describe "Combinations of components" do
    it "should handle list of dates followed by list of pages, with no demarcation" do
      parse_and_check 'Ann. Soc. Agric. Puy, XII. 1842-46, 1846, 1848 (wrapper), 248',
        'Ann. Soc. Agric. Puy', 'XII.', '1842-46, 1846, 1848', '(wrapper), 248'
    end
  end

end
