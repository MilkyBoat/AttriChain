from web3 import Web3, Account
import json

contracts_path = '../build/contracts/AttriChain.json'


def DeployContract():
    # 连接本地区块链网络
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    # 判断是否连接上
    if w3.isConnected() is False:
	    raise Exception('error in connecting')
    # 加载本地的已经编译的合约文件，将其解码后去除abi部分和bytecode，生成合约对象
    AttriChain_file = open(contracts_path, 'r', encoding='utf-8')
    # 发起一次交易，内容是AttriChain的构造函数，这种交易实质上是对合约的部署，发起者是默认账户，接收者等信息均为空
    AttriChain_json = json.load(AttriChain_file)
    # AttriChain是AttriChain.json通过python转化的一个对象
    AttriChain = w3.eth.contract(abi=AttriChain_json['abi'], bytecode=AttriChain_json['bytecode'])
    # 合约对象将自己部署到区块链上
    tx_hash = AttriChain.constructor().transact({'from': w3.eth.accounts[0]})
    # 查看回执
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contractAddress = tx_receipt.contractAddress
    # 返回合约地址
    return contractAddress


#contractAddress合约地址，inputstr为我要存入链上的值
def SaveStr(contractAddress,inputstr):
    # 连接本地区块链网络
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    # 判断是否连接上
    if w3.isConnected() is False:
	    raise Exception('error in connecting')
    # 获取abi
    AttriChain_file = open(contracts_path, 'r', encoding='utf-8')
    AttriChain_json = json.load(AttriChain_file)
    #web3下的etherum库，通过contract方法，去连接地址为contractAddress的合约，合约的abi是从json对象中提取出的，最终返回调用合约的对象
    contract_instance = w3.eth.contract(address=contractAddress, abi=AttriChain_json['abi'])

    tx_hash = contract_instance.functions.setCe(inputstr).transact({'from': w3.eth.accounts[0]})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    #tx_receipt表示执行结果
    return tx_receipt


def ReadStr(contractAddress):
    # 连接本地区块链网络
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    # 判断是否连接上
    if w3.isConnected() is False:
	    raise Exception('error in connecting')
    # 获取abi
    AttriChain_file = open(contracts_path, 'r', encoding='utf-8')
    AttriChain_json = json.load(AttriChain_file)
    #正确读取，并返回字符串strr
    contract_instance = w3.eth.contract(address=contractAddress, abi=AttriChain_json['abi'])
    #call()表示直接执行
    strr = contract_instance.functions.getCe().call()
    return strr


def setVi(contractAddress, vi, i):
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    if w3.isConnected() is False:
	    raise Exception('error in connecting')
    AttriChain_file = open(contracts_path, 'r', encoding='utf-8')
    AttriChain_json = json.load(AttriChain_file)
    contract_instance = w3.eth.contract(address=contractAddress, abi=AttriChain_json['abi'])

    tx_hash = contract_instance.functions.setVi(vi, i).transact({'from': w3.eth.accounts[0]})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    return tx_receipt


def getVi(contractAddress, i):
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    if w3.isConnected() is False:
	    raise Exception('error in connecting')
    AttriChain_file = open(contracts_path, 'r', encoding='utf-8')
    AttriChain_json = json.load(AttriChain_file)
    contract_instance = w3.eth.contract(address=contractAddress, abi=AttriChain_json['abi'])
    #call()表示直接执行
    vi = contract_instance.functions.getVi(i).call()
    return vi


def test():
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    if w3.isConnected() is False:
	    raise Exception('error in connecting')

    # NIZK test
    test_path = '../build/contracts/test_nizk.json'
    test_json = json.load(open(test_path, 'r', encoding='utf-8'))
    test_nizk = w3.eth.contract(abi=test_json['abi'], bytecode=test_json['bytecode'])
    tx_hash = test_nizk.constructor().transact({'from': w3.eth.accounts[0]})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contractAddress0 = tx_receipt.contractAddress
    contract_instance0 = w3.eth.contract(address=contractAddress0, abi=test_json['abi'])

    contract_instance0.functions.nizk_prove().transact({'from': w3.eth.accounts[0]})
    contract_instance0.functions.nizk_verify().transact({'from': w3.eth.accounts[0]})

    # DTBE test
    test_path = '../build/contracts/test_dtbe.json'
    test_json = json.load(open(test_path, 'r', encoding='utf-8'))
    test_dtbe1 = w3.eth.contract(abi=test_json['abi'], bytecode=test_json['bytecode'])
    tx_hash = test_dtbe1.constructor().transact({'from': w3.eth.accounts[0]})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contractAddress1 = tx_receipt.contractAddress
    contract_instance1 = w3.eth.contract(address=contractAddress1, abi=test_json['abi'])

    test_json = json.load(open('../build/contracts/test_dtbe_main.json', 'r', encoding='utf-8'))
    test_dtbe2 = w3.eth.contract(abi=test_json['abi'], bytecode=test_json['bytecode'])
    tx_hash = test_dtbe2.constructor().transact({'from': w3.eth.accounts[0]})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contractAddress2 = tx_receipt.contractAddress
    contract_instance2 = w3.eth.contract(address=contractAddress2, abi=test_json['abi'])

    # contract_instance1.functions.dtbe_keygen_1().estimateGas()
    contract_instance1.functions.dtbe_keygen_1().transact({'from': w3.eth.accounts[0]})
    contract_instance1.functions.dtbe_keygen_2().transact({'from': w3.eth.accounts[0]})
    contract_instance1.functions.dtbe_keygen_3().transact({'from': w3.eth.accounts[0]})
    contract_instance1.functions.dtbe_keygen_4().transact({'from': w3.eth.accounts[0]})
    contract_instance1.functions.dtbe_keygen_5().transact({'from': w3.eth.accounts[0]})
    contract_instance1.functions.dtbe_keygen_6().transact({'from': w3.eth.accounts[0]})
    for i in range(3):
        contract_instance1.functions.dtbe_keygen_7(i).transact({'from': w3.eth.accounts[0]})
        contract_instance1.functions.dtbe_keygen_8(i).transact({'from': w3.eth.accounts[0]})
    contract_instance1.functions.dtbe_keygen_9().transact({'from': w3.eth.accounts[0]})
    
    contract_instance1.functions.dtbe_encrypt().transact({'from': w3.eth.accounts[0]})

    # contract_instance2.functions.dtbe_shareDec(0).estimateGas()
    for i in range(3):
        contract_instance2.functions.dtbe_shareDec(i).transact({'from': w3.eth.accounts[0]})
    contract_instance2.functions.dtbe_combine().transact({'from': w3.eth.accounts[0]})


if __name__ == "__main__":
    # 以下为第一次执行，为部署合约
    contractAddress = DeployContract()
    print(contractAddress)
    # 修改一个保存的值
    Str0='0'*2000
    SaveStr(contractAddress,bytes(Str0,encoding='ascii'))
    # 读取这个值
    print(ReadStr(contractAddress))
    