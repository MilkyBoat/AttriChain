from web3 import Web3, Account
from solc import compile_standard
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


from web3 import Web3, Account
from solc import compile_standard
import json
def test():
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:8545"))
    if w3.isConnected() is False:
	    raise Exception('error in connecting')
    test_path = '../build/contracts/test.json'
    # test_file = open(test_path, 'r', encoding='utf-8')
    # test_json = json.load(test_file)
    test_file = open('../contracts/test.sol', 'r', encoding='utf-8')
    test_file = test_file.read()
    test_json = compile_standard({
        "language": "Solidity",
        "sources": {
            "Greeter.sol": {
                "content": test_file
            }
        },
        "settings":
            {
                "outputSelection": {
                    "*": {
                        "*": [
                            "metadata", 
                            "evm.bytecode",
                            "evm.bytecode.sourceMap"
                        ]
                    }
                }
            }
    })
    test_json = test_file.pop("test.sol:test")
    test = w3.eth.contract(abi=test_json['abi'], bytecode=test_json['bytecode'])
    tx_hash = test.constructor().transact({'from': w3.eth.accounts[0]})
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contractAddress = tx_receipt.contractAddress
    contract_instance = w3.eth.contract(address=contractAddress, abi=test_json['abi'])
    # functions
    # contract_instance.functions.nizk_setup().transact({'from': w3.eth.accounts[0]})
    # contract_instance.functions.nizk_add().transact({'from': w3.eth.accounts[0]})
    # contract_instance.functions.nizk_sub().transact({'from': w3.eth.accounts[0]})

    contract_instance.functions.nizk_prove().transact({'from': w3.eth.accounts[0]})
    contract_instance.functions.nizk_verify().transact({'from': w3.eth.accounts[0]})

    # contract_instance.functions.dtbe_keygen().transact({'from': w3.eth.accounts[0]})


if __name__ == "__main__":
    # 以下为第一次执行，为部署合约
    contractAddress = DeployContract()
    print(contractAddress)
    
    # 以下为第二次执行，先设置刚才获取的合约地址，然后可以读写
    # contractAddress = '0xbc9EaAA3A9CBf3edfc703a319Ca61F87146D044f'
    # 修改一个保存的值
    Str0='0'*2000
    SaveStr(contractAddress,bytes(Str0,encoding='ascii'))
    # 读取这个值
    print(ReadStr(contractAddress))
    