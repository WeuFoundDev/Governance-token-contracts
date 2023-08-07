pragma solidity ^0.8.16;

import "./Iint.sol";


contract Minting  {
    
    uint public MaxSupply;
    uint public PresentSupply;
    address public BurningAddress;
    mapping(address => uint) public Devamount;
    address public WeuFoundation;
    Iint public intToken;
    address public ProtocolAddress;
    modifier OnlyBurning(){
        require(msg.sender == BurningAddress,"The sender needs to be burning address");
        _;
    }
    modifier OnlyFoundation(){
        require(msg.sender == WeuFoundation,"The sender needs to be WeuFoundation address");
        _;
    }
    constructor(){
        BurningAddress = msg.sender;
    }
    function initialize(uint _supply,address _weuFoundation,address _intToken,address _protocol)external OnlyBurning{
        require(ProtocolAddress == address(0),"The Protocol is already initialized");
        MaxSupply=_supply;
        WeuFoundation=_weuFoundation;
        intToken=Iint(_intToken);
        ProtocolAddress =_protocol;
      }
    function InceaseMaxSupply(uint _supply)external OnlyBurning{
        require(_supply!=0,"The supply cannot be equal to zero ");
         MaxSupply += _supply;
    } 
    function mintSupply(uint _supply,address _dev)external OnlyFoundation  {
        require(_supply !=0 && _dev!=address(0),"The supply amount cannot be equal to zero and _dev address should not be equal to zero address");
        require(MaxSupply >= (PresentSupply+_supply));
         intToken.mint(_dev, _supply);
         PresentSupply += _supply;
    }
    

}
