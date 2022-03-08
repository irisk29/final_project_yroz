import uuid

import botocore
from botocore.exceptions import ClientError
from flask import Flask, render_template
from flask import jsonify
from flask import request
from uuid import uuid5, uuid4
import random
import boto3

# creating of object of flask app
app = Flask(__name__)
# creating dynamodb access
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('PaymentStub')


@app.route('/create_user_e_wallet/<string:userId>', methods=['POST'])
def create_user_e_wallet(userId):
    try:
        e_wallet_token = str(uuid5(uuid.NAMESPACE_URL, userId))
        item = {"userId": userId, "creditCards": [],  "e_wallet": {e_wallet_token: 0}}
        table.put_item(Item=item, ConditionExpression='attribute_not_exists(userId)')
        result = {"token": e_wallet_token, "msg": "created user e_wallet successfully"}
        return jsonify(result), 200
    except ClientError as e:
        if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
            result = {"token": None, "msg": "user e_wallet already exists"}
            return jsonify(result), 403
        else:
            result = {"token": None, "msg": e.response['Error']['Message']}
            return jsonify(result), 403


@app.route('/add_user_credit_card/<string:userId>', methods=['UPDATE'])
def add_user_credit_card(userId):
    try:
        data = request.get_json()
        cardNumber = data["cardNumber"]
        expiryDate = data["expiryDate"]
        cvv = data["cvv"]
        # TODO: checks for valid credit data
        credit_card_token = str(uuid5(uuid.NAMESPACE_URL, cardNumber))
        table.update_item(
            Key={"userId": userId},
            UpdateExpression="SET creditCards = list_append(creditCards, :c_lst)",
            ConditionExpression='not(contains(creditCards, :c))',
            ExpressionAttributeValues={
                ':c_lst': [credit_card_token],
                ':c': credit_card_token,
            }
        )
        result = {"token": credit_card_token, "msg": "added user credit card successfully"}
        return jsonify(result), 200
    except botocore.exceptions.ClientError as e:
        result = {"token": None, "msg": e.response['Error']['Message']}
        return jsonify(result), 403


@app.route('/remove_user_credit_card/<string:userId>', methods=['UPDATE'])
def remove_user_credit_card(userId):
    try:
        data = request.get_json()
        credit_card_token = data["creditToken"]
        table.update_item(
            Key={"userId": userId},
            UpdateExpression="DELETE creditCards :c_lst",
            ConditionExpression='contains(creditCards, :c))',
            ExpressionAttributeValues={
                ':c_lst': [credit_card_token],
                ':c': credit_card_token,
            }
        )
        result = {"msg": "removed user credit card successfully"}
        return jsonify(result), 200
    except botocore.exceptions.ClientError as e:
        result = {"token": None, "msg": e.response['Error']['Message']}
        return jsonify(result), 403


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
