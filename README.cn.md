# AttriChain
一种支持存储用户属性并进行链上认证的区块链，本demo基于以太坊与python3的web3.py开发

## 依赖库
> 应用
* nodejs
* truffle 不低于4.1.8且不高于5
* python3
* ganache-cli

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
ganache-cli -db -l 10000000 -g 100;
# 启动python主程序
python AttriChain.py
```
