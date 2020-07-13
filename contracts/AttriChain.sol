// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

contract AttriChain{

    string public Ce;
    string[] public V;

    constructor() public {
        V = new string[](3);
    }

    function getCe() public view returns (string memory){
        return Ce;
    }

    function setCe(string memory str) public {
        Ce = str;
    }

    function getVi(uint i) public view returns(string memory){
        return V[i];
    }

    function setVi(string memory vi, uint i) public {
        V[i] = vi;
    }
}