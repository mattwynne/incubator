Feature: Finish a Level
  In order to get a new challenge
  As a player
  I want to move up a level when all the tests are passing
  
  Scenario: Finish Level 1
    Given I have started playing level 1
    When I make all the test pass
    Then I should see that the tests for level 2 have been run
    And I should see that some of the tests have failed
  

  
