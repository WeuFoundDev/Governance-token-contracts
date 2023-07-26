pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Iint is IERC20
{
    function mint(address,uint)external;
    function burn(address)external;
}
