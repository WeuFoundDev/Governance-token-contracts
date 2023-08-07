pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract GlipsVault{

    mapping(address => uint)public ProtocolAmount;
    address public BurningPool;
    address public  Owner;

    constructor()
    {
        Owner=msg.sender;
    }
    modifier OnlyOwner()
    {
        require(msg.sender == Owner,"The owner needs to be msg.sender");
        _;
    }
    modifier OnlyBurning()
    {
        require(msg.sender == BurningPool,"The caller needs to be the burning contract");
        _;
    }
    function ReceiveAmount(address _protocol,uint _amount,address usdUsed)external OnlyBurning
    {
        require(_protocol != address(0),"The protocol address cannot be equal to address zero");
        require(_amount != 0,"The amount cannot be equal to zero ");
        require(IERC20(usdUsed).allowance(BurningPool,address(this))>= _amount);
        IERC20(usdUsed).transferFrom(BurningPool,address(this),_amount);
        ProtocolAmount[_protocol]=_amount;

    }
    function ChangeBurningContract(address _burningcontract)external OnlyOwner{
        require(_burningcontract != address(0),"The burning contract address cannot be equal to the zero address");
        BurningPool = _burningcontract;
    }
}
