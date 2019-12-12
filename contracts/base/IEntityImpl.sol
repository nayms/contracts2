pragma solidity >=0.5.8;

interface IEntityImpl {
  // basic details

  function getName () external view returns (string memory);
  function setName (string calldata _name) external;

  // policies

  /**
   * Notify that a new Policy has been deployed.
   */
  event NewPolicy(
    address indexed policy,
    address indexed entity,
    address indexed deployer
  );

  function createPolicy(address _impl, string calldata _name) external;
  function getNumPolicies() external view returns (uint256);
  function getPolicy(uint256 _index) external view returns (address);
}
