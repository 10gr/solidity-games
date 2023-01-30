// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract TokenSale is ReentrancyGuard, Ownable {
    IERC20 private token;
    bool public isFrozen;
    uint256 public price;
    address payable private holdingAddress;

    constructor(
        address _token,
        address payable _holdingAddress,
        uint256 _price
    ) {
        token = IERC20(_token);
        holdingAddress = _holdingAddress;
        isFrozen = true;
        price = _price;
    }

    function buy(uint256 amount) public payable nonReentrant {
        require(amount > 0, "Amount cannot be 0.");
        require(msg.value >= amount * price, "Insufficient payment.");
        require(!isFrozen, "Contract is frozen.");

        token.transferFrom(holdingAddress, _msgSender(), amount * 1e18);
        _safeTransfer(holdingAddress, msg.value);
    }

    function setFrozen(bool state) public onlyOwner {
        isFrozen = state;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function _safeTransfer(address payable to, uint256 amount) internal {
        uint256 balance = address(this).balance;
        if (amount > balance) amount = balance;
        Address.sendValue(to, amount);
    }
}
