pragma solidity >=0.4.2;

contract AttriChain{

    string public Ce;

    function getCe() public view returns (string memory){
        return Ce;
    }

    function setCe(string memory str) public {
        Ce = str;
    }
}