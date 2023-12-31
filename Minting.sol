// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MintingPool is Ownable {
    using SafeMath for uint256;

    uint256 public timechain = 50;
    uint256 public intToken = 1000000;
    uint256 public slashPercentage = 2 * 10**6; // 2% represented as 2 * 10^6 (6 decimal places)

    // Function to burn and claim INT tokens based on the minting pool algorithm
    function burnAndClaim() external onlyOwner returns (uint256) {
        uint256 newSupply = 2000000; // Example: New inputs added to minting pool

        // Calculate the slashing percentage for the new supply
        uint256 remainingTimechain = timechain.sub(5); // Assuming 5 timechain periods have passed
        uint256 slashingPercentage = calculateSlashingPercentage(remainingTimechain);

        // Calculate the slashing amount for each portion
        uint256 slashingAmountForExisting = intToken.mul(slashPercentage).div(10*8); // Divide by 10*8 due to 6 decimal places
        uint256 slashingAmountForNew = newSupply.mul(slashingPercentage).div(10*8); // Divide by 10*8 due to 6 decimal places

        // Calculate the total slashed amount
        uint256 totalSlashedAmount = slashingAmountForExisting.add(slashingAmountForNew);

        // Update the INT token balance in the minting pool after slashing
        intToken = intToken.sub(totalSlashedAmount);

        // Decrease the timechain period
        timechain--;

        return intToken;
    }

    // Function to calculate the slashing percentage for new supply based on the remaining timechain periods
    function calculateSlashingPercentage(uint256 remainingTimechain) internal pure returns (uint256) {
        return uint256(100 * 10*6).div(remainingTimechain); // Divide by 10*6 to get 6 decimal places
    }
}