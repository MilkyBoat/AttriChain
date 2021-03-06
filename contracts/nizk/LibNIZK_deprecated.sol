pragma solidity ^0.4.2;

import "../utillib/LibString.sol";
import "../utillib/LibInt.sol";
import "./LibNizkParam.sol";

library LibNIZK {
    using LibString for *;
    using LibInt for *;
    using LibNizkParam for *;

    function nizk_setup() internal view returns (string) {
        string memory cmd = "[69d98d6a04c41b4605aacb7bd2f74bee][10nizk_setup]";

        uint rLen = 458880*2;
        string memory result = new string(rLen);

        uint strptr;
        assembly {
            strptr := add(result, 0x20)
        }
        cmd = cmd.concat("|", strptr.toString());

        bytes32 hash;
        uint strlen = bytes(cmd).length;
        assembly {
            strptr := add(cmd, 0x20)
            hash := sha3(strptr, strlen)
        }

        string memory errRet = "";
        uint ret = uint(hash);
        if (ret != 0) {
            return errRet;
        }
        
        return result;
    }

    function nizk_verifyproof(
        string pais,
        string balapubcipher,
        string traapubcipher,
        string trabpubcipher,
        string apukkey,
        string bpukkey,
        string nizkpp
        ) internal returns (uint) {
        string memory cmd = "[69d98d6a04c41b4605aacb7bd2f74bee][16nizk_verifyproof]";
        cmd = cmd.concat("|", pais);
        cmd = cmd.concat("|", balapubcipher);
        cmd = cmd.concat("|", traapubcipher);
        cmd = cmd.concat("|", trabpubcipher);
        cmd = cmd.concat("|", apukkey);
        cmd = cmd.concat("|", bpukkey);
        cmd = cmd.concat("|", nizkpp);


        uint strptr;
        bytes32 hash;
        uint strlen = bytes(cmd).length;
        assembly {
            strptr := add(cmd, 0x20)
            hash := sha3(strptr, strlen)
        }

        uint ret = uint(hash);
        return ret;
    }

    function nizk_apubcipheradd(LibNizkParam.NizkParam memory param) internal returns (string){


        string memory cmd = "[69d98d6a04c41b4605aacb7bd2f74bee][18nizk_apubcipheradd]";
        cmd = cmd.concat("|", param.cipher1);
        cmd = cmd.concat("|", param.cipher2);

        string memory result = new string(384);

        uint strptr;
        assembly {
            strptr := add(result, 0x20)
        }
        cmd = cmd.concat("|", strptr.toString());

        /*verify proof*/
        cmd = cmd.concat("|", param.pais);
        cmd = cmd.concat("|", param.balapubcipher);
        cmd = cmd.concat("|", param.traapubcipher);
        cmd = cmd.concat("|", param.trabpubcipher);
        cmd = cmd.concat("|", param.apukkey);
        cmd = cmd.concat("|", param.bpukkey);
        cmd = cmd.concat("|", param.nizkpp);

        bytes32 hash;
        uint strlen = bytes(cmd).length;
        assembly {
            strptr := add(cmd, 0x20)
            hash := sha3(strptr, strlen)
        }

        uint ret = uint(hash);
        if (ret != 0) {
            return "";
        }
        
        return result;
    }

    function nizk_apubciphersub(LibNizkParam.NizkParam memory param) internal returns (string){

        string memory cmd = "[69d98d6a04c41b4605aacb7bd2f74bee][18nizk_apubciphersub]";
        cmd = cmd.concat("|", param.cipher1);
        cmd = cmd.concat("|", param.cipher2);

        uint rLen = 384;
        string memory result = new string(rLen);

        uint strptr;
        assembly {
            strptr := add(result, 0x20)
        }
        cmd = cmd.concat("|", strptr.toString());
        /*verify proof*/
        cmd = cmd.concat("|", param.pais);
        cmd = cmd.concat("|", param.balapubcipher);
        cmd = cmd.concat("|", param.traapubcipher);
        cmd = cmd.concat("|", param.trabpubcipher);
        cmd = cmd.concat("|", param.apukkey);
        cmd = cmd.concat("|", param.bpukkey);
        cmd = cmd.concat("|", param.nizkpp);

        bytes32 hash;
        uint strlen = bytes(cmd).length;
        assembly {
            strptr := add(cmd, 0x20)
            hash := sha3(strptr, strlen)
        }

        string memory errRet = "";
        uint ret = uint(hash);
        if (ret != 0) {
            return errRet;
        }
        
        return result;
    }
}
