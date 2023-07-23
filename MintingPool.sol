// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./INT.sol";

contract MintingPool is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    INT public intToken;
    address public verifier;
    uint256 public developerRewardPercentage = 90;
    uint256 public verifierRewardPercentage = 10;
    uint256 public slashingPercentage = 2 * 10 ** 6; // 2% in 6 decimal places
    uint256 public timeChainPeriods = 50;

    event Minted(address indexed account, uint256 amount);

    constructor(address _intToken, address _verifier) {
        intToken = INT(_intToken);
        verifier = _verifier;
    }

    function mintByIssueSolvers(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        require(
            intToken.balanceOf(msg.sender) >= amount,
            "Insufficient balance"
        );

        uint256 totalSupply = intToken.totalSupply();
        uint256 verifierReward = amount.mul(verifierRewardPercentage).div(100);
        uint256 developerReward = amount.sub(verifierReward);

        intToken.mint(msg.sender, developerReward);
        intToken.mint(verifier, verifierReward);

        emit Minted(msg.sender, developerReward);
        emit Minted(verifier, verifierReward);

        // Calculate the slashing amount for the new supply of INT
        uint256 newSupply = totalSupply.add(amount);
        uint256 remainingTimeChainPeriods = timeChainPeriods.sub(
            block.number % timeChainPeriods
        );
        uint256 slashingAmount = slashingPercentage.mul(amount).div(
            remainingTimeChainPeriods
        );

        // Reserve the slashing amount in the GLIPs vault
        intToken.mint(address(this), slashingAmount);
    }

    function updateSlashingPercentage(
        uint256 _newSlashingPercentage
    ) external onlyOwner {
        require(_newSlashingPercentage > 0, "Invalid slashing percentage");
        slashingPercentage = _newSlashingPercentage;
    }

    function updateTimeChainPeriods(
        uint256 _newTimeChainPeriods
    ) external onlyOwner {
        require(_newTimeChainPeriods > 0, "Invalid time chain periods");
        timeChainPeriods = _newTimeChainPeriods;
    }
}
