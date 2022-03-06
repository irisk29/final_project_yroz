import requests

if __name__ == '__main__':
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json"
    }

    url_payment_method = "http://127.0.0.1:5000/create_payment_method"
    payload_payment_method = {
        "accountId": "33612345678",
        "cardNumber": "1111111",
        "cardDate": "21/1",
    }

    response = requests.request("POST", url_payment_method, json=payload_payment_method, headers=headers)
    print(response.text)

    url_payment = "http://127.0.0.1:5000/make_web_payment"
    payload_payment = {
        "returnUrl": "https://www.yoursite.com/thankyou.php",
        "errorUrl": "https://www.yoursite.com/oops.php",
        "cancelUrl": "https://www.yoursite.com/seeYouNextTime.php",
        "cardId": str(response.json()['cardId']),
        "accountId": "33612345678",
        "totalAmount": "1500",
    }
    response = requests.request("POST", url_payment, json=payload_payment, headers=headers)
    print(response.text)
