# coding: UTF-8
require 'spec_helper'

describe Sherpa::Parser do
  let(:parser) {Sherpa::Parser}
  let(:grammar) do
    parser.require_grammars
    SherbornGrammar
  end

  describe "Exemplars" do
    def parse_and_check citation, title, volume, date, pages
      parser.parse(citation).should == {citations: [{
        title: title, date: date, volume: volume, pages: pages
      }]}
    end

=begin
(Roret's Suite à Buffon), Acalèphes, 1843, 121
Aanhang. Cramer's Uitl. Kapellen, V. 1790, 160
Abh. K. bayer. Ak. Wiss. I. 1829-30 (Dec. 1832), 533
Ann. Soc. Ent. France, I (1) <em>c.</em> Ap. 1832, 72
Classif. Batrach. 1838,—<em>ex</em> Mém. Soc. Sci. Nat. Neuchütel, II. 1839 [1840], 38 & 78
Reise (Senckenb. Nat. Ges.) Fische (—) 1830 <em>vel</em> 1831, 118
H. N. g. et p. Moll., wrapper of livr. 15, 1822
Mon. Limniades N. Amer., wrapper of (3) July 1841 [3]
Nom. Brit. Ins., ed. 2, July 1833, App. ; & Ill. [Brit. Ent. (Mand. V.) Mar. 1835, 426
Proc. Boston Soc. N. H. I (—) 184-, 186 ; Boston [Journ. N. H. V (1) 1845, 64
Revue Entom. I (—) 1833, Descr. d'esp. nouv., no. 11
Tav. sin. Hem. 1850,—<em>ex</em> Mem. Soc. Ital. Sci. XXV (1) 1852, [99
=end

    it "should handle Linnaeus" do
      parse_and_check 'Linn. Syst. Nat., ed. 13, I. 1789, 1849.', 'Linn. Syst. Nat.', 'ed. 13, I.', '1789', '1849'
    end
    it "should handle TITLE VOLUME DATE, PAGE" do
      parse_and_check 'Ent. Syst. IV. 1794, 262', 'Ent. Syst.', 'IV.', '1794', '262'
    end
    it "should handle TITLE VOLUME, DATE" do
      parse_and_check 'Exot. Schmett. II. Tab. [168], 18—', 'Exot. Schmett.', 'II. Tab. [168]', '18—', nil
    end
    it "should handle TITLE, DATE, PAGE (no volume; title does not end in a period)" do
      parse_and_check 'Gen. Sp. Ins. Geer, 1783, 32.', 'Gen. Sp. Ins. Geer', nil, '1783', '32'
    end
    it "should handle TITLE VOLUME (ISSUE) DATE, PAGE" do
      parse_and_check 'Uitl. Kapellen, I. (8) 1776, 146', 'Uitl. Kapellen', 'I. (8)', '1776', '146'
    end
    it "should handle TITLE (ISSUE) DATE, PAGE" do
      parse_and_check 'Ency. Méth. (Vers) (2) 1792, 750', 'Ency. Méth. (Vers)', '(2)', '1792', '750'
    end
    it "should handle TITLE VOLUME" do
      parse_and_check 'Exot. Schmett. II. Tab. [103]', 'Exot. Schmett.', 'II. Tab. [103]', nil, nil
    end
    it "should handle a bracketed year range without a trailing comma followed by a plate section in parentheses" do
      parse_and_check "Ill. Indian Zool. I (—) [1830-2] (pl. 17)", 'Ill. Indian Zool.', 'I (—)', '[1830-2]', '(pl. 17)'
    end
    it "should handle an exotic Schmett" do
      parse_and_check 'Exot. Schmett. II. Tab. Hamadryas amphinosa', 'Exot. Schmett.', 'II. Tab. Hamadryas amphinosa', nil, nil
    end
    it "should handle the Atlas..Adour" do
      parse_and_check 'Atlas to Conch, foss. tert. Adour, 1840-46 [<em>vero propius</em> 1847] Turbinellus, pl. iii.',
        'Atlas to Conch. foss. tert. Adour', nil, '1840-46 [<em>vero propius</em> 1847]', 'Turbinellus, pl. iii'
    end
    it "should handle multipart citations where both parts are complete" do
      parser.parse('Danske Atlas, I. 1763, 621 ; & Danischer Atlas, I. 1765, 401.').should == {
        citations: [
          {title: 'Danske Atlas', volume: 'I.', date: '1763', pages: '621'},
          {title: 'Danischer Atlas', volume: 'I.', date: '1765', pages: '401'},
        ]
      }
    end
  end

  describe "Component rules" do
    describe "Title" do
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
    end

    describe "Volume" do
      it "should handle a roman number + period" do
        grammar.parse 'I.', root: :volume_without_issue
        grammar.parse 'I.', root: :volume
      end
      it "should handle a roman number + (issue)" do
        grammar.parse 'I. (1)', root: :volume_with_issue
        grammar.parse 'I. (1)', root: :volume
      end
      it "should handle a roman number without a period" do
        grammar.parse 'I', root: :volume_without_issue
        grammar.parse 'I', root: :volume
      end
      it "should handle a roman number without a period followed by the issue" do
        grammar.parse 'I (—)', root: :volume_without_period_with_issue
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
        parser.parse "1840", root: :year
        parser.parse "1840", root: :date
      end
      it "should handle an abbreviated month + year" do
        parser.parse "Oct. 1840", root: :date
      end
      it "should include a range" do
        parser.parse '1840-46', root: :year_range
        parser.parse '1840-46', root: :date
      end
      it "should include a bracketed phrase following a year range" do
        parser.parse "1840-46 [<em>vero propius</em> 1847]", root: :date
      end
      it "should handle a one-digit end year in a range" do
        parser.parse "1830-2", root: :year_range
        parser.parse "1830-2", root: :date
      end
      it "should handle a bracketed date" do
        parser.parse "[1830-2]", root: :date
      end
      it "should handle x or y" do
        parser.parse '1830 <em>vel</em> 1831', root: :year_range
        parser.parse '1830 <em>vel</em> 1831', root: :date
      end
      it "should handle a year with open last digit" do
        parser.parse '184-', root: :year_range
        parser.parse '184-', root: :date
      end
      it "should handle a year with open last two digits" do
        parser.parse '18-', root: :year_range
        parser.parse '18-', root: :date
      end
      it "should handle a bracketed date with query" do
        parser.parse '[? 1820]', root: :date
      end
      it "should handle a indeterminate date note" do
        parser.parse '<em>die indet.</em>', root: :date
      end
      it "should handle bracketed date followed by note" do
        parser.parse '[1822-26, <em>teste</em> Scudder]', root: :date
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

    describe "Multipart citations" do
      it "should handle a multipart without a &" do
        parser.parse('Proc. Boston Soc. N. H. I (—) 1844, 187 ; Boston Journ. N. H. V (1) 1845, 84').should == {citations: [
            {title: 'Proc. Boston Soc. N. H.', volume: 'I (—)', date: '1844', pages: '187'},
            {title: 'Boston Journ. N. H.', volume: 'V (1)', date: '1845', pages: '84'},
          ]}
      end
    end

    describe "Roman numerals" do
      it "should understand these" do
        for number in ['III', 'I', 'II', 'IV', 'V']
          parser.parse number, root: :roman_number
        end
        for number in ['iii', 'i', 'ii', 'iv', 'v']
          parser.parse number, root: :roman_number
        end
      end
      it "should not use mixed case" do
        -> {parser.parse "Ic", root: :roman_number}.should raise_error Citrus::ParseError
      end
    end

    describe "Bracketed phrase" do
      it "should be parsed" do
        parser.parse '[phrase]', root: :bracketed_phrase
      end
    end

    describe "Taxon name" do
      it "should recognize a genus name" do
        parser.parse 'Atta', root: :taxon_name
      end
      it "should recognize a species name" do
        parser.parse 'Atta major', root: :taxon_name
      end
    end

  end
end
