var chainInit = artifacts.require("./ChainInit.sol");
// var test = artifacts.require("./test.sol")


module.exports = function(deployer) {
    deployer.deploy(chainInit);
    // deployer.deploy(test);
    // deployer.deploy()
};
