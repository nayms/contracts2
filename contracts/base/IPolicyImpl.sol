pragma solidity >=0.6.7;

import "./IPolicyClaims.sol";
import "./IPolicyCommissions.sol";
import "./IPolicyPremiums.sol";

/**
 * @dev Policies.
 */
abstract contract IPolicyImpl is IPolicyClaims, IPolicyCommissions, IPolicyPremiums {
  /**
   * @dev Create tranch.
   *
   * @param _numShares No. of shares in this tranch.
   * @param _pricePerShareAmount Price of each share during the initial sale period.
   * @param _premiums Premium payment amounts in chronological order.
   * @param _initialBalanceHolder For testing only. For normal use set to `0x`.
   */
  function createTranch (
    uint256 _numShares,
    uint256 _pricePerShareAmount,
    uint256[] memory _premiums,
    address _initialBalanceHolder
  ) public virtual;

  /**
   * @dev Get policy info.
   *
   * @return initiationDate_ Initiation date  (seconds since epoch).
   * @return startDate_ Start date  (seconds since epoch).
   * @return maturationDate_ Maturation date (seconds since epoch).
   * @return unit_ Payment unit (for tranch sale, premiums, claim payouts, etc).
   * @return premiumIntervalSeconds_ Time between premium payments (seconds).
   * @return brokerCommissionBP_ Broker's commission rate (1 = 0.1%)
   * @return assetManagerCommissionBP_ Asset managers commission rate (1 = 0.1%)
   * @return naymsCommissionBP_ Nayms commission rate (1 = 0.1%)
   * @return numTranches_ No. of tranches created.
   * @return state_ Current policy state.
   */
  function getInfo () public view virtual returns (
    uint256 initiationDate_,
    uint256 startDate_,
    uint256 maturationDate_,
    address unit_,
    uint256 premiumIntervalSeconds_,
    uint256 brokerCommissionBP_,
    uint256 assetManagerCommissionBP_,
    uint256 naymsCommissionBP_,
    uint256 numTranches_,
    uint256 state_
  );

  /**
   * @dev Get claim stats.
   * @return numClaims_ No. of claims raised in total.
   * @return numPendingClaims_ No. of claims yet to be approved/declined.
   */
  function getClaimStats() public view virtual returns (
    uint256 numClaims_,
    uint256 numPendingClaims_
  );

  /**
   * @dev Get tranch info.
   *
   * @param _index Tranch index.
   * @return token_ Tranch ERC-20 token address.
   * @return state_ Current tranch state.
   * @return balance_ Current tranch balance (of the payment unit)
   * @return numPremiums_ No. of premium payments required in total.
   * @return nextPremiumAmount_ Payment due by the next premium interval.
   * @return nextPremiumDueAt_ When the next premium payment is due by (timestamp = seconds since epoch).
   * @return premiumPaymentsMissed_ No. of premium payments that have been missed.
   * @return numPremiumsPaid_ No. of premium payments made.
   * @return sharesSold_ No. of shared sold (during the initial sale period).
   * @return initialSaleOfferId_ Market offer id of the initial sale.
   * @return finalBuybackofferId_ Market offer id of the post-maturation/cancellation token buyback.
   */
  function getTranchInfo (uint256 _index) public view virtual returns (
    address token_,
    uint256 state_,
    uint256 balance_,
    uint256 numPremiums_,
    uint256 nextPremiumAmount_,
    uint256 nextPremiumDueAt_,
    uint256 premiumPaymentsMissed_,
    uint256 numPremiumsPaid_,
    uint256 sharesSold_,
    uint256 initialSaleOfferId_,
    uint256 finalBuybackofferId_
  );


  /**
   * @dev Get tranch premium info.
   *
   * @param _tranchIndex Tranch index.
   * @param _premiumIndex Premium index.
   * @return amount_ Amount due.
   * @return dueAt_ When it is due by (timestamp = seconds since epoch).
   * @return paidAt_ When it was paid (timestamp = seconds since epoch).
   * @return paidBy_ Who paid it.
   */
  function getTranchPremiumInfo (uint256 _tranchIndex, uint256 _premiumIndex) public view virtual returns (
    uint256 amount_,
    uint256 dueAt_,
    uint256 paidAt_,
    address paidBy_
  );


  /**
   * @dev Get accumulated commission balances.
   *
   * Note that these balances do not include amounts that have already been paid out (see `payCommissions()`).
   *
   * @return brokerCommissionBalance_ Currently accumulated broker commission.
   * @return assetManagerCommissionBalance_ Currently accumulated asset manager commission.
   * @return naymsCommissionBalance_ Currently accumulated Nayms commission.
   */
  function getCommissionBalances() public view virtual returns (
    uint256 brokerCommissionBalance_,
    uint256 assetManagerCommissionBalance_,
    uint256 naymsCommissionBalance_
  );

  /**
   * @dev Get claim info.
   *
   * @return amount_ Amount the claim is for.
   * @return tranchIndex_ Tranch the claim is against.
   * @return approved_ Whether the claim has been approved.
   * @return declined_ Whether the claim has been declined.
   * @return paid_ Whether the claim has been paid out.
   */
  function getClaimInfo (uint256 _claimIndex) public view virtual returns (
    uint256 amount_,
    uint256 tranchIndex_,
    bool approved_,
    bool declined_,
    bool paid_
  );

  /**
   * @dev Get the max. no. of premium payments possible based on the policy dates.
   *
   * @return Max. no. of premium payments possible.
   */
  function calculateMaxNumOfPremiums() public view virtual returns (uint256);
  /**
   * @dev Get whether the initiation date has passed.
   *
   * @return true if so, false otherwise.
   */
  function initiationDateHasPassed () public view virtual returns (bool);
  /**
   * @dev Get whether the start date has passed.
   *
   * @return true if so, false otherwise.
   */
  function startDateHasPassed () public view virtual returns (bool);
  /**
   * @dev Get whether the maturation date has passed.
   *
   * @return true if so, false otherwise.
   */
  function maturationDateHasPassed () public view virtual returns (bool);

  /**
   * @dev Heartbeat: Ensure the policy and tranch states are up-to-date.
   */
  function checkAndUpdateState () public virtual;

  // events

  /**
   * @dev Emitted when a new tranch has been created.
   * @param token The tranch token address.
   * @param initialBalanceHolder For testing purpses. Ignore.
   * @param index The tranch index.
   */
  event CreateTranch(
    address indexed token,
    address indexed initialBalanceHolder,
    uint256 index
  );
}
