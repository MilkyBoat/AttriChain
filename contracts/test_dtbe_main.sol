// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

// import "./test_dtbe.sol";
import "./test.sol";
// import "./dtbe/LibDTBE.sol";
import "./utillib/Pairing.sol";

contract test_dtbe_main is test{
    using LibDTBE for *;
    using Pairing for *;

    // LibDTBE.PK public epk;
    // LibDTBE.SK[] public esk;
    // LibDTBE.SVK[] public esvk;
    // Pairing.G1Point[] public c_dtbe;
    LibDTBE.CLUE[] public V;

    function dtbe_shareVerify(uint i) public returns(bool) {
        return LibDTBE.shareVerify(test.epk, test.esvk[i], 123456, test.c_dtbe, V[0]);
    }

    function dtbe_shareDec(uint i) public {
        V[i] = LibDTBE.shareDec(test.epk, test.esk[i], 123456, test.c_dtbe);
    }

    function dtbe_combine() public {
        LibDTBE.combine(test.epk, test.esvk, V, test.c_dtbe, 123456);
    }
}