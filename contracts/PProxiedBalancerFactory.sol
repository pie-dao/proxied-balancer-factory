pragma solidity ^0.6.2;

import "./PBPoolOverrides.sol";
import "./interfaces/IBPool.sol";
import "@pie-dao/proxy/contracts/PProxyOverrideablePausable.sol";


contract PProxiedBalancerFactory {

    mapping(address=>bool) private _isBPool;
    address[] public bPools;


    address public template;
    address public overrides;

    event LOG_NEW_POOL(
        address indexed caller,
        address indexed pool
    );

    constructor(address _overrides, address _template) public {
        // Create new template pool using delegatecall to properly setup the constructor args
        template = _template;
        overrides = _overrides;
    }

    function newProxiedPool(string calldata _name, string calldata _symbol) external returns(address) {
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
        _isBPool[address(proxy)] = true;
        bPools.push(address(proxy));
        emit LOG_NEW_POOL(msg.sender, address(proxy));
        return(address(proxy));
    }

    function isBPool(address b)
        external view returns (bool)
    {
        return _isBPool[b];
    }


}