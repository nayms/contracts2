// SPDX-License-Identifier: MIT
pragma solidity >=0.6.7;

import "./base/Controller.sol";
import "./base/IDiamondUpgradeFacet.sol";
import "./base/IDiamondProxy.sol";

contract CommonUpgradeFacet is Controller, IDiamondUpgradeFacet {
  constructor (address _settings) Controller(_settings) public {
    // empty
  }

  function upgrade (address[] memory _facets) public override assertIsAdmin {
    IDiamondProxy(address(this)).registerFacets(_facets);
  }

  function getVersionInfo () public override pure returns (string memory num_, uint256 date_, string memory hash_) {
    num_ = "1.0.0-pr.134.build.1474";
    date_ = 1637841761;
    hash_ = "b7217a2461530094972f39fcd530008d7aa4184f";
  }
}
