// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

import "./test.sol";
// import "./dtbe/LibDTBE.sol";
import "./utillib/Pairing.sol";

contract test_dtbe is test{
    using LibDTBE for *;
    using Pairing for *;

    // LibDTBE.PK public epk;
    // LibDTBE.SK[] public esk;
    // LibDTBE.SVK[] public esvk;
    // Pairing.G1Point[] public c_dtbe;
    // LibDTBE.CLUE[] public V;

    function dtbe_keygen() public {
        (test.epk, test.esk, test.esvk) = LibDTBE.KeyGen(3);
    }

    function dtbe_encrypt() public {
        Pairing.G1Point memory M;
        test.c_dtbe = LibDTBE.encrypt(epk, 123456, M);
    }
}