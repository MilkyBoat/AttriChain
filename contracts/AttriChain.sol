// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

import "./nizk/LibNizk.sol";
import "./dtbe/LibDTBE.sol";
import "./utillib/Pairing.sol";

contract AttriChain{

    using Schnorr for *;
    using LibDTBE for *;
    using Pairing for *;

    mapping(address => string) public pk;
    mapping(address => string) sk;

    address[1] public user_addr;
    address[2] public attri_addr;
    address[3] public track_addr;

    constructor() public{
        user_addr[0] = 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1;
        attri_addr[0] = 0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0;
        attri_addr[1] = 0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b;
        track_addr[0] = 0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d;
        track_addr[1] = 0xd03ea8624C8C5987235048901fB614fDcA89b117;
        track_addr[2] = 0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC;


    }

    function request(uint uid, string memory alpha) public {

    }

    function authentication(uint uid, string memory alpha) internal returns(string memory) {
        
    }
}
