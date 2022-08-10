// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MlmEIP712 is EIP712 {
    using ECDSA for bytes32;

    struct Message {
        string name;
        address from;           // Externally-owned account (EOA) making the request.
        uint256 value;
        uint256 salt;
        bytes signature;
    }

    bytes32 private constant message_HASH = keccak256("Message(string name,address from,uint256 value,uint256 salt)");
   
    constructor() EIP712("MlmEIP712", "0.0.1") {}   

    /** @notice Function to verify address according to the hash
    *   @param req Struct object
        @return Function returns true if address is correct
    */
    function verify(Message calldata req) external view returns(bool) {
        bytes32 hash = _hashData(req);
        return (ECDSA.recover(hash, req.signature) == msg.sender);
    }

    /** @notice Function to get hash
    *   @param req Struct object
        @return Function returns hash
    */
    function _hashData(Message calldata req) private view returns(bytes32) {
        bytes32 hash = _hashTypedDataV4(keccak256(abi.encode(
            message_HASH,
            keccak256(bytes(req.name)),
            req.from,
            req.value,
            req.salt
        )));
        return hash;
    }
}