from  web3 import Web3
from web3.contract import ConciseContract
import pandas as pd
from solc import compile_files
import time
import random
import sys
from solc import compile_files, link_code, compile_source

def call_test():
  count=[500,1000,2000,5000]
  rate=[0.0,0.01,0.05,0.10]
  for c in count:
    for r in rate:
      print("%8d,%8.2f,%8.2f"%(c,r,test(c,r,20)))

def test(logs_count,abnormal_rate,round):
  time_=0
  log_data=list(pd.read_csv('Apache_2k.log_structured.csv').Content)
  for i in range(round):
    abnormal_data=random.sample(log_data,int(logs_count*abnormal_rate))
    abnormal_data=['flagflag'+each for each in abnormal_data]
    normal_data=random.sample(log_data,int(logs_count*(1.0-abnormal_rate)))
    #print (len(normal_data))
    #print (len(abnormal_data))
    log_data=abnormal_data+normal_data
    random.shuffle(log_data)
    random.shuffle(log_data)
    time_start=time.time()
    account=web3.eth.accounts[0]
    for log in log_data:
      #print ("%s:%d"%(log,contract_instance.call().detect_log_by_dis(log)))
      if contract_instance.call().detect_log_by_dis(log)>10:
        print (log)
        try:
          web3.eth.sendTransaction({'from':account,'to':account,'value':web3.toWei(0, "ether"),'msg':'alert'})
        except Exception as e:
          #print ("need unlock account first.")
          web3.personal.unlockAccount(account,passphrase='123456')
          web3.eth.sendTransaction({'from':account,'to':account,'value':web3.toWei(0, "ether"),'msg':'alert'})
    time_end=time.time()
    time_+=time_end-time_start
    time.sleep(10*(logs_count/500))
  return (time_/float(round))

def create_contract():
  templates=str(list(pd.read_csv('templates.csv').templates))
  first_file=open('first.csv','r')
  first=first_file.read()
  first_file.close()
  second_file=open('second.csv','r')
  second=second_file.read()
  second_file.close()
  return first+templates+second

global contract_instance
if __name__=='__main__':
  #connect to the node
  auto_create=create_contract()
  out=open('out.sol','w')
  out.write(auto_create)
  out.close()
  web3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
  MyContracts = compile_files(["out.sol","Strings.sol"])
  main_contract = MyContracts.pop("out.sol:log_analysis")
  library_link = MyContracts.pop("Strings.sol:strings")
  #deploy the smart contract
  MyContract=web3.eth.contract(abi=main_contract['abi'],bytecode=main_contract['bin']) 
  web3.personal.unlockAccount(web3.eth.accounts[0],passphrase='123456') 
  tx_hash=MyContract.deploy({'from':web3.eth.accounts[0]})
  tx_receipt = ''
  while not tx_receipt:
    tx_receipt = web3.eth.getTransactionReceipt(tx_hash)
    time.sleep(1)
  
  contract_instance = web3.eth.contract(address=tx_receipt["contractAddress"],abi=main_contract["abi"])
  #print (contract_instance.call().cal_distance("jk2_init() Found child 6725 in scoreboard slot 10","jk2_init() Found child <*> in scoreboard slot <*>"))
  #print(contract_instance.call().detect_log_by_dis("jk2_init() Found child 6725 in scoreboard slot 10"))
  #print(contract_instance.call().detect_logs("t4"))
  print ('testing...\n\tcount\tabnormal_rate\ttime')
  call_test()

