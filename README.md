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
```bash
#!/usr/bin/env bash
git clone https://github.com/MilkyBoat/AttriChain.git
cd AttriChain/app
# start up block chain at localhost
ganache-cli -db -l 18446744073709551615 -g 1
# start main python program
python AttriChain.py
```
