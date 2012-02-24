Feature: SherPa - the SHERborn PArser
  In order to extract bibliographic information from Sherborn
  So we can match it against his bibliography
  So we can match names against Suzanne's matches against his bibliography
  So we can provide original publication source for names

  Scenario: Parsing a file and writing the results
    Given a file named "sherborn.txt" with:
    """
uid	Status	Filename	Sequence	Page	NameString	NameStringSic	Genus	GenusSic	Subgenus	OrigAuthor	CombAuthor	Citation	Cit1Author	Cit1NameString	Cit1Title	Cit1Volume	Cit1Number	Cit1Date	Cit1Pages	Cit1Status	Cit1Other	Cit2	Cit3	Cit4	varr	publication	leftovers	AfterDash	bid	extra_lines_flag	Iteration	Unicode	AdditionCorrection	TaxonRankID	IsHomonym	RLPComments	Flag
124	1	SIL34_01_01_0067	2	1	abacus	0	Papilio	0			A. J. Retzius	Gen. Sp. Ins. Geer, 1783, 32.			Gen. Sp. Ins. Geer, 1783, 32											Gen Sp Ins Geer				0	12	abacus Papilio. A. J. Retzius, Gen. Sp. Ins. Geer, 1783, 32.	0	70	0		0
125	1	SIL34_01_01_0067	3	1	abadonna	0	Sphinx	0			J. C. Fabricius	Suppl. Ent. Syst. 1798, 435			Suppl. Ent. Syst. 1798, 435											Suppl Ent Syst				0	1	abadonna Sphinx, J. C. Fabricius, Suppl. Ent. Syst. 1798, 435.	0	70	0		0
    """
    When I run `sherpa sherborn.txt`
    Then the file "sherborn.json" should contain the JSON:
    """
    [
    {"citations":[{"title":"Gen. Sp. Ins. Geer","date":"1783","series_volume_issue":null,"pages":"32"}],"text":"Gen. Sp. Ins. Geer, 1783, 32."},
    {"citations":[{"title":"Suppl. Ent. Syst.","date":"1798","series_volume_issue":null,"pages":"435"}],"text":"Suppl. Ent. Syst. 1798, 435"}
    ]
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
    4 (100%) valid CSV
    0 (0%) invalid CSV
    2 (50%) no citation
    1 (25%) parsed
    1 (25%) unparsed
    25% success
    """

  Scenario: Running silently
    Given a file named "sherborn.txt" with:
    """
uid	Status	Filename	Sequence	Page	NameString	NameStringSic	Genus	GenusSic	Subgenus	OrigAuthor	CombAuthor	Citation	Cit1Author	Cit1NameString	Cit1Title	Cit1Volume	Cit1Number	Cit1Date	Cit1Pages	Cit1Status	Cit1Other	Cit2	Cit3	Cit4	varr	publication	leftovers	AfterDash	bid	extra_lines_flag	Iteration	Unicode	AdditionCorrection	TaxonRankID	IsHomonym	RLPComments	Flag
125	1	SIL34_01_01_0067	3	1	abadonna	0	Sphinx	0			J. C. Fabricius	Suppl. Ent. Syst. 1798, 435			Suppl. Ent. Syst. 1798, 435											Suppl Ent Syst				0	1	abadonna Sphinx, J. C. Fabricius, Suppl. Ent. Syst. 1798, 435.	0	70	0		0
    """
    When I run `sherpa -q sherborn.txt`
    Then the stdout should contain exactly:
    """
    """

  Scenario: Reporting comparison with Rich's manual parsing
    Given pending
    Given a file named "sherborn.txt" with:
    """
uid	Status	Filename	Sequence	Page	NameString	NameStringSic	Genus	GenusSic	Subgenus	OrigAuthor	CombAuthor	Citation	Cit1Author	Cit1NameString	Cit1Title	Cit1Volume	Cit1Number	Cit1Date	Cit1Pages	Cit1Status	Cit1Other	Cit2	Cit3	Cit4	varr	publication	leftovers	AfterDash	bid	extra_lines_flag	Iteration	Unicode	AdditionCorrection	TaxonRankID	IsHomonym	RLPComments	Flag
124	1	SIL34_01_01_0067	2	1	abacus	0	Papilio	0			A. J. Retzius	Gen. Sp. Ins. Geer, 1783, 32.			Gen. Sp. Ins. Geer, 1783, 32											Gen Sp Ins Geer				0	12	abacus Papilio. A. J. Retzius, Gen. Sp. Ins. Geer, 1783, 32.	0	70	0		0
125	1	SIL34_01_01_0067	3	1	abadonna	0	Sphinx	0			J. C. Fabricius	Suppl. Ent. Syst. 1798, 435			Suppl. Ent. Syst. 1798, 435											Suppl Ent Syst				0	1	abadonna Sphinx, J. C. Fabricius, Suppl. Ent. Syst. 1798, 435.	0	70	0		0
    """
    When I run `sherpa sherborn.txt`
    Then the file "sherborn.json" should contain exactly:
    """
    [
    {"citations":[{"title":"Gen. Sp. Ins. Geer","date":"1783","series_volume_issue":null,"pages":"32"}],"text":"Gen. Sp. Ins. Geer, 1783, 32.","comparison":[{"field":"title", "us":"The right title", "them":"The almost right title"}]},
    {"citations":[{"title":"Suppl. Ent. Syst.","date":"1798","series_volume_issue":null,"pages":"435"}],"text":"Suppl. Ent. Syst. 1798, 435"}
    ]
    """
