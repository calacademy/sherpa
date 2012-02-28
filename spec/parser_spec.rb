# coding: UTF-8
require 'spec_helper'

describe Sherpa::Parser do
  let(:parser) {Sherpa::Parser}

  describe "Parsing the whole citation" do

    def parse_and_check citation, title, volume, date, pages
      parser.parse(citation).should == {citations: [{
        title: title, date: date, volume: volume, pages: pages
      }]}
    end

    describe "Specific combinations or patterns of data" do
      it "should handle a bracketed year range without a trailing comma followed by a plate section in brackets" do
        parse_and_check "Ill. Indian Zool. I (—) [1830-2] (pl. 17)", 'Ill. Indian Zool.', 'I (—)', '[1830-2]', '(pl. 17)'
      end

      describe "Atlas...Adour" do
        it "should handle one" do
          parse_and_check "Atlas to Conch, foss. tert. Adour, 1840-46 [<em>vero propius</em> 1847] Turbinellus, pl. iii", "Atlas to Conch. foss. tert. Adour", nil, "1840-46 [<em>vero propius</em> 1847]", "Turbinellus, pl. iii"
        end
        it "should put the supplement with the page section, for now" do
          parse_and_check "Atlas to Conch. foss. tert. Adour, 1840-46 [<em>vero propius</em> 1847], Suppl. pl. iii",  "Atlas to Conch. foss. tert. Adour", nil, "1840-46 [<em>vero propius</em> 1847]", "Suppl. pl. iii"
        end
        it "should handle 'foss' without a period" do
          parser.parse "Atlas to Conch. foss, tert. Adour, 1840-46 [<em>vero propius</em> 1847], Turbinelles, pl. ii"
        end
      end

      describe "Ic. hist lepidopt" do
        it "should parse these variants" do
          parse_and_check "Ic. hist, lepidopt. Europe, II (—) 1837, 177", "Ic. hist, lepidopt. Europe", "II (—)", "1837", "177"
          parse_and_check "Ic. hist, lépidopt. Europe, II (—) 1834, 71", "Ic. hist, lépidopt. Europe", "II (—)", "1834", "71"
          parse_and_check "Ic. hist. Lépidopt. Europe, I (—) 1833, 183", "Ic. hist. Lépidopt. Europe", "I (—)", "1833", "183"
        end
      end
    end

    it "should handle this" do
      pending
      parser.parse "Proc. Boston Soc. N. H. I (—) 184-, 129 ; Boston Journ. N. H. IV (3) 1843, 337 & 347"
    end

    describe "Title" do
      it "should handle a title ending with an abbreviated word" do
        parse_and_check 'Suppl. Ent. Syst. 1798, 435', 'Suppl. Ent. Syst.', nil, '1798', '435',
      end
      it "should handle a title ending with an unabbreviated word" do
        parse_and_check 'Gen. Sp. Ins. Geer, 1783, 32.', 'Gen. Sp. Ins. Geer', nil, '1783', '32'
      end
      it "handle an abbreviation that's not a roman number" do
        parse_and_check 'F. Boica, I. 1798, 542', 'F. Boica', 'I.', '1798', '542'
      end
      it "should handle a parenthesized phrase before the volume" do
        parse_and_check 'Nat. Ins. (Käfer) II. 1789, 53', 'Nat. Ins. (Käfer)', 'II.', '1789', '53'
      end
    end

    describe "Series, volume, issue" do
      it "should handle a journal with a volume" do
        parse_and_check 'Danske Atlas, I 1763, 621', 'Danske Atlas', 'I', '1763', '621'
      end
      it "should handle a journal with a volume" do
        parse_and_check 'Mant. I. 1787, 164', 'Mant.', 'I.', '1787', '164'
      end
      it "should handle roman numeral volume numbers" do
        for number in ['III', 'I', 'II', 'IV', 'V']
          parse_and_check "Mant. #{number}. 1787, 164", 'Mant.', number + '.', '1787', '164'
        end
      end
      it "should handle a journal with a volume and a series" do
        parse_and_check 'Uitl. Kapellen, I (8) 1776, 146', 'Uitl. Kapellen', 'I (8)', '1776', '146'
      end
      it "should handle any number in the issue" do
        parse_and_check 'Uitl. Kapellen, I (43) 1776, 146', 'Uitl. Kapellen', 'I (43)', '1776', '146'
      end
      it "should handle an edition" do
        parse_and_check 'Syst. Nat., ed. 13, I. 1789, 1900', 'Syst. Nat.', 'ed. 13, I.', '1789', '1900'
      end
      it "should handle an issue without a volume" do
        parse_and_check 'Ency. Méth. (Vers) (2) 1792, 750', 'Ency. Méth. (Vers)', '(2)', '1792', '750'
      end
      it "should handle a placeholder, when it's just a hyphen" do
        parse_and_check 'Ins. Afr. Amer. (-) 1806, 18', 'Ins. Afr. Amer.', '(-)', '1806', '18'
      end
      it "should handle a placeholder, even when it's UTF-16" do
        parse_and_check 'Ins. Afr. Amer. (—) 1806, 18', 'Ins. Afr. Amer.', '(—)', '1806', '18'
      end

      describe "the various permutations of Tab." do
        it "should handle Tab. Word, Year" do
          parse_and_check 'Exot. Schmett., Tab. Nereis, 1806', 'Exot. Schmett.', 'Tab. Nereis', '1806', nil
        end
        it "should handle Tab. Word" do
          parse_and_check 'Exot. Schmett., Tab. Idia', 'Exot. Schmett.', 'Tab. Idia', nil, nil
        end
        it "should handle 'Tab. Page'" do
          parse_and_check 'Exot. Schmett. II. Tab. [23]', 'Exot. Schmett.', 'II. Tab.', nil, '[23]'
        end
        it "should handle 'Tab. Word word'" do
          parse_and_check 'Exot. Schmett. II. Tab. Hamadryas amphinosa', 'Exot. Schmett.', 'II. Tab. Hamadryas amphinosa', nil, nil
        end
        it "should handle 'Tab.' alone" do
          parse_and_check 'Exot. Schmett. II. Tab.', 'Exot. Schmett.', 'II. Tab.', nil, nil
        end
      end

    end

    describe "Date" do
      it "should handle a year range" do
        parse_and_check 'Ins. Afr. Amér. (—) 1813-20, 168', 'Ins. Afr. Amér.', '(—)', '1813-20', '168'
      end
      it "should handle a missing date" do
        parse_and_check 'Exot. Schmett. II. 1784, 23', 'Exot. Schmett.', 'II.', '1784', '23'
      end
    end

    describe "Multipart citations" do
      it "should handle it when both parts are complete" do
        parser.parse('Danske Atlas, I. 1763, 621 ; & Danischer Atlas, I. 1765, 401.').should == {
          citations: [
            {title: 'Danske Atlas', volume: 'I.', date: '1763', pages: '621'},
            {title: 'Danischer Atlas', volume: 'I.', date: '1765', pages: '401'},
          ]
        }
      end
      it "should handle a multipart without a &" do
        parser.parse('Proc. Boston Soc. N. H. I (—) 1844, 187 ; Boston Journ. N. H. V (1) 1845, 84').should == {
          citations: [
            {title: 'Proc. Boston Soc. N. H.', volume: 'I (—)', date: '1844', pages: '187'},
            {title: 'Boston Journ. N. H.', volume: 'V (1)', date: '1845', pages: '84'},
          ]
        }
      end
    end

  end

  describe "Component rules" do

    describe "Date" do
      it "should include a bracketed phrase following a date in the date" do
        parser.parse "1840-46 [<em>vero propius</em> 1847]", root: :date
      end
      it "should handle a one-digit end year in a range" do
        parser.parse "1830-2", root: :date
      end
      it "should handle a bracketed date" do
        parser.parse "[1830-2]", root: :date
      end
      it "should handle x or y" do
        parser.parse '1830 <em>vel</em> 1831', root: :date
      end
      it "should handle a year with open last digit" do
        pending
        parser.parse '184-', root: :date
      end
    end

    describe "Pages" do
      it "should handle a reference to a section of a plate" do
        parser.parse "Volutes, pl. ii", root: :pages
      end
      it "should handle a reference to another section of a plate" do
        parser.parse "Turbinellus, pl. iii", root: :pages
      end
      it "should handle an arabic plate number" do
        parser.parse "Buccins, pl. 1", root: :pages
      end
      it "should handle a plate in parentheses" do
        parser.parse "(pl. 17)", root: :pages
      end
    end

    describe "Roman numerals" do
      it "should detect roman numbers" do
        parser.parse "II", root: :roman_number
      end
      it "should not use mixed case" do
        -> {parser.parse "Ic", root: :roman_number}.should raise_error Citrus::ParseError
      end
    end

  end

end
