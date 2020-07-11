from web3 import Web3, Account
from solc import compile_files, link_code, compile_source
import json
import os
import time
import DS
# import NIZK
# import DTBE

account_list = [
	'0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1',  # 用户，链的初始化者
	'0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0',  # 属性机构
	'0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b',  # 属性机构
	'0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d',  # 追踪机构
	'0xd03ea8624C8C5987235048901fB614fDcA89b117',  # 追踪机构
	'0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC',  # 追踪机构
	'0x3E5e9111Ae8eB78Fe1CC3bb8915d5D461F3Ef9A9',  # 额外的账户，备用
]

user_num = 1
attri_num = 2
track_num = 3

# os.system("truffle migrate --reset")

# 连接本地区块链网络
w3 = Web3(Web3.HTTPProvider("http://localhost:8545"))
# 判断是否连接上
if w3.isConnected() is False:
	raise Exception('error in connecting')

# Contracts = compile_files([
# 	'contracts/ChainInit.sol',
# 	'contracts/nizk/LibNIZK.sol',
# 	'contracts/nizk/LibNizkParam.sol',
# 	'contracts/utillib/LibInt.sol',
# 	'contracts/utillib/LibString.sol',
# 	'contracts/LibDTBE.sol',
# ])

# 加载本地的已经编译的合约文件，将其解码后去除abi部分和bytecode，生成合约对象
ChainInit_file = open('./build/contracts/ChainInit.json', 'r', encoding='utf-8')
ChainInit_json = json.load(ChainInit_file)
ChainInit = w3.eth.contract(abi=ChainInit_json['abi'], bytecode=ChainInit_json['bytecode'])
# 如果交易失败，错误信息显示账户处于未解锁状态，可以解除下面这句话的注释，这将解锁account_list中第一个账户
# w3.parity.personal.unlockAccount(account_list[0], '', '')
# 发起一次交易，内容是ChainInit的构造函数，这种交易实质上是对合约的部署，发起者是默认账户，接收者等信息均为空
tx_hash = ChainInit.constructor().transact({'from': w3.eth.accounts[0]})
# 查看回执，如果没有收到绘制就sleep0.1秒再获取，直到获取到回执再继续
tx_receipt = ''
while not tx_receipt:
	tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
	time.sleep(0.1)

# 再次建立一个合约对象
contract_instance = w3.eth.contract(address=tx_receipt.contractAdress, abi=ChainInit_json['abi'])

# 这里是一个典型的合约函数调用的例子，使用时直接替换helloworld()即可，
# 如果需要交易有接收方，可以在json串中添加信息，后半段将变成：
# .transact({'from': w3.eth.accounts[0], 'to': 接收方地址})
tx_hash = contract_instance.functions.helloWorld().transact({'from': w3.eth.accounts[0]})
# 获取回执以保证这次交易已经完成，当交易使用了加密库的时候可能需要好几秒
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

# 用户初始化
for i in range(user_num):
	pubKey, priKey = DS.keyGen()
	tx_hash = contract_instance.functions.userInit(i, pubKey, priKey).transact({'from': w3.eth.accounts[0]})
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

# 属性机构初始化
for i in range(attri_num):
	pubKey, priKey = DS.keyGen()
	tx_hash = contract_instance.functions.attriInit(i, pubKey, priKey).transact({'from': w3.eth.accounts[0]})
	tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

# TODO: 在后面添加你需要的操作

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
