pragma solidity ^0.6.2;

interface IBPool {
    function setController(address _controller) external;
    function getController() external view returns(address);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
}