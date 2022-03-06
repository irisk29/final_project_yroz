from flask import Flask, render_template
from flask import jsonify
from flask import request
from uuid import uuid4
import random

# creating of object of flask app
app = Flask(__name__)


# registering handler for handling exceptions
# once we get bad get request, we will present html page we created in /templates/exception.html
@app.errorhandler(Exception)
def handle_exception(e):
    return render_template('exception.html', error=e)


@app.route('/make_web_payment', methods=['POST'])
def make_web_payment():
    payload = request.json
    returnUrl = payload["returnUrl"]
    errorUrl = payload["errorUrl"]
    cancelUrl = payload["cancelUrl"]
    accountId = payload["accountId"]
    cardId = payload["cardId"]
    totalAmount = payload["totalAmount"]

    print("web payment request - charge " + cardId +
          " and credit account " + accountId + " for the amount " + totalAmount)
    if int(totalAmount) <= 0:
        return render_template('exception.html', error="total amount must be positive"), 401
    if cardId == str(100):
        return render_template('exception.html', error="special sign"), 401

    rand_token = uuid4()
    res = {"token": rand_token}
    return jsonify(res), 200


@app.route('/make_digital_payment', methods=['POST'])
def make_digital_payment():
    payload = request.json
    walletId = payload["walletId"]
    accountId = payload["accountId"]
    totalAmount = payload["totalAmount"]

    print("digital payment request - charge wallet " + walletId +
          " and credit account " + accountId + " for the amount " + totalAmount)
    if int(totalAmount) <= 0:
        return render_template('exception.html', error="total amount must be positive"), 401
    if walletId == str(100):
        return render_template('exception.html', error="special sign"), 401

    rand_token = uuid4()
    res = {"token": rand_token}
    return jsonify(res)


@app.route('/create_wallet', methods=['POST'])
def create_wallet():
    payload = request.json
    walletId = payload["walletId"]
    clientMail = payload["clientMail"]

    print("create wallet request - wallet id " + walletId + " to client " + clientMail)
    if walletId == str(100):
        return render_template('exception.html', error="special sign"), 401

    res = {"walletId": walletId}
    return jsonify(res)


@app.route('/create_payment_method', methods=['POST'])
def create_payment_method():
    payload = request.json
    accountId = payload["accountId"]
    cardNumber = payload["cardNumber"]
    cardDate = payload["cardDate"]

    print("create payment method request - account id "
          + accountId + " card number " + cardNumber + " cardDate " + cardDate)
    if accountId == str(100):
        return render_template('exception.html', error="special sign"), 401

    res = {"cardId": random.randint(1, 256)}
    return jsonify(res)


if __name__ == '__main__':
    # run our web service as thread safe
    app.run(debug=True)
