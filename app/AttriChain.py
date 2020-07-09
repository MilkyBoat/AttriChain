from web3 import Web3, Account
from solc import compile_files, link_code, compile_source
import json
import os
import time
import DS
from ZeroKnowledge.Zk import Zk
import DTBE

# -----------------基本变量-------------------------
# 账户信息
accountType = {}
user_addr = []
attri_addr = []
track_addr = []

user_addr.append(0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1)
attri_addr.append(0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0)
attri_addr.append(0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b)
track_addr.append(0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d)
track_addr.append(0xd03ea8624C8C5987235048901fB614fDcA89b117)
track_addr.append(0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC)

for ac in user_addr:
	accountType[ac] = 'user'
for ac in attri_addr:
	accountType[ac] = 'attri'
for ac in track_addr:
	accountType[ac] = 'track'

# 密钥信息
# crs = ''
epk = ''
esk = []
esvk = []
pubKey = {}
priKey = {}
P = b'a1'

# --------------链信息初始化--------------------
# 全局初始化
zero = Zk()
# crs = NIZK.setup()
epk, esk, esvk = DTBE.KeyGen()
#用户初始化
for i in range(len(user_addr)):
	pubK, priK = DS.keyGen()
	pubKey[user_addr[i]] = pubK
	priKey[user_addr[i]] = priK
#属性机构初始化
for i in range(len(attri_addr)):
	pubK, priK = DS.keyGen()
	pubKey[attri_addr[i]] = pubK
	priKey[attri_addr[i]] = priK
#追踪机构初始化
for i in range(len(track_addr)):
	priKey[track_addr[i]] = esk[i]

# 连接本地区块链网络
w3 = Web3(Web3.HTTPProvider("http://localhost:8545"))
# 判断是否连接上
if w3.isConnected() is False:
	raise Exception('error in connecting')

# 加载本地的已经编译的合约文件，将其解码后取出abi部分和bytecode，生成合约对象
AttriChain_file = open('./build/contracts/ChainInit.json', 'r', encoding='utf-8')
AttriChain_json = json.load(AttriChain_file)
AttriChain = w3.eth.contract(abi=AttriChain_json['abi'], bytecode=AttriChain_json['bytecode'])
tx_hash = AttriChain.constructor().transact({'from': w3.eth.accounts[0]})
tx_receipt = None
while not tx_receipt:
	tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
	time.sleep(0.1)
AttriChain_instance = w3.eth.contract(address=tx_receipt.contractAdress, abi=AttriChain_json['abi'])
tx = bytes(str(tx_receipt.contractAdress), encoding='ascii')

# --------------属性发布与追踪--------------------
# 用户0请求认证a属性
# -------- request
uid = 0
attri_a = b'a1'

# 返回属性证书cred
# -------- Authentication()
# 组装message, 前271字符为私钥，末尾为属性信息，中间用|分割
message = pubKey[user_addr[0]] + b'|' + attri_a
cred = DS.sign(priKey[attri_addr[0]], message)

# 用户生成交易
# -------- Sign()
fpk, fsk = DS.keyGen()
C_ttbe = DTBE.encrypt(epk, t=fpk, m=pubKey[user_addr[0]])
sigma_fpk = DS.sign(priKey[user_addr[0]], fpk)
pi = zero.create(pubKey[user_addr[0]] + b'|' + cred + b'|' + sigma_fpk)
coded_pi = ''
for tur in pi:
	coded_pi += str(tur[0]) + '_' + str(tur[1]) + ','
coded_pi = bytes(coded_pi[:-1], encoding='ascii')
sigma = DS.sign(fsk, tx + b'|' + P + b'|' + coded_pi + b'|' + C_ttbe + b'|' + fpk)
Ce = C_ttbe + b'|' + fpk + b'|' + sigma + b'|' + coded_pi
# Ce = str(Ce)[2:-1] # 如果bytes类型数据不能作为参数传入，则使用str类型，但是可能因为编码问题出事，尽量不用
# 发送Ce到链上
tx_hash = AttriChain_instance.functions.setCe(Ce).transact({'from': w3.eth.accounts[0]})
tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

# 追踪（该过程中出现的变量为避免冲突一律带t_前缀）
gamma = []
# -------- Parse()
t_Ce = AttriChain_instance.functions.getCe().call()
# t_Ce = t_Ce[2:-1] # 如果字符串还带着b前缀，用这个去掉
t_Ce_info = str(t_Ce).split(b'|')
t_C_ttbe = t_Ce_info[0]
t_fpk = t_Ce_info[1]
t_sigma = t_Ce_info[2]
t_pi_str = t_Ce_info[3]
t_pi = t_pi_str.split(',')
for i in range(len(t_pi)):
	t_sp = t_pi[i].split('_')
	t_pi[i] = (int(t_sp[0]), int(t_sp[1]))

# -------- Trace()
secrets = zero.getSecret()
verify_result = zero.verifier.verify(secrets, t_pi)
if verify_result is False:
	raise Exception("error when verifying NIZK pi")
for i in range(track_addr):
	vi = DTBE.shareDec(epk, priKey[track_addr[i]], fpk, C_ttbe)
	gamma.append(vi)

# -------- Collect()
for i in range(track_addr):
	ri = DTBE.shareVerify(epk, esvk[i], fpk, gamma[i], C_ttbe)
	if ri == 0:
		raise Exception('error in collect, clue is wrong')
t_upk = DTBE.combine(epk, esvk, fpk, gamma, C_ttbe)

if t_upk == pubKey[user_addr[0]]:
	print('attribute verified successfully')
else:
	print('error when verifying attribute')
