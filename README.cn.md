# AttriChain
> 本项目是对以下论文的实现："AttriChain: Decentralized Traceable Anonymous Identities in Privacy-Preserving Permissioned Blockchain"

一种支持存储用户属性并进行链上认证的区块链，本demo基于以太坊与python3的web3.py开发

## 依赖库
> 应用
* nodejs
* truffle 不低于4.1.8且不高于5
* python3
* ganache-cli
* openSSL

> python库（没有附带链接的都可以通过pip安装）
* web3
* Crypto
* [ZeroKnowledge](https://github.com/anudit/zkpython)(无需下载安装，该库已附带于本项目代码中)
* petlib
* bplib

## 使用方式
```bash
# git下载代码
git clone https://github.com/MilkyBoat/AttriChain.git
cd AttriChain/app
# 启动本地区块链与客户端
ganache-cli -db -l 9007199254740991 -g 1
# 启动python主程序
python AttriChain.py
```
