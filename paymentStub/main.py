import requests

if __name__ == '__main__':
    url_payment_method = "http://127.0.0.1:5000/make_payment"
    payload_payment_method = {
        "userId": "<string:userId>",
        "storeId": "<string:storeId>",
        "creditCardToken": "ed99d320-1d86-59db-b579-054796b766e2",
        "creditAmount": 30,
        "eWalletToken": "98ea3c23-9379-534d-befc-187bf8d38677",
        "cashBackAmount": 0
    }

    response = requests.request("PATCH", url_payment_method, json=payload_payment_method)
    print(response.text)

    # DART EXAMPLE USAGE OF ADD CREDIT CARD #
    # var url = Uri.parse('https://0cjie5t2fa.execute-api.us-east-1.amazonaws.com/dev/addUserCreditCard');
    # var body = {
    #     "userId": "Sagiv",
    #     "cardNumber": "123456",
    #     "expiryDate": 14,
    #     "cvv": 077,
    # };
    # var response = await http.patch(url, body: json.encode(body));
    # print('Response status: ${response.statusCode}');
    # print('Response body: ${response.body}');

    # DART EXAMPLE USAGE OF GET BALANCE #
    # var body = {
    #     "userId": "Sagiv",
    #     "eWalletToken": "dc362916-d665-528d-8e01-1bd5f04607a0",
    # };
    # var url = Uri.https('0cjie5t2fa.execute-api.us-east-1.amazonaws.com', '/dev/eWalletBalance', body);
    # var response = await http.get(url);
    # print('Response status: ${response.statusCode}');
    # print('Response body: ${response.body}');


