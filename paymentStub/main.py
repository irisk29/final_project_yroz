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

    # DART EXAMPLE USAGE #
    # var url = Uri.parse('http://10.0.2.2:5000/make_payment');
    # var body = {
    #     "userId": "<string:userId>",
    #     "storeId": "<string:storeId>",
    #     "creditCardToken": "ed99d320-1d86-59db-b579-054796b766e2",
    #     "creditAmount": 30,
    #     "eWalletToken": "98ea3c23-9379-534d-befc-187bf8d38677",
    #     "cashBackAmount": 0
    # };
    # var response = await http.patch(url, body: json.encode(body));
    # print('Response status: ${response.statusCode}');
    # print('Response body: ${response.body}');
