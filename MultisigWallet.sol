// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract INT is ERC20, ReentrancyGuard {
    using SafeMath for uint256;

    // Multisig variables
    address public signer1;
    address public signer2;
    address public signer3;

    // Number of required approvals (2 out of 3)
    uint256 public requiredApprovals = 2;

    // Mapping to keep track of signed requests
    mapping(uint256 => mapping(address => bool)) private approvals;

    constructor() ERC20("INT Token", "INT") {
        _mint(msg.sender, 1000000 * 10**decimals());

        // Set the initial signers 
        signer1=address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        signer2=address(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678);
        signer3=address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
    }

    // Function to mint new tokens to a specified account.
    // The minting request requires at least two approvals from signers.
    function mint(address account, uint256 amount) external nonReentrant onlySigner {
        // Generate a unique identifier for this mint request (can be based on amount, account, or any other parameter)
        uint256 requestId = uint256(keccak256(abi.encodePacked(account, amount, block.timestamp)));

        // Ensure the request is not already approved
        require(!isApproved(requestId, msg.sender), "The request is already approved.");

        // Mark the request as approved by the current signer
        approvals[requestId][msg.sender] = true;

        // Check if the required number of approvals is reached
        uint256 approvalCount = 0;
        if (isApproved(requestId, signer1)) approvalCount++;
        if (isApproved(requestId, signer2)) approvalCount++;
        if (isApproved(requestId, signer3)) approvalCount++;

        // If the required number of approvals is reached, mint the tokens
        require(approvalCount >= requiredApprovals, "Insufficient approvals for minting.");

        _mint(account, amount);
    }

    // Modifier to restrict access to only the signers.
    modifier onlySigner() {
        require(msg.sender == signer1 || msg.sender == signer2 || msg.sender == signer3, "Only signers can call this function.");
        _;
    }

    // Check if a request is approved by a specific signer
    function isApproved(uint256 requestId, address signer) private view returns (bool) {
        return approvals[requestId][signer];
    }
}
