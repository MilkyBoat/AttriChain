pragma solidity >=0.4.2;

library LibDTBE {

    function KeyGen(/*uint k, uint n*/) internal returns(string memory, string[] memory, string[] memory){
        string memory epk = '';
        string[] memory esk = new string[](3);
        string[] memory esvk = new string[](3);
        return (epk, esk, esvk);
    }

    function encrypt(string epk, string t, string m) internal returns(string memory){
        return '';
    }

    function isVaild(string epk,string t, string m, string Cttbe) internal returns(bool) {
        return true;
    }

    function shareDec(string epk,string esk, string t, string Cttbe) internal returns(string memory){
        return '';
    }

    function shareVerify(string epk,string esvk, string t, string vi, string Cttbe) internal returns(bool){
        return true;
    }

    function combine(string epk, string[] storage esvk, string t, string[] storage vi, string Cttbe) internal returns(string memory){
        return '';
    }
}