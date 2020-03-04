pragma solidity ^0.6.2;

import "./IBPool.sol";

// Additional methods not present in the Vanilla balancer pools
interface IPBPool is IBPool {
    function getFactory() external view returns(address);
}