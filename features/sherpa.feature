Feature: SherPa - the SHERborn PArser
  In order to extract bibliographic information from Sherborn
  So we can match it against his bibliography
  So we can match names against Suzanne's matches against his bibliography
  So we can provide original publication source for names

  Scenario: Parsing a file
    Given a file named "sherborn.txt" with:
    """
124	1	SIL34_01_01_0067	2	1	abacus	0	Papilio	0			A. J. Retzius	Gen. Sp. Ins. Geer, 1783, 32.			Gen. Sp. Ins. Geer, 1783, 32											Gen Sp Ins Geer				0	12	abacus Papilio. A. J. Retzius, Gen. Sp. Ins. Geer, 1783, 32.	0	70	0		0
125	1	SIL34_01_01_0067	3	1	abadonna	0	Sphinx	0			J. C. Fabricius	Suppl. Ent. Syst. 1798, 435			Suppl. Ent. Syst. 1798, 435											Suppl Ent Syst				0	1	abadonna Sphinx, J. C. Fabricius, Suppl. Ent. Syst. 1798, 435.	0	70	0		0
    """
    When I run `sherpa sherborn.txt`
    Then it should emit the JSON:
    """
    [
      {"title": "Gen. Sp. Ins. Geer", "year": "1783", "pages": "32", "text": "Gen. Sp. Ins. Geer, 1783, 32."},
      {"title": "Suppl. Ent. Syst.", "year": "1798", "pages": "435", "text": "Suppl. Ent. Syst. 1798, 435"}
    ]
    """
