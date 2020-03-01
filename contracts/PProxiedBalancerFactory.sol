pragma solidity ^0.6.2;

import "./interfaces/IBFactory.sol";
import "./interfaces/IBPool.sol";
import "./PBPoolOverrides.sol";
import "@pie-dao/proxy/contracts/PProxyOverrideablePausable.sol";


contract PProxiedBalancerFactory {

    address public template;
    address public overrides;

    constructor(address _bFactory, address _overrides) public {
        template = IBFactory(_bFactory).newBPool();
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