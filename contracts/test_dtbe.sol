// This file is MIT Licensed.
//
// Copyright 2020 xu yunkai

pragma solidity >=0.4.2;
// pragma experimental ABIEncoderV2;

import "./dtbe/LibDTBE.sol";

// contract test_dtbe_main{
//     function setepk(LibDTBE.PK _epk) public;
//     function setesk(LibDTBE.SK[] _esk) public;
//     function setesvk(LibDTBE.SVK[] _esvk) public;
//     function setcdtbe(Pairing.G1Point[] _c_dtbe) public;
// }

contract test_dtbe{
    using LibDTBE for *;
    using Pairing for *;

    LibDTBE.PGroup public pg;
    LibDTBE.PK public epk;
    LibDTBE.SK[] public esk;
    LibDTBE.SVK[] public esvk;
    Pairing.G1Point[] public c_dtbe;
    // LibDTBE.CLUE[] public V;

    uint p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint256 h;
    uint256 w;
    uint256 z;
    uint256[3] _ui;
    uint256[3] _vi;
    uint256 u = 0; //sum of ui
    uint256 v = 0; //sum of vi
    Pairing.G2Point[3] _ui_;
    Pairing.G2Point[3] _vi_;


    // function get

    function dtbe_keygen_1() public {
        // (epk, esk, esvk) = LibDTBE.KeyGen(3);

        uint n = 3;
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

        uint256 r1 = LibDTBE.rand(p);
		uint256 r2 = LibDTBE.rand(p);
        c_dtbe.push(LibDTBE.G1mul(epk.H, r1));
        c_dtbe.push(LibDTBE.G1mul(epk.V, r2));
        c_dtbe.push(LibDTBE.G1add(Pairing.G1Point(123, 456), LibDTBE.G1mul(epk.U, r1 + r2)));
        Pairing.G1Point memory tmp = LibDTBE.G1mul(epk.U, 123456);
        c_dtbe.push(LibDTBE.G1mul(LibDTBE.G1add(tmp, epk.W), r1));
        c_dtbe.push(LibDTBE.G1mul(LibDTBE.G1add(tmp, epk.Z), r2));
    }
}