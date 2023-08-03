// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Iint.sol";
import "./Minting.sol";
import "./IMinting.sol";
import "./IGlipVault.sol";
contract TimechainProtocol is ReentrancyGuard{
    // Define the structure for the protocol's Burning pool
    struct BurningPool {
        uint256 totalInputs;
        uint256 timeChainsLeft;
        mapping(uint=>mapping(uint=>uint)) slashingPercentage;//slashingpercent[number of investment][Amount]=slashpercent
        mapping(uint => uint)amountStaked;//Investment number-->amount staked
        address Mintingaddress;
        uint256 noOfinvestments;
        address usdUsed;
        uint256 startingBlock;
        uint256 totalslashedAmount;
    }

    // Mapping to store the protocol's Burning pool data
    mapping(address => BurningPool) public BurningPools;

    // GLIPs vault to hold the slashed INT
    // mapping(address => uint256) public glipsVaultAmount;

    address public stableCoin1;
    address public stableCoin2;
    address public stableCoin3;
    address public glipsVault;
    Iint public intToken;
    address public owner;
    address public WeuFoundation;
    constructor(address _stableCoin1,address _stableCoin2,address _stableCoin3,address _intToken,address weuFoundation,address _glipsVault) {
        stableCoin1 = _stableCoin1;
        stableCoin2=_stableCoin2;
        stableCoin3=_stableCoin3;

        intToken=Iint(_intToken);
        WeuFoundation= weuFoundation;
        glipsVault =_glipsVault;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    // Initialize the protocol's Burning pool with initial values
    function initializeBurningPool(address _protocolAddress,address usdUsed,uint _totalamount) external nonReentrant{
        require(_protocolAddress!=address(0),"The address cannot be equal to zero address");
        require(usdUsed != address(0),"the address cannot be equal to zero address");
        require(_totalamount != 0,"the given amount cannot be equal to zero ");
        require(BurningPools[_protocolAddress].totalInputs == 0, "Burning pool already initialized");
        require(BurningPools[_protocolAddress].noOfinvestments == 0,"The pool is already initialized");
        require(usdUsed == stableCoin1 || usdUsed == stableCoin2 || usdUsed ==stableCoin3 ,"The tokem used should be any one of them");
        BurningPools[_protocolAddress].totalInputs=_totalamount;
        BurningPools[_protocolAddress].timeChainsLeft=50;
        BurningPools[_protocolAddress].slashingPercentage[1][_totalamount]=2;
        BurningPools[_protocolAddress].noOfinvestments=1;
        BurningPools[_protocolAddress].amountStaked[1]=_totalamount;
        BurningPools[_protocolAddress].usdUsed=usdUsed;
        BurningPools[_protocolAddress].startingBlock = block.timestamp;
        Minting minting=new Minting();
        address contaddress=address(minting);
        IMinting(minting).initialize(usdUsed, WeuFoundation, address(intToken), _protocolAddress);
        BurningPools[_protocolAddress].Mintingaddress=contaddress;
        //transfer the usd to this account,before that he need to give the approval for this contract
        IERC20(usdUsed).transferFrom(msg.sender,address(this),_totalamount);

    }

    // Function to add new inputs to the Burning pool
    function addInputsToBurningPool(address _protocolAddress,uint _totalamount) external nonReentrant{
        require(_protocolAddress!=address(0),"The address cannot be equal to zero address");
        require(_totalamount != 0,"the given amount cannot be equal to zero ");
        BurningPool storage pool = BurningPools[_protocolAddress];
        require(pool.noOfinvestments != 0,"The no of investments cannot be equal to zero ");
        require(pool.Mintingaddress != address(0),"The pool Haven't initialized");
        // Calculate the slashing percentage for the new supply of INT
        uint256 slashingPercentage = 100 / pool.timeChainsLeft;

        // Update the Burning pool data with the new inputs and slashing percentage
        pool.totalInputs += _totalamount;
        pool.noOfinvestments +=1;
        pool.amountStaked[pool.noOfinvestments]=_totalamount;
        pool.slashingPercentage[pool.noOfinvestments][_totalamount]=slashingPercentage;
        IMinting(pool.Mintingaddress).InceaseMaxSupply(_totalamount);
        IERC20(pool.usdUsed).transferFrom(msg.sender,address(this),_totalamount);
        
    }

    // Function to slash the INT tokens based on the current timechain
    function slashTokens(address _protocolAddress) external nonReentrant{
        require(_protocolAddress!=address(0),"The address cannot be equal to zero address");
        BurningPool storage pool = BurningPools[_protocolAddress];
        require(pool.timeChainsLeft > 0,"The Timechains needs to be greater than 0");
        uint completedTimeChains= (block.timestamp - pool.startingBlock)/7 days;
        uint FinalTimeChainLeft=completedTimeChains-(50-pool.timeChainsLeft);
        uint256 slashedAmount;
        for(uint i= 0 ;i<=pool.noOfinvestments;i++)
        {
            uint amountstaked=pool.amountStaked[i+1];
             // Calculate the slashed amount for this period
            slashedAmount += (amountstaked * (pool.slashingPercentage[i+1][amountstaked]* completedTimeChains)) / 100;
            
        }
        // Update the Burning pool's total inputs after slashing
        pool.totalslashedAmount += slashedAmount;
         // Add the slashed amount to the GLIPs vault
        // glipsVaultAmount[msg.sender] += slashedAmount;
        IERC20(pool.usdUsed).approve(glipsVault,slashedAmount);
        IGlipVault(glipsVault).ReceiveAmount(_protocolAddress,slashedAmount,pool.usdUsed);
        // Decrease the number of timechains left
        pool.timeChainsLeft -= completedTimeChains;
        //send the amount to the glipsVault
        IERC20(pool.usdUsed).transfer(glipsVault,slashedAmount);
        
    }

    // Function to get the balance of INT available to spend at the start of the current timechain
    function getBalance(address _protocolAddress) external view returns (uint256) {
        require(_protocolAddress!=address(0),"The address cannot be equal to zero address");
        BurningPool storage pool = BurningPools[_protocolAddress];
        return pool.totalInputs - pool.totalslashedAmount;
    }
     

    function burnandClaim(address _protocol,uint256 amount) external nonReentrant  {
        require(amount!=0,"The address cannot be equal to zero address");
        require(intToken.balanceOf(msg.sender)>= amount,"Not Sufficient Amount in your wallet");
        require(IERC20(stableCoin1).balanceOf(address(this))>=amount || IERC20(stableCoin2).balanceOf(address(this))>=amount || IERC20(stableCoin3).balanceOf(address(this))>=amount );
        BurningPool storage pool = BurningPools[_protocolAddress];
        require((block.timestamp - pool.startingBlock) >= 7 days,"The timechain had till not completed");
        address currentStableCoin = findGreatest(stableCoin1, stableCoin2, stableCoin3);
        intToken.transferFrom(msg.sender,address(this),amount);
        intToken.burn(amount);
        IERC20(currentStableCoin).transfer(msg.sender,amount);
    }

    function findGreatest(address _stableCoin1,address _stableCoin2,address _stableCoin3) public view  returns (address) {
        // Using if-else statements
        address greatestCoin;

        if ( IERC20(_stableCoin1).balanceOf(address(this))>= IERC20(_stableCoin2).balanceOf(address(this)) && IERC20(_stableCoin1).balanceOf(address(this)) >= IERC20(_stableCoin3).balanceOf(address(this)) ) {
            greatestCoin = _stableCoin1;
        } else if (IERC20(_stableCoin2).balanceOf(address(this)) >= IERC20(_stableCoin1).balanceOf(address(this)) && IERC20(_stableCoin2).balanceOf(address(this)) >= IERC20(_stableCoin3).balanceOf(address(this))) {
            greatestCoin = _stableCoin2;
        } else{
            greatestCoin = _stableCoin3;
        } 

        return greatestCoin;
    }
}
