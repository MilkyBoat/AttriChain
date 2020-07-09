# AttriChain

## requirements
#### tools
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
truffle migrate --reset;
ganache-cli -db ./ -g 10000 -l 4294967295;
python ./app/AttriChain.py
```

## accounts list
* (0) 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1 user
* (1) 0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0 attribution institution
* (2) 0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b attribution institution
* (3) 0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d trace institution
* (4) 0xd03ea8624C8C5987235048901fB614fDcA89b117 trace institution
* (5) 0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC trace institution
* (6) 0x3E5e9111Ae8eB78Fe1CC3bb8915d5D461F3Ef9A9 other
* (7) 0x28a8746e75304c0780E011BEd21C72cD78cd535E other
* (8) 0xACa94ef8bD5ffEE41947b4585a84BdA5a3d3DA6E other
* (9) 0x1dF62f291b2E969fB0849d99D9Ce41e2F137006e other
