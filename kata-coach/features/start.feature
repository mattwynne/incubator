Feature: Start
  In order to play
  As a player
  I want start

  Scenario: Start the game
    Given I have a brand new kata
    When I start
    Then I should see that the tests for level 1 have been run
    And I should see that all of the tests have failed
    And I should see how much time is left

  
