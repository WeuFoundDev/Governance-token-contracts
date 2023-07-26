pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract INT is ERC20 {
    address public weuFoundation;
    address public BurningAddress;
    address public Owner;

    constructor() ERC20("INT Token", "INPUT") {
        Owner = msg.sender;
    }

    modifier onlyWEUFoundation() {
        require(msg.sender == weuFoundation, "Only WEU Foundation can perform this action");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only WEU Foundation can perform this action");
        _;
    }
    modifier onlyBurning(){
        require(msg.sender == BurningAddress,"Only burning address can perform this action");
        _;
    }

    function mint(address account, uint256 amount) external onlyWEUFoundation {
        require(account != address(0),"The account address should not be equal to zero address");
        _mint(account, amount);
    }

    function ChangeWeuFoundationaddress(address _weuFoundation)external  onlyOwner{
        require(_weuFoundation != address(0),"The Weu foundation address should not be equal to zero address");
        weuFoundation = _weuFoundation;
    }

    function changeBurningAddress(address _burningAddress)external onlyBurning{
         require(_burningAddress != address(0),"The Burning address should not be equal to zero address");
        BurningAddress = _burningAddress;
    }
    function burn(uint256 amount) external onlyBurning {
        _burn(msg.sender, amount);
    }

}