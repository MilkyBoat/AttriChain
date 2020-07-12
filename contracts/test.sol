pragma solidity >=0.4.2;

import "./nizk/LibNIZK.sol";
import "./nizk/LibNizkParam.sol";
import "./dtbe/LibDTBE.sol";

contract test{
    using LibNIZK for *;
    using LibNizkParam for *;
    using LibDTBE for *;

    string public nizk_pp;

    function nizk_setup() public returns(string memory) {
        nizk_pp = LibNIZK.nizk_setup();
        return nizk_pp;
    }

    function nizk_add() public {
        LibNizkParam.NizkParam param;
        LibNizkParam.reset(param);
        param.nizkpp = 'nizk_pp';
        LibNIZK.nizk_apubcipheradd(param);
    }

    function nizk_sub() public {
        LibNizkParam.NizkParam param;
        LibNizkParam.reset(param);
        param.nizkpp = 'nizk_pp';
        LibNIZK.nizk_apubciphersub(param);
    }
}