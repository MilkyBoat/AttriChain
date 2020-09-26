# AttriChain
> The implement of paper: "AttriChain: Decentralized Traceable Anonymous Identities in Privacy-Preserving Permissioned Blockchain"

[中文文档](README.cn.md)

## requirements
#### tools
* nodejs
* truffle >=4.1.8 <5
* python3
* ganache-cli
* openssl

#### python libs (aviliable at pypi if no link was attached)
* web3
* Crypto
* [ZeroKnowledge](https://github.com/anudit/zkpython)(no need to install, this lib has attached in code)
* petlib
* bplib

## how to run

#### offline version

In this version, BlockChain was still used. All calculations will be done on the local computer using Python, the BlockChain(Implemented with Truffle framework based on Ethereum) will storage the credentials that need to be exposed.

```bash
#!/usr/bin/env bash
git clone https://github.com/MilkyBoat/AttriChain.git
cd AttriChain/app
# start up block chain at localhost
ganache-cli -db -l 18446744073709551615 -g 1
# start main python program
python AttriChain_offline.py
```

this code will compile the smart contracts and init the BolckChain to a AttriChain, use one account as user, two as Attribution Inst., three as Track Inst.. Then, user with uid=0 require to authenticate a attribute string "al". Attri Inst. sign it, then storage recept to the chain. Finally, someone wants to confirm the attribution, the trace Inst. verify the cred and return clues, if the clues are right, then attribute verified successfully.

#### online version





