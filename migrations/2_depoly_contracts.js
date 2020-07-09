var chain = artifacts.require("./AttriChain.sol");
// var test = artifacts.require("./test.sol")

module.exports = function(deployer) {
    deployer.deploy(chain);
    // deployer.deploy(test);
};
