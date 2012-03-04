# coding: UTF-8
require 'spec_helper'

describe 'SherbornGrammar' do
  let(:grammar) do
    Sherpa::Parser.require_grammars
    SherbornGrammar
  end

  describe "Title" do
    it "should handle a phrase in parentheses" do
      grammar.parse 'Reise (Senckenb. Nat. Ges.) Fische', root: :title
    end
    it "should handle a title ending with an unabbreviated word" do
      grammar.parse 'Gen. Sp. Ins. Geer', root: :title
    end
    it "should handle a title ending with an abbreviated word" do
      grammar.parse 'Suppl. Ent. Syst.', root: :title
    end
    it "should handle a title with an accented character" do
      grammar.parse 'Ency. Méth.', root: :title
    end
    it "should handle a title ending in a parenthesized phrase" do
      grammar.parse 'Ency. Méth. (Vers)', root: :title
    end
    it "should not include the volume in the title" do
      -> {grammar.parse 'Ent. Syst. IV.', root: :title}.should raise_error Citrus::ParseError
    end
    it "should not include the volume in the title, even if it doesn't have a period" do
      -> {grammar.parse 'Ent. Syst. IV', root: :title}.should raise_error Citrus::ParseError
    end
    it "should handle a title with a comma" do
      grammar.parse 'Atlas zu Rueppell, Reise', root: :title
    end
    it "should handle an apostrophe" do
      grammar.parse "Aanhang. Cramer's Uitl. Kapellen", root: :title
    end
  end

  describe "Volume" do
    it "should handle a roman number + period" do
      grammar.parse 'I.', root: :volume
    end
    it "should handle a roman number + (issue)" do
      grammar.parse 'I. (1)', root: :volume
    end
    it "should handle a roman number without a period" do
      grammar.parse 'I', root: :volume
    end
    it "should handle a roman number without a period followed by the issue" do
      grammar.parse 'I (—)', root: :volume
    end
    it "should handle any number in the issue" do
      grammar.parse '(43)', root: :issue
    end
    it "should an issue without a volume" do
      grammar.parse '(43)', root: :volume
    end
    it "should handle a placeholder issue" do
      grammar.parse '(-)', root: :issue
    end
    it "should handle an edition" do
      grammar.parse 'ed. 13, I', root: :volume
    end
    it "should handle a parenthesized phrase" do
      grammar.parse "VIII (2) (Ins.)", root: :volume
    end
    describe "Tab." do
      it "should handle a volume with a Tab." do
        grammar.parse 'II. Tab. Hamadryas amphinosa', root: :volume_with_tab
        grammar.parse 'II. Tab. Hamadryas amphinosa', root: :volume
      end
      it "should handle a volume with Tab. and genus name" do
        grammar.parse 'I. Tab. Rusticus', root: :volume_with_tab
        grammar.parse 'I. Tab. Rusticus', root: :volume
      end
      it "should handle a volume with comma before Tab." do
        grammar.parse 'II., Tab. [160]', root: :volume
      end
      it "should handle Tab. genus name" do
        grammar.parse 'Tab. Idia', root: :volume_with_tab
      end
      it "should handle a Tab. species name" do
        grammar.parse 'Tab. Hamadryas amphinosa', root: :volume_with_tab
      end
      it "should handle Tab. by itself" do
        grammar.parse 'Tab.', root: :volume_with_tab
      end
      it "should handle Tab. with bracketed number" do
        grammar.parse 'Tab. [2]', root: :volume_with_tab
      end
      it "should handle Tab. with bracketed hyphen" do
        grammar.parse 'Tab. [—]', root: :volume_with_tab
      end
    end
  end

  describe "Date" do
    it "should handle a year" do
      grammar.parse "1840", root: :year
      grammar.parse "1840", root: :date
    end
    it "should handle an abbreviated month + year" do
      grammar.parse "Oct. 1840", root: :date
    end
    it "should include a range" do
      grammar.parse '1840-46', root: :year_range
      grammar.parse '1840-46', root: :date
    end
    it "should include a bracketed phrase following a year range" do
      grammar.parse "1840-46 [vero proprius 1847]", root: :date
    end
    it "should handle a one-digit end year in a range" do
      grammar.parse "1830-2", root: :year_range
      grammar.parse "1830-2", root: :date
    end
    it "should handle a bracketed date" do
      grammar.parse "[1830-2]", root: :date
    end
    it "should handle x vel y" do
      grammar.parse '1830 vel 1831', root: :year_range
      grammar.parse '1830 vel 1831', root: :date
    end
    it "should handle x & y" do
      grammar.parse '1830 & 1831', root: :year_range
    end
    it "should handle x or y" do
      grammar.parse '1830 or 1831', root: :year_range
      grammar.parse '1830 or 1831', root: :date
    end
    it "should handle a year with open last digit" do
      grammar.parse '184-', root: :year_range
      grammar.parse '184-', root: :date
    end
    it "should handle a year with open last two digits" do
      grammar.parse '18-', root: :year_range
      grammar.parse '18-', root: :date
    end
    it "should handle a bracketed date with query" do
      grammar.parse '[? 1820]', root: :date
    end
    it "should handle a indeterminate date note" do
      grammar.parse 'die indet.', root: :date
    end
    it "should handle a bracketed date followed by note" do
      grammar.parse '[1822-26, teste Scudder]', root: :date
    end
    it "should handle year followed by bracketed year" do
      grammar.parse '1883 [1932]', root: :date
    end
    it "should handle vero proprius" do
      grammar.parse '1840-46 [vero [propius 1847]', root: :date
    end
    it "should handle comma-separated year list" do
      grammar.parse '1842-46, 1846, 1848', root: :date
    end
    it "should handle a rane with another date in parens" do
      grammar.parse '1829-30 (Dec. 1832)', root: :date
    end
    it "should handle this" do
      grammar.parse "c. Ap. 1833", root: :date
    end
  end

  describe "Pages" do
    it "should handle page & page" do
      grammar.parse '2 & 4', root: :pages
    end
    it "should handle a reference to a section of a plate" do
      grammar.parse "Volutes, pl. ii", root: :pages
    end
    it "should handle a reference to another section of a plate" do
      grammar.parse "Turbinellus, pl. iii", root: :pages
    end
    it "should handle an arabic plate number" do
      grammar.parse "Buccins, pl. 1", root: :pages
    end
    it "should handle it when there's no comma after the word" do
      grammar.parse 'Ranelles pl. ii', root: :pages
    end
    it "should handle a plate in parentheses" do
      grammar.parse "(pl. 17)", root: :pages
    end
    it "should handle '(wrapper)'" do
      grammar.parse '(wrapper)', root: :pages
    end
    it "should handle a plate section starting with an abbreviated word with comma" do
      grammar.parse 'Melan., pl. 1', root: :pages
    end
  end

  describe "Multipart citations" do
    it "should handle a multipart without a &" do
      grammar.parse('Proc. Boston Soc. N. H. I (—) 1844, 187 ; Boston Journ. N. H. V (1) 1845, 84').value.should == {citations: [
          {title: 'Proc. Boston Soc. N. H.', volume: 'I (—)', date: '1844', pages: '187'},
          {title: 'Boston Journ. N. H.', volume: 'V (1)', date: '1845', pages: '84'},
        ]}
    end

    describe "With ex" do
      it "should handle a multipart citation with ex" do
        grammar.parse('Classif. Batrach. 1838,—ex Mém. Soc. Sci. Nat. Neuchâtel, II. 1839 [1840], 59').value.should == {
          citations: [
            {title: 'Classif. Batrach.', volume: nil, date: '1838', pages: nil},
            {title: 'Mém. Soc. Sci. Nat. Neuchâtel', volume: 'II.', date: '1839 [1840]', pages: '59'},
          ]
        }
      end
      it "should handle period instead of comma" do
        grammar.parse "Classif. Batrach. 1838.—ex Mém. Soc. Sci. Nat. Neuchâtel, II. 1839 [1840], 34"
      end
      it "handle nothing before dash" do
        grammar.parse 'Classif. Batrach. 1838—ex Mém. Soc. Sci. Nat. Neuchâtel, II. 1839 [1840], 32'
      end
    end
  end

  describe "Roman numerals" do
    it "should understand these" do
      for number in ['III', 'I', 'II', 'IV', 'V']
        grammar.parse number, root: :roman_number
      end
      for number in ['iii', 'i', 'ii', 'iv', 'v']
        grammar.parse number, root: :roman_number
      end
    end
    it "should not use mixed case" do
      -> {grammar.parse "Ic", root: :roman_number}.should raise_error Citrus::ParseError
    end
  end

  describe "Bracketed phrase" do
    it "should be parsed" do
      grammar.parse '[phrase]', root: :bracketed_phrase
    end
  end

  describe "Taxon name" do
    it "should recognize a genus name" do
      grammar.parse 'Atta', root: :taxon_name
    end
    it "should recognize a species name" do
      grammar.parse 'Atta major', root: :taxon_name
    end
  end

end
