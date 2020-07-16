// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;
// pragma experimental ABIEncoderV2;

import "./dtbe/LibDTBE.sol";

contract dtbe_interface{
    function getepk1() public returns(uint, uint, uint, uint);
    function getepk2() public returns(uint, uint, uint, uint);
    function getepk3() public returns(uint, uint, uint, uint);
    function getepk4() public returns(uint, uint, uint, uint);
    function getepk5() public returns(uint, uint, uint, uint);
    function getepk6() public returns(uint, uint, uint, uint);
    function getepk7() public returns(uint, uint, uint, uint);
    function getepk8() public returns(uint, uint);
    function getesk() public returns(uint, uint, uint, uint, uint, uint);
    function getesvk1(uint i) public returns(uint, uint, uint, uint);
    function getesvk2(uint i) public returns(uint, uint, uint, uint);
    function getcdtbe1() public returns(uint, uint, uint, uint, uint, uint);
    function getcdtbe2() public returns(uint, uint, uint, uint);
}

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
        require(c_dtbe.length > 0, 'no param');
        LibDTBE.CLUE vi;
        vi.Ci1 = LibDTBE.G1mul(c_dtbe[0], esk[i].ui);
        vi.Ci2 = LibDTBE.G1mul(c_dtbe[1], esk[i].vi);
        V.push(vi);
    }

    function dtbe_combine() public {
        // LibDTBE.combine(epk, esvk, V, c_dtbe, 123456);

        uint len = esvk.length;
        uint i = 0;
        // while(i < len){
        //     LibDTBE.shareVerify(epk, esvk[i], 123456, c_dtbe, V[i]);
        //     // require(
        //     // 	(!shareVerify(epk, esvk[i], t, Cdtbe, v[i])),
        //     // 	"ERROR!Forced to stop."
        //     // );
        // }

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

    function setData(uint addr) public {
        dtbe_interface _dtbe = dtbe_interface(addr);

        uint[30] memory e;

        // epk
        (e[0], e[1], e[2], e[3]) = _dtbe.getepk1();
        (e[4], e[5], e[6], e[7]) = _dtbe.getepk2();
        (e[8], e[9], e[10], e[11]) = _dtbe.getepk3();
        (e[12], e[13], e[14], e[15]) = _dtbe.getepk4();
        (e[16], e[17], e[18], e[19]) = _dtbe.getepk5();
        (e[20], e[21], e[22], e[23]) = _dtbe.getepk6();
        (e[24], e[25], e[26], e[27]) = _dtbe.getepk7();
        (e[28], e[29]) = _dtbe.getepk8();
        LibDTBE.PGroup pg;
        pg._p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        pg._G = Pairing.P2();
		pg._ECG1 = "ECops.sol";
		pg._ECG2 = "ECopsG2.sol";
		pg._pairing = "Pairing.sol";
		epk.P = pg;
        epk.H = Pairing.G1Point(e[0], e[1]);
		epk._H = Pairing.G2Point([e[2], e[3]], [e[4], e[5]]);
		epk.U = Pairing.G1Point(e[6], e[7]);
		epk._U = Pairing.G2Point([e[8], e[9]], [e[10], e[11]]);
        epk.V = Pairing.G1Point(e[12], e[13]);
        epk._V = Pairing.G2Point([e[14], e[15]], [e[16], e[17]]);
        epk.W = Pairing.G1Point(e[18], e[19]);
        epk._W = Pairing.G2Point([e[20], e[21]], [e[22], e[23]]);
        epk.Z = Pairing.G1Point(e[24], e[25]);
        epk._Z = Pairing.G2Point([e[26], e[27]], [e[28], e[29]]);

        // esk
        (e[0], e[1], e[2], e[3], e[4], e[5]) = _dtbe.getesk();
        uint i = 0;
        uint m = 0;
        while (i<3){
            esk.push(LibDTBE.SK({
                ui: e[m],
                vi: e[m + 1]
            }));
            m += 2;
            i++;
        }

        // esvk
        i = 0;
        while (i<3){
            (e[0], e[1], e[2], e[3]) = _dtbe.getesvk1(i);
            (e[4], e[5], e[6], e[7]) = _dtbe.getesvk2(i);
            esvk.push(LibDTBE.SVK({
                Ui: Pairing.G2Point([e[0], e[1]], [e[2], e[3]]),
                Vi: Pairing.G2Point([e[4], e[5]], [e[6], e[7]])
            }));
            i++;
        }

        //c_dtbe
        (e[0], e[1], e[2], e[3], e[4], e[5]) = _dtbe.getcdtbe1();
        (e[6], e[7], e[8], e[9]) = _dtbe.getcdtbe2();
        i = 0;
        m = 0;
        while (i<5){
            c_dtbe.push(Pairing.G1Point(e[m], e[m + 1]));
            m += 2;
            i++;
        }
    }

    // function setepk(uint[] e) public {
    //     LibDTBE.PGroup pg;
    //     pg._p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    //     pg._G = Pairing.P2();
	// 	pg._ECG1 = "ECops.sol";
	// 	pg._ECG2 = "ECopsG2.sol";
	// 	pg._pairing = "Pairing.sol";
	// 	epk.P = pg;
    //     epk.H = Pairing.G1Point(e[0], e[1]);
	// 	epk._H = Pairing.G2Point([e[2], e[3]], [e[4], e[5]]);
	// 	epk.U = Pairing.G1Point(e[6], e[7]);
	// 	epk._U = Pairing.G2Point([e[8], e[9]], [e[10], e[11]]);
    //     epk.V = Pairing.G1Point(e[12], e[13]);
    //     epk._V = Pairing.G2Point([e[14], e[15]], [e[16], e[17]]);
    //     epk.W = Pairing.G1Point(e[18], e[19]);
    //     epk._W = Pairing.G2Point([e[20], e[21]], [e[22], e[23]]);
    //     epk.Z = Pairing.G1Point(e[24], e[25]);
    //     epk._Z = Pairing.G2Point([e[26], e[27]], [e[28], e[29]]);
    // }
    // function setesk(uint[] e) public{
    //     uint i = 0;
    //     uint m = 0;
    //     while (i<3){
    //         esk.push(LibDTBE.SK({
    //             ui: e[m],
    //             vi: e[m + 1]
    //         }));
    //         m += 2;
    //         i++;
    //     }
    // }
    // function setesvk(uint[] e) public{
    //     uint i = 0;
    //     uint m = 0;
    //     while (i<3){
    //         esvk.push(LibDTBE.SVK({
    //             Ui: Pairing.G2Point([e[m], e[m + 1]], [e[m + 2], e[m + 3]]),
    //             Vi: Pairing.G2Point([e[m + 4], e[m + 5]], [e[m + 6], e[m + 7]])
    //         }));
    //         m += 4;
    //         i++;
    //     }
    // }
    // function setcdtbe(uint[] c) public{
    //     uint i = 0;
    //     uint m = 0;
    //     while (i<5){
    //         c_dtbe.push(Pairing.G1Point(c[m], c[m + 1]));
    //         m += 2;
    //         i++;
    //     }
    // }
}