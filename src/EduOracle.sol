// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDIAOracleV2 {
    function getValue(string memory) external view returns (uint128, uint128);
}

contract EduOracle {
    IDIAOracleV2 internal priceFeed;
    string public key; // DIA 오라클에서 필요한 데이터 키

    // 생성자를 사용하여 오라클 주소와 키를 설정
    constructor(address oracleAddress, string memory _key) {
        priceFeed = IDIAOracleV2(oracleAddress);
        key = _key;
    }

    /**
     * Returns the latest price
     */
    function peek() public view returns (bytes32, bool) {
        (uint128 price, uint128 timeStamp) = priceFeed.getValue(key);

        // 타임스탬프가 너무 오래된 경우 에러 처리
        require(block.timestamp - timeStamp < 300, "EduOracle/timestamp-too-old");

        if (price == 0) {
            return (0, false);
        }
        return (bytes32(uint256(price) * (10 ** 10)), true);
    }

    /**
     * 가격 데이터가 최신 상태인지 확인하는 함수
     */
    function isPriceFresh(uint128 maxTimePassed) public view returns (bool) {
        (, uint128 timeStamp) = priceFeed.getValue(key);
        return (block.timestamp - timeStamp < maxTimePassed);
    }
}
