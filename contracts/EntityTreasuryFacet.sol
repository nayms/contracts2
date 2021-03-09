pragma solidity >=0.6.7;

import "./base/Controller.sol";
import "./base/EternalStorage.sol";
import "./base/EntityFacetBase.sol";
import "./base/IPolicyTreasury.sol";
import "./base/IERC20.sol";
import "./base/IDiamondFacet.sol";

/**
 * @dev Business-logic for policy treasuries
 */
 contract EntityTreasuryFacet is EternalStorage, Controller, EntityFacetBase, IPolicyTreasury, IDiamondFacet {
  /**
   * Constructor
   */
  constructor (address _settings) Controller(_settings) public {
  }

  // IDiamondFacet

  function getSelectors () public pure override returns (bytes memory) {
    return abi.encodePacked(
      IPolicyTreasury.tradeTokens.selector
    );
  }


  // IPolicyTreasury

  function tradeTokens (address _token, uint256 _tokenAmount, address _priceUnit, uint256 _priceAmount) 
    public 
    override
    assertIsPolicyCreatedByMe(msg.sender)
    returns (uint256)
  {
    return _tradeOnMarket(_token, _tokenAmount, _priceUnit, _priceAmount);
  }
}
