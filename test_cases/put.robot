*** Settings ***
Documentation     A test suite with a single test for valid login.
...
...               NN Test Cases.
Resource          ../keywords/keywords.robot

Test Teardown       Restore Database

*** Test Cases ***
Scenario: Create payment as different users
    [Template]  Create payment as different users
    # username        # password
    admin             admin
    john              john
    unknown           unknown

##Negative Test
Create payment with currency invalid
    When i request to create a payment with invalid currency    admin   admin
    Then the payment should not be created


*** Keywords ***
Create payment as different users
    [Arguments]     ${user}    ${passwd}
    When i request to create a payment    ${user}  ${passwd}
    Then the payment should be created




