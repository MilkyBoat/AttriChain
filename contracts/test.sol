pragma solidity >=0.4.2;

import "./nizk/LibNIZK.sol";
import "./dtbe/LibDTBE.sol";

contract test{
    using LibNIZK for *;
    using LibDTBE for *;

    function nizk_setup() public {
        LibNIZK.nizk_setup();
    }

    // function nizk_setup() public {
    //     LibNIZK.nizk_setup();
    // }
}