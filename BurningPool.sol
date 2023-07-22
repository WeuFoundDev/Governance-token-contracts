// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./INT.sol";

contract BurningPool is ReentrancyGuard {
    using SafeMath for uint8;

    INT public intToken;
    mapping(address => uint256) public usdBalance;

    constructor(address _intToken) {
        intToken = INT(_intToken);
    }

    function burnAndClaimUSD(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        require(intToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        intToken.burn(amount);
        uint256 usdAmount = convertInputToUSD(amount);
        usdBalance[msg.sender] = usdBalance[msg.sender].add(usdAmount);
    }

    function convertInputToUSD(uint256 amount) internal pure returns (uint256) {
        // Convert INT to USD based on the fixed conversion rate of 1 INT = 1 USD
        return amount;
    }
}
