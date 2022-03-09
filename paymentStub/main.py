import requests

if __name__ == '__main__':
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json"
    }

    url_payment_method = "http://127.0.0.1:5000/make_payment"
    payload_payment_method = {
        "userId": "<string:userId>",
        "storeId": "<string:storeId>",
        "creditCardToken": "ed99d320-1d86-59db-b579-054796b766e2",
        "creditAmount": 30,
        "eWalletToken": "98ea3c23-9379-534d-befc-187bf8d38677",
        "cashBackAmount": 20
    }

    response = requests.request("UPDATE", url_payment_method, json=payload_payment_method, headers=headers)
    print(response.text)
