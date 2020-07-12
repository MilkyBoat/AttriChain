from web3 import Web3, Account
import json
import os
import pickle
import base64
import struct
from time import time
import chainUtil as chain
import DS
from ZeroKnowledge.Zk import Zk
import LibDTBE
from bplib.bp import BpGroup
from bplib.bp import G1Elem
from petlib.pack import encode, decode

# -----------------基本变量-------------------------
# 账户信息
accountType = {}
user_addr = []
attri_addr = []
track_addr = []
track_limit = 3  # 追踪阈值

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
# 合约编译
os.system('truffle complie')
# 全局初始化
zero = Zk()
epk, esk, esvk = LibDTBE.KeyGen(track_limit)
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
# 组装message, 前271字节为私钥，末尾为属性信息，中间用|||分割
message = pubKey[user_addr[0]] + b'|||' + attri_a
cred = DS.sign(priKey[attri_addr[0]], message)

# 用户生成交易
# -------- Sign()
fpk, fsk = DS.keyGen()
t_para = struct.unpack('>i', fpk[27:31])[0]
G = BpGroup()
M_para = G.hashG1(pubKey[user_addr[0]])
C_dtbe = LibDTBE.Encrypt(epk, t=t_para, M=M_para)
coded_C_dtbe = encode(C_dtbe)
sigma_fpk = DS.sign(priKey[user_addr[0]], fpk)
pi = zero.create(pubKey[user_addr[0]] + b'|||' + cred + b'|||' + sigma_fpk)
coded_pi = pickle.dumps(pi)
sigma = DS.sign(fsk, tx + b'|||' + P + b'|||' + coded_pi + b'|||' + coded_C_dtbe + b'|||' + fpk)
Ce = coded_C_dtbe + b'|||' + fpk + b'|||' + sigma + b'|||' + coded_pi
Ce = base64.b64encode(Ce).decode()
# 发送Ce到链上
tx_receipt = chain.SaveStr(contractAddress, Ce)

# 追踪（该过程中出现的变量为避免冲突一律带t_前缀）
# -------- Parse()
t_Ce = chain.ReadStr(contractAddress)
t_Ce = base64.b64decode(t_Ce)
t_Ce_info = t_Ce.split(b'|||')
t_C_dtbe_str = t_Ce_info[0]
t_C_dtbe = decode(t_C_dtbe_str)
t_fpk = t_Ce_info[1]
t_fpk_para = struct.unpack('>i', t_fpk[27:31])[0]
t_sigma = t_Ce_info[2]
t_pi_str = t_Ce_info[3]
t_pi = pickle.loads(t_pi_str)

# -------- Trace()
secrets = zero.getSecret()
verify_result = zero.verifier.verify(secrets, t_pi)
print('verify_result: ', verify_result)
if verify_result is False:
	raise Exception("error when verifying NIZK pi")
for i in range(track_limit):
	vi = LibDTBE.shareDec(epk, priKey[track_addr[i]], t_fpk_para, t_C_dtbe)
	coded_vi = encode(vi.Ci1) + b'|||' + encode(vi.Ci2)
	coded_vi = base64.b64encode(coded_vi).decode()
	chain.setVi(contractAddress, coded_vi, i)

# -------- Collect()
gamma = []
for i in range(track_limit):
	t_coded_vi = chain.getVi(contractAddress, i)
	t_coded_vi = base64.b64decode(t_coded_vi)
	t_cis = t_coded_vi.split( b'|||')
	t_vi = LibDTBE.CLUE(decode(t_cis[0]), decode(t_cis[1]))
	ri = LibDTBE.shareVerify(epk, esvk[i], t_fpk_para, t_vi, t_C_dtbe)
	if ri == 0:
		raise Exception('error in collect, clue is wrong')
	gamma.append(t_vi)
t_upk = LibDTBE.Combine(epk, esvk, t_fpk_para, gamma, t_C_dtbe)

if t_upk == M_para:
	print('attribute verified successfully')
else:
	print('error when verifying attribute')
