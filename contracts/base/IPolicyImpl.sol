pragma solidity >=0.5.8;

import "./IPolicyMutations.sol";

contract IPolicyImpl is IPolicyMutations {
  function getStartDate () public view returns (uint256);
  function getState () public view returns (uint256);

  function createTranch (
    uint256 _numShares,
    uint256 _pricePerShareAmount,
    uint256[] memory _premiums,
    address _initialBalanceHolder
  ) public returns (uint256);

  function getNumTranches () public view returns (uint256);
  function getTranchToken (uint256 _index) public view returns (address);
  function getTranchState (uint256 _index) public view returns (uint256);

  function getNumberOfTranchPaymentsMissed (uint256 _index) public view returns (uint256);
  function tranchPaymentsAllMade (uint256 _index) public view returns (bool);
  function getNextTranchPremiumAmount (uint256 _index) public view returns (uint256);
  function payTranchPremium (uint256 _index) public;
  function getTranchBalance (uint256 _index) public view returns (uint256);
  function getNumberOfTranchSharesSold (uint256 _index) public view returns (uint256);
  function getTranchInitialSaleMarketOfferId (uint256 _index) public view returns (uint256);
  function getTranchFinalBuybackMarketOfferId (uint256 _index) public view returns (uint256);

  function getAssetManagerCommissionBalance () public view returns (uint256);
  function getNaymsCommissionBalance () public view returns (uint256);
  function getBrokerCommissionBalance () public view returns (uint256);

  function getNumberOfClaims () external view returns (uint256);
  function getNumberOfUnapprovedClaims () external view returns (uint256);
  function getClaimAmount (uint256 _claimIndex) external view returns (uint256);
  function getClaimTranch (uint256 _claimIndex) external view returns (uint256);
  function isClaimPaid (uint256 _claimIndex) external view returns (bool);
  function isClaimApproved (uint256 _claimIndex) external view returns (bool);

  function calculateMaxNumOfPremiums() public view returns (uint256);
  function initiationDateHasPassed () public view returns (bool);
  function startDateHasPassed () public view returns (bool);
  function maturationDateHasPassed () public view returns (bool);

  function checkAndUpdateState () public;
  function payCommissions (
    address _assetManagerEntity, address _assetManager,
    address _brokerEntity, address _broker
  ) public;

  // events

  event CreateTranch(
    address indexed policy,
    address indexed tranch,
    address indexed initialBalanceHolder,
    uint256 index
  );

  event BeginSale(address indexed policy, address indexed caller);
  event PolicyActive(address indexed policy, address indexed caller);
}
