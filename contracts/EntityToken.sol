pragma solidity >=0.6.7;

import './base/IMintableToken.sol';
import './base/IEntityTokensFacet.sol';

/**
 * @dev An Entity token.
 */
contract EntityToken is IMintableToken {
  IEntityTokensFacet public impl;
  uint256 public index;

  constructor (address _impl) public {
    impl = IEntityTokensFacet(_impl);
  }

  // ERC-20 queries //

  function name() public view override returns (string memory) {
    return impl.tknName();
  }

  function symbol() public view override returns (string memory) {
    return impl.tknSymbol();
  }

  function totalSupply() public view override returns (uint256) {
    return impl.tknTotalSupply();
  }

  function balanceOf(address owner) public view override returns (uint256) {
    return impl.tknBalanceOf(owner);
  }

  function decimals() public view override returns (uint8) {
    return 18;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return impl.tknAllowance(spender, owner);
  }


  // Mutations //

  function mint(uint256 _amount) public override {
    impl.tknMint(msg.sender, _amount);
    emit Mint(msg.sender, _amount);
  }

  function approve(address spender, uint256 value) public override returns (bool) {
    impl.tknApprove(spender, msg.sender, value);
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    impl.tknTransfer(msg.sender, msg.sender, to, value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public override returns (bool) {
    impl.tknTransfer(msg.sender, from, to, value);
    emit Transfer(from, to, value);
    return true;
  }
}
