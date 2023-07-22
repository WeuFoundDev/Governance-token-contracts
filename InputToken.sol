// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract INPUT is ERC20 {
    constructor() ER20("INPUT Token", "INT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
