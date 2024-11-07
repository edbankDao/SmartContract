// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/MockDiaOracle.sol";
import "../src/EduOracle.sol";

contract EduOracleTest is Test {
    MockDIAOracle mockOracle;
    EduOracle eduOracle;

    // 테스트 데이터 키와 초기값
    string constant key = "BTC/USD";
    uint128 constant initialValue = 1000 * 10 ** 8; // 가상의 가격 데이터 (ex: 1000.0 in 8 decimals)
    // uint128 constant initialTimestamp = 1714917922; // 임의의 타임스탬프
    uint128 initialTimestamp = uint128(block.timestamp); // 현재 블록 타임스탬프 사용

    function setUp() public {
        // MockDIAOracle와 EduOracle 배포
        mockOracle = new MockDIAOracle();
        eduOracle = new EduOracle(address(mockOracle), key);

        // MockDIAOracle에 초기 값 설정
        mockOracle.setValue(key, initialValue, initialTimestamp);
    }

    function testPeekReturnsCorrectValue() public {
        // 가격 조회: EduOracle의 peek() 호출
        (bytes32 price, bool isValid) = eduOracle.peek();

        // 예상되는 가격과 상태를 확인
        assertEq(uint256(price), uint256(initialValue) * 10 ** 10);
        assertTrue(isValid);
    }

    function testPriceFreshness() public {
        // 가격 데이터의 유효성 검사 (isPriceFresh 사용)
        bool isFresh = eduOracle.isPriceFresh(300);
        assertTrue(isFresh);
    }

    function testSpotPoke() public {
        // 새로운 가격과 타임스탬프 업데이트
        uint128 newPrice = 2000 * 10 ** 8; // 2000.0
        uint128 newTimestamp = uint128(block.timestamp);

        // MockDIAOracle에 새로운 값 설정
        mockOracle.setValue(key, newPrice, newTimestamp);

        // EduOracle의 peek()로 업데이트된 가격 확인
        (bytes32 updatedPrice, bool isValid) = eduOracle.peek();

        // 예상된 새로운 가격과 상태를 확인
        assertEq(uint256(updatedPrice), uint256(newPrice) * 10 ** 10);
        assertTrue(isValid);
    }
}
