// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MockDIAOracle {
    mapping(string => uint256) public values;
    address public oracleUpdater;

    event OracleUpdate(string key, uint128 value, uint128 timestamp);
    event UpdaterAddressChange(address newUpdater);

    constructor() {
        oracleUpdater = msg.sender;
    }

    /**
     * Updates the value and timestamp for a given key.
     * Only the oracleUpdater can call this function.
     */
    function setValue(
        string memory key,
        uint128 value,
        uint128 timestamp
    ) public {
        require(
            msg.sender == oracleUpdater,
            "Only oracleUpdater can set values"
        );
        uint256 cValue = (uint256(value) << 128) + timestamp;
        values[key] = cValue;
        emit OracleUpdate(key, value, timestamp);
    }

    /**
     * Returns the latest value and timestamp for a given key.
     */
    function getValue(
        string memory key
    ) external view returns (uint128, uint128) {
        uint256 cValue = values[key];
        uint128 timestamp = uint128(cValue % 2 ** 128);
        uint128 value = uint128(cValue >> 128);
        return (value, timestamp);
    }

    /**
     * Updates the address of the oracle updater.
     * Only the current oracleUpdater can call this function.
     */
    function updateOracleUpdaterAddress(
        address newOracleUpdaterAddress
    ) public {
        require(
            msg.sender == oracleUpdater,
            "Only oracleUpdater can update updater address"
        );
        oracleUpdater = newOracleUpdaterAddress;
        emit UpdaterAddressChange(newOracleUpdaterAddress);
    }
}
