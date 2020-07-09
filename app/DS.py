from Crypto.PublicKey import RSA
from Crypto.Signature import PKCS1_v1_5
import Crypto.Hash.SHA256
# import Crypto.Hash.keccak
from Crypto import Random

def keyGen():

	rsa = RSA.generate(1024)
	priKey = rsa.exportKey('PEM')
	pubKey = rsa.publickey().exportKey()

	return pubKey, priKey


def sign(key, plaintext, hash_algorithm=Crypto.Hash.SHA256):
	"""数字签名"""
	signer = PKCS1_v1_5.new(RSA.importKey(key))
	#hash算法必须要pycrypto库里的hash算法，不能直接用系统hashlib库，pycrypto是封装的hashlib
	hash_value = hash_algorithm.new(plaintext)
	return signer.sign(hash_value)


def verify(key, sign, plaintext, hash_algorithm=Crypto.Hash.SHA256):
	"""校验数字签名"""
	hash_value = hash_algorithm.new(plaintext)
	verifier = PKCS1_v1_5.new(RSA.importKey(key))
	return verifier.verify(hash_value, sign)


def signature_test():
	message = 'DS数字签名测试'
	public_key, private_key = keyGen()
	signature = sign(private_key, message.encode(encoding='utf-8'))
	result = verify(public_key, signature, message.encode('utf-8'))
	print(result)

if __name__ == '__main__':
	signature_test()
