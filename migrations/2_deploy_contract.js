const Contract = artifacts.require("Contract");

module.exports = async (deployer, _network, accounts) => {
  deployer.deploy(Contract, {
    functionCalled: false,
    admin: "tz1RiffSJssQNXH5BBriGZMhhcqm5j637ehr",
    number: "0",
  });
};
