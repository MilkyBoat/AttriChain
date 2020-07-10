from web3 import Web3, Account
import json
import os
import time
import chainUtil as chain
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

# 链接本地区块链并部署合约
contractAddress = chain.DeployContract()
tx = bytes(str(contractAddress), encoding='ascii')

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
Ce = str(Ce)[2:-1]
# 发送Ce到链上
tx_receipt = chain.SaveStr(contractAddress, Ce)

# 追踪（该过程中出现的变量为避免冲突一律带t_前缀）
gamma = []
# -------- Parse()
t_Ce = chain.ReadStr(contractAddress)
t_Ce_info = str(t_Ce).split('|')
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
