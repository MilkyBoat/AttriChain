// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;
// pragma experimental ABIEncoderV2;

import "./dtbe/LibDTBE.sol";

contract test_dtbe{
    using LibDTBE for *;
    using Pairing for *;

    LibDTBE.PGroup public pg;
    LibDTBE.PK public epk;
    LibDTBE.SK[] public esk;
    LibDTBE.SVK[] public esvk;
    Pairing.G1Point[] public c_dtbe;
    // LibDTBE.CLUE[] public V;

    uint256 h;
    uint256 w;
    uint256 z;
    uint256[3] _ui;
    uint256[3] _vi;
    uint256 u = 0; //sum of ui
    uint256 v = 0; //sum of vi
    Pairing.G2Point[3] _ui_;
    Pairing.G2Point[3] _vi_;


    function dtbe_keygen_1() public {
        // (epk, esk, esvk) = LibDTBE.KeyGen(3);

        uint n = 3;
        uint p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        pg._p = p;
        pg._G = Pairing.P2();
		pg._ECG1 = "ECops.sol";
		pg._ECG2 = "ECopsG2.sol";
		pg._pairing = "Pairing.sol";
		epk.P = pg;

        h = LibDTBE.rand(p);
        w = LibDTBE.rand(p);
        z = LibDTBE.rand(p);
        // uint256 h = LibDTBE.rand(p);
        // uint256 w = LibDTBE.rand(p);
        // uint256 z = LibDTBE.rand(p);
        // uint256[] memory _ui = new uint256[](n);
        // uint256[] memory _vi = new uint256[](n);
        // uint256 u = 0; //sum of ui
        // uint256 v = 0; //sum of vi

        uint i = 0;
        while(i < n){
            _ui[i] = LibDTBE.rand(p);
            _vi[i] = LibDTBE.rand(p);
            u = u + _ui[i];
            v = v + _vi[i];
            //initialize the sk
            esk.push(LibDTBE.SK({
                ui: _ui[i],
                vi: _vi[i]
            }));
            i++;
        }

        epk.H = LibDTBE.G1mul(Pairing.P1(), h);
		// epk._H = LibDTBE.G2mul(Pairing.P2(), h);

		epk.U = LibDTBE.G1mul(epk.H, u);
		// epk._U = LibDTBE.G2mul(epk._H, u);

        epk.V = LibDTBE.G1mul(epk.U, ECops.inverse(v));
        // epk._V = LibDTBE.G2mul(epk._U, ECops.inverse(v));

        epk.W = LibDTBE.G1mul(epk.H, w);
        // epk._W = LibDTBE.G2mul(epk._H, w);

        epk.Z = LibDTBE.G1mul(epk.V, z);
        // epk._Z = LibDTBE.G2mul(epk._V, z);

        // i = 0;
        // while(i < n){
        //     esvk.push(LibDTBE.SVK({
        //         Ui: LibDTBE.G2mul(epk._H, _ui[i]),
        //         Vi: LibDTBE.G2mul(epk._V, _vi[i])
        //     }));
        //     i++;
        // }
    }

    function dtbe_keygen_2() public {
		epk._H = LibDTBE.G2mul(Pairing.P2(), h);
		// epk._U = LibDTBE.G2mul(epk._H, u);
        // epk._V = LibDTBE.G2mul(epk._U, ECops.inverse(v));
        // epk._W = LibDTBE.G2mul(epk._H, w);
        // epk._Z = LibDTBE.G2mul(epk._V, z);
    }

    function dtbe_keygen_3() public {
		epk._U = LibDTBE.G2mul(epk._H, u);
    }

    function dtbe_keygen_4() public {
		epk._V = LibDTBE.G2mul(epk._U, ECops.inverse(v));
    }

    function dtbe_keygen_5() public {
		epk._W = LibDTBE.G2mul(epk._H, w);
    }

    function dtbe_keygen_6() public {
		epk._Z = LibDTBE.G2mul(epk._V, z);
    }

    function dtbe_keygen_7(uint i) public {
        _ui_[i] = LibDTBE.G2mul(epk._H, _ui[i]);
    }

    function dtbe_keygen_8(uint i) public {
        _vi_[i] = LibDTBE.G2mul(epk._V, _vi[i]);
    }

    function dtbe_keygen_9() public {
        uint n = 3;
        uint i = 0;
        while(i < n){
            esvk.push(LibDTBE.SVK({
                Ui: _ui_[i],
                Vi: _vi_[i]
            }));
            i++;
        }
    }

    function dtbe_encrypt() public {
        // Pairing.G1Point memory M = Pairing.G1Point(123, 456);
        // c_dtbe = LibDTBE.encrypt(epk, 123456, M);

        uint p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        uint256 r1 = LibDTBE.rand(p);
		uint256 r2 = LibDTBE.rand(p);
        c_dtbe.push(LibDTBE.G1mul(epk.H, r1));
        c_dtbe.push(LibDTBE.G1mul(epk.V, r2));
        c_dtbe.push(LibDTBE.G1add(Pairing.G1Point(123, 456), LibDTBE.G1mul(epk.U, r1 + r2)));
        Pairing.G1Point memory tmp = LibDTBE.G1mul(epk.U, 123456);
        c_dtbe.push(LibDTBE.G1mul(LibDTBE.G1add(tmp, epk.W), r1));
        c_dtbe.push(LibDTBE.G1mul(LibDTBE.G1add(tmp, epk.Z), r2));
    }

    function getepk1() public returns(uint, uint, uint, uint) {
        return (epk.H.X, epk.H.Y, epk._H.X[0], epk._H.X[1]);
    }

    function getepk2() public returns(uint, uint, uint, uint){
        return (epk._H.Y[0], epk._H.Y[1], epk.U.X, epk.U.Y);
    }

    function getepk3() public returns(uint, uint, uint, uint){
        return (epk._U.X[0], epk._U.X[1], epk._U.Y[0], epk._U.Y[1]);
    }

    function getepk4() public returns(uint, uint, uint, uint){
        return (epk.V.X, epk.V.Y, epk._V.X[0], epk._V.X[1]);
    }

    function getepk5() public returns(uint, uint, uint, uint){
        return (epk._V.Y[0], epk._V.Y[1], epk.W.X, epk.W.Y);
    }

    function getepk6() public returns(uint, uint, uint, uint){
        return (epk._W.X[0], epk._W.X[1], epk._W.Y[0], epk._W.Y[1]);
    }

    function getepk7() public returns(uint, uint, uint, uint){
        return (epk.Z.X, epk.Z.Y, epk._Z.X[0], epk._Z.X[1]);
    }

    function getepk8() public returns(uint, uint){
        return (epk._Z.Y[0], epk._Z.Y[1]);
    }

    function getesk() public returns(uint, uint, uint, uint, uint, uint) {
        return (esk[0].ui, esk[0].vi, esk[1].ui, esk[1].vi, esk[2].ui, esk[2].vi);
    }

    function getesvk1(uint i) public returns(uint, uint, uint, uint) {
        return (
        esvk[i].Ui.X[0],
        esvk[i].Ui.X[1],
        esvk[i].Ui.Y[0],
        esvk[i].Ui.Y[1]
        );
    }

    function getesvk2(uint i) public returns(uint, uint, uint, uint) {
        return (
        esvk[i].Vi.X[0],
        esvk[i].Vi.X[1],
        esvk[i].Vi.Y[0],
        esvk[i].Vi.Y[1]
        );
    }

    function getcdtbe1() public returns(uint, uint, uint, uint, uint, uint) {
        return (
            c_dtbe[0].X, c_dtbe[0].Y,
            c_dtbe[1].X, c_dtbe[1].Y,
            c_dtbe[2].X, c_dtbe[2].Y
        );
    }

    function getcdtbe2() public returns(uint, uint, uint, uint) {
        return (
            c_dtbe[3].X, c_dtbe[3].Y,
            c_dtbe[4].X, c_dtbe[4].Y
            );
    }

    // function transData(uint main_addr) public {
    //     test_dtbe_main_interface test_main = test_dtbe_main_interface(main_addr);
    //     // epk
    //     uint[] e;
    //     e.push(epk.H.X); e.push(epk.H.Y);
    //     e.push(epk._H.X[0]); e.push(epk._H.X[1]); e.push(epk._H.Y[0]); e.push(epk._H.Y[1]);
    //     e.push(epk.U.X); e.push(epk.U.Y);
    //     e.push(epk._U.X[0]); e.push(epk._U.X[1]); e.push(epk._U.Y[0]); e.push(epk._U.Y[1]);
    //     e.push(epk.V.X); e.push(epk.V.Y);
    //     e.push(epk._V.X[0]); e.push(epk._V.X[1]); e.push(epk._V.Y[0]); e.push(epk._V.Y[1]);
    //     e.push(epk.W.X); e.push(epk.W.Y);
    //     e.push(epk._W.X[0]); e.push(epk._W.X[1]); e.push(epk._W.Y[0]); e.push(epk._W.Y[1]);
    //     e.push(epk.Z.X); e.push(epk.Z.Y);
    //     e.push(epk._Z.X[0]); e.push(epk._Z.X[1]); e.push(epk._Z.Y[0]); e.push(epk._Z.Y[1]);
    //     test_main.setepk();

    //     // esk
    //     e.length = 0;
    //     uint i = 0;
    //     while(i<3){
    //         e.push(esk[i].ui);
    //         e.push(esk[i].vi);
    //         i++;
    //     }
    //     test_main.setesk(e);

    //     // esvk
    //     e.length = 0;
    //     i = 0;
    //     while(i<3){
    //         e.push(esvk[i].Ui.X[0]);
    //         e.push(esvk[i].Ui.X[1]);
    //         e.push(esvk[i].Ui.Y[0]);
    //         e.push(esvk[i].Ui.Y[1]);
    //         e.push(esvk[i].Vi.X[0]);
    //         e.push(esvk[i].Vi.X[1]);
    //         e.push(esvk[i].Vi.Y[0]);
    //         e.push(esvk[i].Vi.Y[1]);
    //         i++;
    //     }
    //     test_main.setesk(e);

    //     // c_dtbe
    //     e.length = 0;
    //     i = 0;
    //     while(i<5){
    //         e.push(c_dtbe[i].X);
    //         e.push(c_dtbe[i].Y);
    //     }
    //     test_main.setcdtbe(e);
    // }
}