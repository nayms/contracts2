pragma solidity >=0.5.8;

interface IPolicyMutations {
  function makeClaim (uint256 _index, address _clientManagerEntity, uint256 _amount) external;
  function approveClaim (uint256 _claimIndex) external;
  function payClaims() external;
}
