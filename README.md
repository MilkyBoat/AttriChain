# AttriChain
[中文文档](README.cn.md)

## requirements
#### tools
* nodejs
* truffle >=4.1.8 <5
* python3
* ganache-cli

#### python libs (aviliable at pypi if no link was attached)
* web3
* Crypto
* [ZeroKnowledge](https://github.com/anudit/zkpython)(no need to install, this lib has attached in code)

## how to run
```bash
#!/usr/bin/env bash
git clone https://github.com/MilkyBoat/AttriChain.git
cd AttriChain
# complie the block chain smart contract
truffle complie;
# start up block chain at localhost
ganache-cli;
# start main python program
python ./app/AttriChain.py
```
