pragma solidity >=0.4.2;

contract AttriChain{

    string public saveStr;
    string public saveIng;

    function getStr() public view returns (string memory){
        return saveStr;
    }

    function setStr(string memory inputstr) public {
        saveStr = inputstr;
    }

    function setString(string memory inputIng) public {
        saveIng = inputIng;
    }
}