*** Settings ***
Documentation     A test suite with a single test for valid login.
...
...               NN Test Cases.
Resource          ../keywords/keywords.robot

Test Teardown       Restore Database

*** Test Cases ***
Process all payments
    Given i have payments
    When i request to process all payments
    Then all the payments should be processed

#Negative *** Test Cases ***
Process all payments as user
    Given i have payments
    When i request to process all payments as user
    Then all the payments should not be processed