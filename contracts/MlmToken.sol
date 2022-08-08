// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MlmToken is ERC20 {

    address public admin;
    
    constructor() ERC20("MlmToken", "MLM") {
        _mint(msg.sender, 100000000 * (10 ** 18));
        admin = msg.sender;
    }

    /** @notice Function to mint tokens
    *   @param _to Address to assigning tokens
    *   @param _amount Amount of tokens
    *   @return Boolean value that '_mint' function was executed correctly
    */
    function mint(address _to, uint256 _amount) external returns(bool) {
        require(msg.sender == admin, "Incorrect address");
        _mint(_to, _amount);
        return true;
    }

}