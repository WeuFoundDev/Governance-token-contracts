pragma solidity ^0.8.16;

interface IBurning
{
    function initialize(uint,address,address,address)external;
    function InceaseMaxSupply(uint)external;
}
