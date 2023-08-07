pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract INT is ERC20 {
    address public weuFoundation;
    address public BurningAddress;
    address public Owner;
    address public MintingAddress;

    constructor() ERC20("INT Token", "INPUT") {
        Owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "Only WEU Foundation can perform this action");
        _;
    }
    modifier onlyBurning(){
        require(msg.sender == BurningAddress,"Only burning address can perform this action");
        _;
    }
    modifier onlyMinting()
    {
        require(msg.sender == MintingAddress,"Only Minting address can perform this action");
        _;
    }

    function mint(address account, uint256 amount) external onlyMinting {
        require(account != address(0),"The account address should not be equal to zero address");
        _mint(account, amount);
    }

    function ChangeWeuFoundationaddress(address _weuFoundation)external  onlyOwner{
        require(_weuFoundation != address(0),"The Weu foundation address should not be equal to zero address");
        weuFoundation = _weuFoundation;
    }

    function changeBurningAddress(address _burningAddress)external onlyOwner{
         require(_burningAddress != address(0),"The Burning address should not be equal to zero address");
        BurningAddress = _burningAddress;
    }
    function burn(uint256 amount) external onlyBurning {
        _burn(msg.sender, amount);
    }

    function transfer(address to,uint256 value)public  override virtual  returns(bool)
    {
        require(msg.sender == weuFoundation,"the caller needs to be from WeuFoundation");
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address _from,address _to,uint256 value)public  override virtual  returns(bool)
    {
        require(msg.sender == weuFoundation || msg.sender == BurningAddress,"the caller needs to be from WeuFoundation or the burning Contract");
        address spender = _msgSender();
        _spendAllowance(_from, spender, value);
        _transfer(_from, _to, value);
        return true;
    }

    function approve(address spender,uint256 value)public  override virtual  returns(bool)
    {
        require(msg.sender == weuFoundation || spender == BurningAddress,"the caller needs to be from WeuFoundation or the to address needs to be the burning address");
         address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

}
