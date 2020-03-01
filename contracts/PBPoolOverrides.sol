pragma solidity ^0.6.2;

import "@pie-dao/proxy/contracts/PProxyStorage.sol";

contract PBPoolOverrides is PProxyStorage {

    bytes32 constant NAME_SLOT = keccak256(abi.encodePacked("NAME_SLOT"));
    bytes32 constant SYMBOL_SLOT = keccak256(abi.encodePacked("SYMBOL_SLOT"));

    function doesOverride(bytes4 _selector) public view returns (bool) {
        if(
            _selector == this.name.selector ||
            _selector == this.symbol.selector ||
            _selector == this.initOverrides.selector
        ) {
            return true;
        }

        return false;
    }

    function initOverrides(string memory _name, string memory _symbol) public {
        require(storageRead(NAME_SLOT) == bytes32(0), "PBPoolOverrides.initOverrides: Already initialised");
        setString(NAME_SLOT, _name);
        setString(SYMBOL_SLOT, _symbol);
    }

    function name() external view returns(string memory) {
        return(readString(NAME_SLOT));
    }

    function symbol() external view returns(string memory) {
        return(readString(SYMBOL_SLOT));
    }
}