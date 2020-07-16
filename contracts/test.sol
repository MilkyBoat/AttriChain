// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;

// import "./nizk/LibNizk.sol";
import "./dtbe/LibDTBE.sol";

contract test{
    // using Schnorr for *;
    // using LibDTBE for *;
    // using Pairing for *;

    // uint256[2] pk;
    // uint256 s;
    // uint256 e;

    LibDTBE.PGroup public pg;
    LibDTBE.PK public epk;
    LibDTBE.SK[] public esk;
    LibDTBE.SVK[] public esvk;
    Pairing.G1Point[] public c_dtbe;
    // LibDTBE.CLUE[] public V;

    // function nizk_prove() public {
    //     (pk, s, e) = Schnorr.CreateProof(12345, 12345);
    // }

    // function nizk_verify() public returns(bool) {
    //     return Schnorr.VerifyProof(pk, 12345, s, e);
    // }

    // function dtbe_keygen() public {
    //     (epk, esk, esvk) = LibDTBE.KeyGen(3);
    // }

    // function dtbe_encrypt() public {
    //     Pairing.G1Point memory M;
    //     c_dtbe = LibDTBE.encrypt(epk, 123456, M);
    // }

    // function dtbe_shareVerify(uint i) public returns(bool) {
        // return LibDTBE.shareVerify(epk, esvk[i], 123456, c_dtbe, V[0]);
    // }

    // function dtbe_shareDec(uint i) public {
    //     V[i] = LibDTBE.shareDec(epk, esk[i], 123456, c_dtbe);
    // }

    // function dtbe_combine() public {
    //     LibDTBE.combine(epk, esvk, V, c_dtbe, 123456);
    // }
}