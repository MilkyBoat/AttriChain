from web3 import Web3, Account
from solc import compile_files, link_code, compile_source
import json
import os
import time
import chainUtil as chain
import DS

account_list = [
	'0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1',  # user, initializer
	'0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0',  # attribute ins.
	'0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b',  # attribute ins.
	'0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d',  # track ins.
	'0xd03ea8624C8C5987235048901fB614fDcA89b117',  # track ins.
	'0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC',  # track ins.
	'0x3E5e9111Ae8eB78Fe1CC3bb8915d5D461F3Ef9A9',  # extra, backup account
]

user_num = 1
attri_num = 2
track_num = 3

# use truffle to complie all the smart contracts
# os.system("truffle complie")

# Connect to blockchain in localhost:8545, the default port of truffle
w3 = Web3(Web3.HTTPProvider("http://localhost:8545"))
if w3.isConnected() is False:
	raise Exception('error in connecting')

AttriChain_file = open('./build/contracts/AttriChain.json', 'r', encoding='utf-8')
AttriChain_json = json.load(AttriChain_file)
AttriChain = w3.eth.contract(abi=AttriChain_json['abi'], bytecode=AttriChain_json['bytecode'])
# w3.parity.personal.unlockAccount(account_list[0], '', '')
tx_hash = AttriChain.constructor().transact({'from': w3.eth.accounts[0]})
tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
AttriChain = w3.eth.contract(address=tx_receipt.contractAdress, abi=AttriChain_json['abi'])

# ------------------ chain init --------------------
upk, usk = [], []
apk, ask = [], []
epk, esk, esvk = 0, [], []

# user init
for i in range(user_num):
	_upk, _usk = DS.keyGen()
	upk.append(_upk)
	usk.append(_usk)

# attri ins. init
for i in range(attri_num):
	_apk, _ask = DS.keyGen()
	apk.append(_apk)
	ask.append(_ask)

# -------------------- request ------------------------
uid = 0
attri_a = b'a1'  # attribution

# ----------------- Authentication ---------------------
# Assemble message,
# the first 271 byte is the public key,
# then is the attribute information, they divided by '|||'
message = upk[0] + b'|||' + attri_a
cred = DS.sign(ask[0], message)


# TODO: 

# test_file = open('../build/contracts/test.json', 'r', encoding='utf-8')
# test_json = json.load(test_file)
# test = w3.eth.contract(abi=test_json['abi'], bytecode=test_json['bytecode'])

# tx_hash = test.constructor().transact({'from': w3.eth.accounts[0]})
# tx_receipt = ''
# while not tx_receipt:
# 	tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
# 	time.sleep(0.1)

# tx_hash = contract_instance.functions.request(0, 0).transact({'from': w3.eth.accounts[0]})
# tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
