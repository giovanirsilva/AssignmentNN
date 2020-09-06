*** Settings ***
Library               Collections
Library               RequestsLibrary
Library               RequestsChecker
Library               json
Library               requests
Library               Process


*** Variables ***
${url}=   http://localhost:5000/finance/api/v1.0/payments
&{headers}=   content-type=application/json   accept=application/json

${purchase}=    1
${amount}=      949.0
${currency}=    GBP

${purchase_usd}=    5
${amount_usd}=      1542.0
${currency_usd}=    USD


${dbname}=   payments
${dbuser}=   none
${dbpasswd}=     none
${dbhost}=   C:\Users\User\Desktop\assignment\assignment
${dbport}=   5000
@{queryResults}


*** Keywords ***

i request to retrive the payments as
    [Arguments]     ${user}     ${passwd}
    ${false}=    Convert To Boolean    False
    ${user_pass}=   Evaluate   ("${user}", "${passwd}",)
    ${resp}=    Get   ${url}    auth=${user_pass}        headers=${headers}
    Set Global Variable     ${resp}
    Set Global Variable     ${user}

the payments should be retrived
    log to console       \nGet Json Response:\n${resp.json()}
    Run keyword if     '${user}'=='admin'       Should be true      '${resp.status_code}'=='200'
    Run keyword if     '${user}'=='john'        Should be true      '${resp.status_code}'=='200'
    Run keyword if     '${user}'=='unknown'     Should be true      '${resp.status_code}'=='403'



i request to create a payment
    [Arguments]     ${user}     ${passwd}   ${purchase}=${purchase}     ${amount}=${amount}     ${currency}=${currency}
    ${req_dict}    Create Dictionary    purchase=${purchase}    amount=${amount}    currency=${currency}
    ${req_json}    Json.Dumps    ${req_dict}

    ${false}=    Convert To Boolean    False
    ${user_pass}=   Evaluate   ("${user}", "${passwd}",)
    log to console      Json: ${req_json}
    ${resp_put}=    Put        ${url}   data=${req_json}      auth=${user_pass}        headers=${headers}
    Set Global Variable     ${resp_put}
    Set Global Variable     ${user}
    Set Global variable     ${req_json}


the payment should be created
    log to console       \nGet Json Response:\n${resp_put.json()}

    ${resp_put_dict}=  evaluate  json.dumps(${resp_put.json()})    json
    ${data_put}=  evaluate    json.loads('''${resp_put_dict}''')    json


    Run keyword if     '${user}'=='admin'       Should be true      '${resp_put.status_code}'=='200'
    Run keyword if     '${user}'=='admin'       Should be true      ${data_put["created"]}==1
    Run keyword if     '${user}'=='john'        Should be true      '${resp_put.status_code}'=='200'
    Run keyword if     '${user}'=='john'       Should be true       ${data_put["created"]}==1
    Run keyword if     '${user}'=='unknown'     Should be true      '${resp_put.status_code}'=='403'

    i request to retrive the payments as  admin    admin


i request to create a payment with invalid currency
    [Arguments]     ${user}     ${passwd}
    ${req_dict}    Create Dictionary    purchase=${purchase}    amount=${amount}    currency='INVAL'
    ${req_json}    Json.Dumps    ${req_dict}

    ${false}=    Convert To Boolean    False
    ${user_pass}=   Evaluate   ("${user}", "${passwd}",)
    log to console      Json: ${req_json}
    ${resp_put}=    Put        ${url}   data=${req_json}      auth=${user_pass}        headers=${headers}
    Set Global Variable     ${resp_put}
    Set Global Variable     ${user}
    Set Global variable     ${req_json}


the payment should not be created
    log to console       \nGet Json Response:\n${resp_put.json()}

    Should be true      '${resp_put.status_code}'=='400'


i have payments
    [Arguments]     ${user}=admin
    i request to create a payment   ${user}   ${user}
    i request to create a payment   ${user}   ${user}   ${purchase_usd}   ${amount_usd}    ${currency_usd}
    Should be true      '${resp_put.status_code}'=='200'

i request to process all payments
    ${user_pass}=   Evaluate   ("admin", "admin",)
    log to console      Json: ${req_json}
    ${resp_post}=    Post        ${url}   data=${req_json}      auth=${user_pass}        headers=${headers}
    Set Global Variable     ${resp_post}


all the payments should be processed

    ${resp_post_dict}=  evaluate  json.dumps(${resp_post.json()})    json
    ${data_post}=  evaluate    json.loads('''${resp_post_dict}''')    json

    Run keyword if     '${user}'=='admin'       Should be true      '${resp_post.status_code}'=='200'
    Run keyword if     '${user}'=='admin'       Should be true      ${data_post["processed"]}==2

    i request to retrive the payments as    admin   admin
        log to console      Jsonnn: ${resp.json()}
        ${resp_dict}=  evaluate  json.dumps(${resp.json()})    json
            ${data}=  evaluate    json.loads('''${resp_dict}''')    json

        ${lenght}=  get length  ${data["payments"]}
        FOR    ${loop}    IN RANGE   0      ${lenght}
        Should Be Equal    ${data["payments"][${loop}][4]}    EUR
        END

       ${resultgbp}=    Evaluate    ${amount} * 0.89
       ${resultusd}=    Evaluate    ${amount_usd} * 0.84


        Should Be True    '${data["payments"][${1}][3]}'=='${resultgbp}'
        Should Be True    '${data["payments"][${2}][3]}'=='${resultusd}'






i request to delete a payment as
    [Arguments]     ${user}     ${passwd}
    ${user_pass}=   Evaluate   ("${user}", "${passwd}",)
    log to console      Json: ${req_json}
    ${resp_delete}=    Delete       ${url}/2   auth=${user_pass}        headers=${headers}
    #Check deleted 1
    Set Global Variable     ${resp_delete}


the payment should be deleted
    i request to retrive the payments as    admin   admin
        ${resp_dict}=  evaluate  json.dumps(${resp.json()})    json
            ${data}=  evaluate    json.loads('''${resp_dict}''')    json

        Should not be true    ${data["payments"][1][0]}==2

the payment should not be deleted
    i request to retrive the payments as    admin   admin
        ${resp_dict}=  evaluate  json.dumps(${resp.json()})    json
            ${data}=  evaluate    json.loads('''${resp_dict}''')    json

        Should be true    ${data["payments"][1][0]}==2



i request to process all payments as user
    ${user_pass}=   Evaluate   ("john", "john",)
    log to console      Json: ${req_json}
    ${resp_post}=    Post        ${url}   data=${req_json}      auth=${user_pass}        headers=${headers}
    Set Global Variable     ${resp_post}


all the payments should not be processed
    #Check processed is equal of number of expected
    i request to retrive the payments as    admin   admin
        log to console      Jsonnn: ${resp.json()}
        ${resp_dict}=  evaluate  json.dumps(${resp.json()})    json
            ${data}=  evaluate    json.loads('''${resp_dict}''')    json

        ${lenght}=  get length  ${data["payments"]}
        FOR    ${loop}    IN RANGE   0      ${lenght}
        Should Not Be Equal    ${data["payments"][${loop}][4]}    EUR
        #Check convertion was correct done
        END



Restore Database
    i request to retrive the payments as    admin   admin
        log to console      Jsonnn: ${resp.json()}
        ${resp_dict}=  evaluate  json.dumps(${resp.json()})    json
            ${data}=  evaluate    json.loads('''${resp_dict}''')    json

        ${lenght}=  get length  ${data["payments"]}
        @{L1}=    Create List
        FOR    ${loop}    IN RANGE   0      ${lenght}

        append to list   ${L1}      ${data["payments"][${loop}][0]}
        END

        Log Many   List:  @{L1}

        ${user_pass}=   Evaluate   ("admin", "admin",)
        ${lenght_list}=   get length  ${L1}
        FOR     ${loop_list}     IN RANGE   1    ${lenght_list}
        ${resp_delete}=    Delete       ${url}/${L1}[${loop_list}]   auth=${user_pass}        headers=${headers}
        END


