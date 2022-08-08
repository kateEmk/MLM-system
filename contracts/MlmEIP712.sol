// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MlmEIP712 is EIP712 {
    using ECDSA for bytes32;

    struct Message {
        string name;
        address from;
        address to;
        uint256 amount;
        string contents;
    }

    struct Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }

    bytes32 private constant hash = keccak256("Message(address from, address to, string contents)");

    constructor() EIP712("MlmEIP712", "0.0.1") {}

    function verify() public view returns(bool) {

    }

    function execute() public payable returns(bool, bytes memory) {

    }

}


// const domain = {
//     name: 'Ether Mail',
//     version: '1',
//     chainId: 1,
//     verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC'
// };