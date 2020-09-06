*** Settings ***
Documentation     A test suite with a single test for valid login.
...
...               NN Test Cases.
Resource          ../keywords/keywords.robot

Test Teardown       Restore Database

*** Test Cases ***
Scenario: Retrive all payments
    [Template]  Retrive all payments
    # username        # password
    admin             admin
    john              john
    unknown           unknown


*** Keywords ***
Retrive all payments
    [Arguments]     ${user}    ${passwd}
    When i request to retrive the payments as    ${user}  ${passwd}
    Then the payments should be retrived

