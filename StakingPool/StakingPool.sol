// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingPool is Ownable, ReentrancyGuard {
    IERC20 public intToken;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewardBalance;
    uint256 public totalStaked;

    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Claimed(address indexed account, uint256 amount);

    constructor(address _intToken) {
        intToken = IERC20(_intToken);
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        intToken.transferFrom(msg.sender, address(this), amount);

        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        intToken.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function claim() external nonReentrant {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");

        rewardBalance[msg.sender] = 0; // Reset the reward balance

        // Transfer the rewards to the user
        intToken.transfer(msg.sender, reward);

        emit Claimed(msg.sender, reward);
    }

    function calculateReward(address account) internal view returns (uint256) {
        return 0;
    }

    function getStakedBalance(address account) external view returns (uint256) {
        return stakedBalance[account];
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }
}
