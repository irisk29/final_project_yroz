import uuid
from decimal import Decimal
from uuid import uuid5

import botocore
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from flask import Flask
from flask import jsonify
from flask import request
import boto3

# creating of object of flask app
app = Flask(__name__)

# creating dynamodb access
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
consumersTable = dynamodb.Table('ConsumersPaymentStub')
storesTable = dynamodb.Table('StoresPaymentStub')


@app.route('/create_user_e_wallet/<string:userId>', methods=['POST'])
def create_user_e_wallet(userId):
    try:
        e_wallet_token = str(uuid5(uuid.NAMESPACE_URL, userId))
        item = {"userId": userId, "creditCards": {},  "e_wallet": {e_wallet_token: 0}}
        consumersTable.put_item(Item=item, ConditionExpression='attribute_not_exists(userId)')
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
        try:
            cardNumber = data["cardNumber"]
            expiryDate = data["expiryDate"]
            cvv = data["cvv"]
        except KeyError:
            result = {"token": None, "msg": "Bad Arguments Request"}
            return jsonify(result), 400

        # TODO: checks for valid credit data
        credit_card_token = str(uuid5(uuid.NAMESPACE_URL, cardNumber))
        consumersTable.update_item(
            Key={"userId": userId},
            UpdateExpression="SET creditCards.#cardToken = :amount",
            ExpressionAttributeNames={"#cardToken": credit_card_token},
            ExpressionAttributeValues={":amount": 1000} ,  # 1000 Euro credit card balance (AT THE MOMENT!)
            ConditionExpression="attribute_not_exists(creditCards.#cardToken)",
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
        try:
            credit_card_token = data["creditToken"]
        except KeyError:
            result = {"msg": "Bad Arguments Request"}
            return jsonify(result), 400

        consumersTable.update_item(
            Key={"userId": userId},
            UpdateExpression="REMOVE creditCards.#cardToken",
            ExpressionAttributeNames={"#cardToken": credit_card_token},
            ConditionExpression='attribute_exists(creditCards.#cardToken)',
        )
        result = {"msg": "removed user credit card successfully"}
        return jsonify(result), 200
    except botocore.exceptions.ClientError as e:
        result = {"msg": e.response['Error']['Message']}
        return jsonify(result), 403


@app.route('/e_wallet_balance/<string:userId>', methods=['GET'])
def e_wallet_balance(userId):
    try:
        data = request.get_json()
        try:
            e_wallet_token = data["eWalletToken"]
        except KeyError:
            result = {"balance": None, "msg": "Bad Arguments Request"}
            return jsonify(result), 400

        response = consumersTable.query(
            KeyConditionExpression=Key('userId').eq(userId),
            FilterExpression="attribute_exists(e_wallet.#eWalletToken)",
            ExpressionAttributeNames={"#eWalletToken": e_wallet_token},
        )
        if not response['Items']:
            result = {"balance": None, "msg": "invalid user id or e_wallet token"}
            return jsonify(result), 403
        userData = response['Items'][0]
        e_wallet = userData["e_wallet"]
        balance = str(e_wallet[e_wallet_token])
        result = {"balance": balance, "msg": "returned user e_wallet balance successfully"}
        return jsonify(result), 200
    except botocore.exceptions.ClientError as e:
        result = {"balance": None, "msg": e.response['Error']['Message']}
        return jsonify(result), 403


@app.route('/save_store_bank_account/<string:storeId>', methods=['POST'])
def save_store_bank_account(storeId):
    try:
        data = request.get_json()
        try:
            bank_account = data["bankAccount"]
        except KeyError:
            result = {"token": None, "msg": "Bad Arguments Request"}
            return jsonify(result), 400

        bank_account_token = str(uuid5(uuid.NAMESPACE_URL, bank_account))
        item = {"storeId": storeId, "bankAccount": bank_account_token}
        storesTable.put_item(Item=item, ConditionExpression='attribute_not_exists(storeId)')
        result = {"token": bank_account_token, "msg": "save store bank account number successfully"}
        return jsonify(result), 200
    except ClientError as e:
        if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
            result = {"token": None, "msg": "store already has updated bank account number"}
            return jsonify(result), 403
        else:
            result = {"token": None, "msg": e.response['Error']['Message']}
            return jsonify(result), 403


@app.route('/delete_store_bank_account/<string:storeId>', methods=['DELETE'])
def delete_store_bank_account(storeId):
    try:
        data = request.get_json()
        try:
            bank_account_token = data["bankAccountToken"]
        except KeyError:
            result = {"msg": "Bad Arguments Request"}
            return jsonify(result), 400

        storesTable.delete_item(
            Key={"storeId": storeId},
            ConditionExpression="bankAccount = :bankAccountToken",
            ExpressionAttributeValues={":bankAccountToken": bank_account_token},
        )
        result = {"msg": "deleted store's bank account successfully"}
        return jsonify(result), 200
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
            result = {"msg": "invalid bank account token"}
            return jsonify(result), 403
        result = {"msg": e.response['Error']['Message']}
        return jsonify(result), 403


@app.route('/make_payment', methods=['UPDATE'])
def make_payment():
    try:
        data = request.get_json()
        try:
            userId = data["userId"]
            storeId = data["storeId"]
            credit_card_token = data["creditCardToken"]
            credit_amount = data["creditAmount"]
            e_wallet_token = data["eWalletToken"]
            cash_back_amount = data["cashBackAmount"]
            if cash_back_amount < 0 or credit_amount < 0:
                raise KeyError
        except KeyError:
            result = {"msg": "Bad Arguments Request"}
            return jsonify(result), 400

        store_response = storesTable.query(KeyConditionExpression=Key('storeId').eq(storeId))
        if len(store_response['Items']) == 0:
            result = {"msg": "store not has bank account number for payments"}
            return jsonify(result), 403

        consumersTable.update_item(
            Key={"userId": userId},
            UpdateExpression="SET creditCards.#creditCardToken = creditCards.#creditCardToken - :creditAmount,"
                             " e_wallet.#eWalletToken = e_wallet.#eWalletToken - :cashBackAmount",
            ExpressionAttributeNames={"#creditCardToken": credit_card_token, "#eWalletToken": e_wallet_token},
            ExpressionAttributeValues={":creditAmount": Decimal(str(credit_amount)),
                                       ":cashBackAmount": Decimal(str(cash_back_amount))},
            ConditionExpression="creditCards.#creditCardToken >= :creditAmount AND"
                                " e_wallet.#eWalletToken >= :cashBackAmount",
        )

        total_amount = credit_amount + cash_back_amount if cash_back_amount is not None else 0
        cash_back_percentage = 0.1
        consumersTable.update_item(
            Key={"userId": userId},
            UpdateExpression="SET e_wallet.#eWalletToken = e_wallet.#eWalletToken + :cashBackAmount",
            ExpressionAttributeNames={"#eWalletToken": e_wallet_token},
            ExpressionAttributeValues={":cashBackAmount": Decimal(str(total_amount * cash_back_percentage))},
        )

        result = {"msg": "payment made successfully"}
        return jsonify(result), 200

    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] != 'ConditionalCheckFailedException':
            result = {"msg": "user has no enough credit card / cash-back money"}
            return jsonify(result), 403
        result = {"msg": e.response['Error']['Message']}
        return jsonify(result), 403


if __name__ == '__main__':
    # run our web service as thread safe
    app.run(debug=True)
