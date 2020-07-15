// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

import "./nizk/LibNizk.sol";

contract test_nizk{
    using Schnorr for *;

    uint256[2] pk;
    uint256 s;
    uint256 e;

    function nizk_prove() public {
        (pk, s, e) = Schnorr.CreateProof(12345, 12345);
    }

    function nizk_verify() public returns(bool) {
        return Schnorr.VerifyProof(pk, 12345, s, e);
    }

}