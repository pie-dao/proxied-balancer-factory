pragma solidity ^0.6.2;

import "@pie-dao/proxy/contracts/PProxyStorage.sol";

contract PBPoolOverrides is PProxyStorage {

    bytes32 constant NAME_SLOT = keccak256(abi.encodePacked("NAME_SLOT"));
    bytes32 constant SYMBOL_SLOT = keccak256(abi.encodePacked("SYMBOL_SLOT"));

    // We recreate the storage layout of Balancer Bronze to be able to set the controller and factoryc
    bytes32 s1;
    bytes32 s2;
    bytes32 s3;
    bytes32 s4;
    bytes32 s5;
    uint8 decimals;
    bool mutex;
    address factory;
    address controller;


    function doesOverride(bytes4 _selector) public view returns (bool) {
        if(
            _selector == this.name.selector ||
            _selector == this.symbol.selector ||
            _selector == this.initOverrides.selector ||
            _selector == this.getFactory.selector 
        ) {
            return true;
        }

        return false;
    }

    function initOverrides(string memory _name, string memory _symbol) public {
        require(storageRead(NAME_SLOT) == bytes32(0), "PBPoolOverrides.initOverrides: Already initialised");
        setString(NAME_SLOT, _name);
        setString(SYMBOL_SLOT, _symbol);
        factory = msg.sender;
        controller = msg.sender;
    }

    function getFactory() external view returns(address) {
        return(factory);
    }

    function name() external view returns(string memory) {
        return(readString(NAME_SLOT));
    }

    function symbol() external view returns(string memory) {
        return(readString(SYMBOL_SLOT));
    }
}