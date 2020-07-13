// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

import "./nizk/LibNizk.sol";
import "./dtbe/LibDTBE.sol";
import "./utillib/Pairing.sol";

contract test{
    using Schnorr for *;
    using LibDTBE for *;
    using Pairing for *;

    uint256[2] pk;
    uint256 s;
    uint256 e;

    LibDTBE.PK public epk;
    LibDTBE.SK[3] public esk;
    LibDTBE.SVK[3] public esvk;
    Pairing.G1Point[] public c_dtbe;

    function nizk_prove() public {
        (pk, s, e) = Schnorr.CreateProof(12345, 12345);
    }

    function nizk_verify() public returns(bool) {
        return Schnorr.VerifyProof(pk, 12345, s, e);
    }

    function dtbe_keygen() public {
        // LibDTBE.SK[] memory sk;
        // LibDTBE.SVK[] memory svk;
        // LibDTBE.KeyGen(3);
        // for (uint i = 0;i < 3;i++){
        //     esk[i] = sk[i];
        // }
        // for (i = 0;i < 3;i++){
        //     esvk[i] = svk[i];
        // }
    }

    function dtbe_encrypt() public {
        Pairing.G1Point memory M;
        LibDTBE.encrypt(epk, 123456, M);
    }

    function dtbe_encrypt() public {
        Pairing.G1Point memory M;
        LibDTBE.encrypt(epk, 123456, M);
    }
}