//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma abicoder v2;

import "../interfaces/ILayerZeroEndpoint.sol";
import "../interfaces/ILayerZeroReceiver.sol";
import "hardhat/console.sol";

contract LayerZeroDemo1 is ILayerZeroReceiver {

    // events
    event ReceiveMsg(
        uint16 _srcChainId,
        address _from,
        uint16 _count,
        bytes _payload
    );

    // instance variables
    ILayerZeroEndpoint public endpoint; // where message will be received from
    uint16 public messageCount;
    byes public message;

    // constructor
    constructor(address _endpoint) {
        endpoint = ILayerZeroEndpoint(_endpoint);
    }

    // methods
    function sendMsg(
        uint16 _dstChainId,
        bytes calldata _destination,
        bytes calldata payload,
    ) public payable {
        endpoint.send{value: msg.value}(
            _dstChainId,
            _destination,
            payload,
            payable(msg.sender),
            address(this),
            bytes("")
        );
    }

    function lzReceive(
        uint16 _srcChainId,
        bytes memory _from,
        uint64,
        bytes memory _payload
    ) external override {
        require(msg.sender == address(endpoint));
        address from;
        assembly {
            from := mload(add(_from, 20))
        }
        if (
            keccak256(abi.encodePacked((_payload))) == 
            keccak256(abi.encodePacked((bytes10("ff"))))
        ) {
            endpoint.receivePayLoad(
                1,
                bytes(""),
                address(0x0),
                1,
                1,
                bytes("")
            );
        }

        // update instance variables
        message = _payload
        messageCount += 1
        emit ReceiveMsg(_srcChainId, from, messageCount, message)
    }

    function estimateFees( // estimates fees for the message
        uint16 _dstChainId,
        address _userApplication,
        bytes calldata _payload,
        bool _payInZRO,
        bytes calldata _adapterParams
    ) external view returns (uint256 nativeFee, uint256 zroFee) {
        return endpoint.estimateFees(
            _dstChainId,
            _userApplication,
            _payload,
            _payInZRO,
            _adapterParams
        );
    }
}