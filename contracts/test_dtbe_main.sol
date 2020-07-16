// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;
// pragma experimental ABIEncoderV2;

import "./dtbe/LibDTBE.sol";

contract test_dtbe_main{
    using LibDTBE for *;
    using Pairing for *;

    LibDTBE.PK public epk;
    LibDTBE.SK[] public esk;
    LibDTBE.SVK[] public esvk;
    Pairing.G1Point[] public c_dtbe;
    LibDTBE.CLUE[] public V;

    // function dtbe_shareVerify(uint i) public returns(bool) {
    //     return LibDTBE.shareVerify(epk, esvk[i], 123456, c_dtbe, V[0]);
    // }

    function dtbe_shareDec(uint i) public {
        // V[i] = LibDTBE.shareDec(epk, esk[i], 123456, c_dtbe);

        LibDTBE.CLUE vi;
        vi.Ci1 = LibDTBE.G1mul(c_dtbe[0], esk[i].ui);
        vi.Ci2 = LibDTBE.G1mul(c_dtbe[1], esk[i].vi);
        V.push(vi);
    }

    function dtbe_combine() public {
        // LibDTBE.combine(epk, esvk, V, c_dtbe, 123456);

        uint len = esvk.length;
        uint i = 0;
        while(i < len){
            LibDTBE.shareVerify(epk, esvk[i], 123456, c_dtbe, V[i]);
            // require(
            // 	(!shareVerify(epk, esvk[i], t, Cdtbe, v[i])),
            // 	"ERROR!Forced to stop."
            // );
        }

        Pairing.G1Point memory tmp = LibDTBE.G1add(V[0].Ci1, V[0].Ci2);
        i = 1;
        while(i < len){
            tmp = LibDTBE.G1add(tmp, LibDTBE.G1add(V[i].Ci1, V[i].Ci2));
            i++;
        }
        tmp = Pairing.negate(tmp);
        LibDTBE.G1add(tmp, c_dtbe[2]);
        // return M;
    }

    // function setepk(LibDTBE.PK _epk) public{
    //     epk = _epk;
    // }
    // function setesk(LibDTBE.SK[] _esk) public{
    //     uint i = 0;
    //     while (i<3){
    //         esk.push(_esk[i]);
    //         i++;
    //     }
    // }
    // function setesvk(LibDTBE.SVK[] _esvk) public{
    //     uint i = 0;
    //     while (i<3){
    //         esvk.push(_esvk[i]);
    //         i++;
    //     }
    // }
    // function setcdtbe(Pairing.G1Point[] _c_dtbe) public{
    //     uint i = 0;
    //     while (i<5){
    //         c_dtbe.push(_c_dtbe[i]);
    //         i++;
    //     }
    // }
}