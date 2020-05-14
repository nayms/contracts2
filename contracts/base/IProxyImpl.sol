pragma solidity >=0.6.7;

/**
 * @dev Proxy implementations.
 */
interface IProxyImpl {
  /**
   * @dev Get version of this implementation.
   *
   * @return The version string
   */
  function getImplementationVersion() external pure returns (string memory);
}
