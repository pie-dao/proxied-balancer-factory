pragma solidity ^0.6.2;

import "./PBPoolOverrides.sol";
import "./interfaces/IBFactory.sol";
import "./interfaces/IBPool.sol";
import "@pie-dao/proxy/contracts/PProxyOverrideablePausable.sol";


contract PProxiedBalancerFactory {

    // Balancer factory storage
    mapping(address=>bool) private _isBPool;
    address private _blabs;


    address public template;
    address public overrides;

    constructor(address _overrides, address _bFactory) public {
        // Create new template pool using delegatecall to properly setup the constructor args
        bytes memory result;
        (, result) = _bFactory.delegatecall(abi.encodeWithSignature("newBPool()"));
        template = abi.decode(result, (address));
        overrides = _overrides;
    }

    function newProxiedPool(string calldata _name, string calldata _symbol) external {
        // DEPLOY Proxy contract
        PProxyOverrideablePausable proxy = new PProxyOverrideablePausable();
        // Set implementation to proxy contract
        proxy.setImplementation(template);
        // Set Overrides to balancer pool overrides
        proxy.setOverrides(overrides);
        // Set token name and symbol
        PBPoolOverrides(address(proxy)).initOverrides(_name, _symbol);
        // Set proxy owner
        proxy.setProxyOwner(msg.sender);
        // Set controller
        IBPool(address(proxy)).setController(msg.sender);
    }

}