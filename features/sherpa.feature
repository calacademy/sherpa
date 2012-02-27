Feature: SherPa - the SHERborn PArser
  In order to extract bibliographic information from Sherborn
  So we can match it against his bibliography
  So we can match names against Suzanne's matches against his bibliography
  So we can provide original publication source for names

  Scenario: Parsing a file and saving the result
    Given a file named "sherborn.txt" with:
    """
uid	Status	Filename	Sequence	Page	NameString	NameStringSic	Genus	GenusSic	Subgenus	OrigAuthor	CombAuthor	Citation	Cit1Author	Cit1NameString	Cit1Title	Cit1Volume	Cit1Number	Cit1Date	Cit1Pages	Cit1Status	Cit1Other	Cit2	Cit3	Cit4	varr	publication	leftovers	AfterDash	bid	extra_lines_flag	Iteration	Unicode	AdditionCorrection	TaxonRankID	IsHomonym	RLPComments	Flag
6009	1	SIL34_01_01_0165	36	99	australis	0	Cerambyx	0			J. F. Gmelin	Linn. Syst. Nat., ed. 13, I. 1789, 1849.			Linn. Syst. Nat., ed. 13, I.			1789	1849							Linn Syst Nat				0	12	australis Cerambyx, J. F. Gmelin. Linn. Syst. Nat., ed. 13, I. 1789, 1849.	0	70	0		0
    """
    When I run `sherpa sherborn.txt`
    Then the file "sherborn.parsed.json" should contain the JSON:
    """
    [{
    "citations": [{"title": "Linn. Syst. Nat.", "date": "1789", "volume": "ed. 13, I.", "pages": "1849"}],
    "citation": "Linn. Syst. Nat., ed. 13, I. 1789, 1849.",
    "them": {"title": "Linn. Syst. Nat., ed. 13, I.", "volume":null, "date": "1789", "pages": "1849"}
    }]
    """

  Scenario: Reporting the results
    Given a file named "sherborn.txt" with:
    """
uid	Status	Filename	Sequence	Page	NameString	NameStringSic	Genus	GenusSic	Subgenus	OrigAuthor	CombAuthor	Citation	Cit1Author	Cit1NameString	Cit1Title	Cit1Volume	Cit1Number	Cit1Date	Cit1Pages	Cit1Status	Cit1Other	Cit2	Cit3	Cit4	varr	publication	leftovers	AfterDash	bid	extra_lines_flag	Iteration	Unicode	AdditionCorrection	TaxonRankID	IsHomonym	RLPComments	Flag
****VALID CSV**** 124	1	SIL34_01_01_0067	2	1	abacus	0	Papilio	0			A. J. Retzius	Gen. Sp. Ins. Geer, 1783, 32.			Gen. Sp. Ins. Geer, 1783, 32											Gen Sp Ins Geer				0	12	abacus Papilio. A. J. Retzius, Gen. Sp. Ins. Geer, 1783, 32.	0	70	0		0


****UNPARSEABLE TITLE 124	1	SIL34_01_01_0067	2	1	abacus	0	Papilio	0			A. J. Retzius	****UNPARSEABLE TITLE****, 1783, 32.			Gen. Sp. Ins. Geer, 1783, 32											Gen Sp Ins Geer				0	12	abacus Papilio. A. J. Retzius, Gen. Sp. Ins. Geer, 1783, 32.	0	70	0		0
    """
    When I run `sherpa sherborn.txt`
    Then it should pass with:
    """
    1 (25%) parsed
    """

  Scenario: The file name is not supplied
    When I run `sherpa`
    Then the stdout should contain "parse error: 'file_name' is required"

  Scenario: Producing a report on the comparison
    Given a file named "sherborn.txt" with:
    """
uid	Status	Filename	Sequence	Page	NameString	NameStringSic	Genus	GenusSic	Subgenus	OrigAuthor	CombAuthor	Citation	Cit1Author	Cit1NameString	Cit1Title	Cit1Volume	Cit1Number	Cit1Date	Cit1Pages	Cit1Status	Cit1Other	Cit2	Cit3	Cit4	varr	publication	leftovers	AfterDash	bid	extra_lines_flag	Iteration	Unicode	AdditionCorrection	TaxonRankID	IsHomonym	RLPComments	Flag
6009	1	SIL34_01_01_0165	36	99	australis	0	Cerambyx	0			J. F. Gmelin	Linn. Syst. Nat., ed. 13, I. 1789, 1849.			Linn. Syst. Nat., ed. 13, I.			1789	1849							Linn Syst Nat				0	12	australis Cerambyx, J. F. Gmelin. Linn. Syst. Nat., ed. 13, I. 1789, 1849.	0	70	0		0
    """
    When I run `sherpa sherborn.txt`
    Then a file named "sherborn.comparison.html" should exist
