// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MlmToken is ERC20 {

    constructor() ERC20("MlmToken", "MLM") { }

    /** @notice Function to mint tokens
    *   @param _to Address to assigning tokens
    *   @param _value Amount of tokens
    */
    function mint(address _to, uint256 _value) public {
        _mint(_to, _value);
    }

     /** @notice Function to burn tokens
    *   @param _from Address for destroying from it tokens
    *   @param _amount Amount of tokens
    */
    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
    }

}