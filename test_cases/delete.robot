*** Settings ***
Documentation     A test suite with a single test for valid login.
...
...               NN Test Cases.
Resource          ../keywords/keywords.robot

Test Teardown       Restore Database

*** Test Cases ***
#This test creates 2 payments.  Since in the start of app we already have 1 payment, in total in the middle of the test it will have 3 payments. Then the
#test delete the 2nd payment. Then it verifies that payment with id 2 it is deleted as expected
Delete specific payment as admin
    Given i have payments
    When i request to delete a payment as  admin   admin
    Then the payment should be deleted


Delete payment as user
    Given i have payments   john
    When i request to delete a payment as  john   john
    Then the payment should be deleted

#Negative Test
Delete payment that was not created by user
    Given i have payments   admin
    When i request to delete a payment as  john   john
    Then the payment should not be deleted
