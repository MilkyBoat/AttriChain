pragma solidity >=0.4.2;

import "./nizk/LibNIZK.sol";
import "./LibDTBE.sol";

contract ChainInit {
    using LibNIZK for *;
    using LibDTBE for *;

    mapping(address => string) public accountType;
    mapping(address => string) public pubKey;
    mapping(address => string) priKey;

    address[1] public user_addr;
    address[2] public attri_addr;
    address[3] public track_addr;

    uint public userNum = 1;
    uint public attriNum = 2;
    uint public trackNum = 3;

    string public crs;
    string epk;
    string[] esk;
    string[] esvk;

    event log(address indexed _from, string _info);

    constructor() public {
        user_addr[0] = 0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1;
        attri_addr[0] = 0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0;
        attri_addr[1] = 0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b;
        track_addr[0] = 0xE11BA2b4D45Eaed5996Cd0823791E0C93114882d;
        track_addr[1] = 0xd03ea8624C8C5987235048901fB614fDcA89b117;
        track_addr[2] = 0x95cED938F7991cd0dFcb48F0a06a40FA1aF46EBC;

        for (uint i = 0; i < userNum; i++){
            accountType[user_addr[i]] = 'user';
        }
        for (i = 0; i < attriNum; i++){
            accountType[attri_addr[i]] = 'attri';
        }
        for (i = 0; i < trackNum; i++){
            accountType[track_addr[i]] = 'track';
        }

        // 全局初始化
        crs = LibNIZK.nizk_setup();
        (epk, esk, esvk) = LibDTBE.KeyGen();

        // 用户初始化，python web3完成

        // 属性机构初始化，python web3完成

        // 追踪机构初始化
        for (i = 0; i<3; i++){
            priKey[track_addr[i]] = esk[i];
        }
    }

    // 用户初始化函数
    function userInit(uint uid, string memory usk, string memory psk) public {
        pubKey[user_addr[uid]] = psk;
        priKey[user_addr[uid]] = usk;
    }

    // 属性机构初始化函数
    function attriInit(uint aid, string memory usk, string memory psk) public {
        pubKey[attri_addr[aid]] = psk;
        priKey[attri_addr[aid]] = usk;
    }

    function helloWorld() public returns (string){
        emit log(msg.sender, "helloWorld!");
        return 'helloworld!';
    }
}
