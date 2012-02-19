Feature: SherPa - the SHErborn PArser
  In order to extract bibliographic information from Sherborn
  So we can match it against his bibliography
  So we can match names against Suzanne's matches against his bibliography
  So we can provide original publication source for names

  Scenario: Getting help
    When I get help for "sherpa"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes options
    And the following options should be documented:
      |--version|
    And the banner should document that this app takes no arguments
