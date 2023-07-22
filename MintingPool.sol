// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INT.sol";

contract MintingPool is Ownable {
    using SafeMath for uint256;

    INT public intToken;
    address public verifier;
    uint256 public developerRewardPercentage = 90;
    uint256 public verifierRewardPercentage = 10;

    event Minted(address indexed account, uint256 amount);

    constructor(address _intToken, address _verifier) {
        intToken = INT(_intToken);
        verifier = _verifier;
    }

    function mintByIssueSolvers(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        uint256 totalSupply = intToken.totalSupply();
        uint256 verifierReward = amount.mul(verifierRewardPercentage).div(100);
        uint256 developerReward = amount.sub(verifierReward);

        intToken.mint(msg.sender, developerReward);
        intToken.mint(verifier, verifierReward);

        emit Minted(msg.sender, developerReward);
        emit Minted(verifier, verifierReward);
    }
}
