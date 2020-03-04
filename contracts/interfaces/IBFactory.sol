pragma solidity ^0.6.2;

interface IBFactory {
    event LOG_NEW_POOL(
        address indexed caller,
        address indexed pool
    );

    function newBPool() external returns (address);
}

