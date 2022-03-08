import requests

if __name__ == '__main__':
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json"
    }

    url_payment_method = "http://127.0.0.1:5000/add_user_credit_card/<string:userId>"
    payload_payment_method = {
        "cardNumber": "33612345678",
        "expiryDate": "11/11/24",
        "cvv": "088",
    }

    response = requests.request("UPDATE", url_payment_method, json=payload_payment_method, headers=headers)
    print(response.text)

    # url_payment = "http://127.0.0.1:5000/make_web_payment"
    # payload_payment = {
    #     "returnUrl": "https://www.yoursite.com/thankyou.php",
    #     "errorUrl": "https://www.yoursite.com/oops.php",
    #     "cancelUrl": "https://www.yoursite.com/seeYouNextTime.php",
    #     "cardId": str(response.json()['cardId']),
    #     "accountId": "33612345678",
    #     "totalAmount": "1500",
    # }
    # response = requests.request("POST", url_payment, json=payload_payment, headers=headers)
    # print(response.text)
