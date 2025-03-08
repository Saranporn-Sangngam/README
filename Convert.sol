// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Convert {

    // ฟังก์ชันที่ใช้แปลงค่าจำนวน uint256 เป็น bytes32
    function convert(uint256 n) public pure returns (bytes32) {
        return bytes32(n);
    }

    // ฟังก์ชันที่ใช้แฮชข้อมูลที่รับมาเป็น bytes32 ด้วย keccak256
    function getHash(bytes32 data) public pure returns(bytes32){
        return keccak256(abi.encodePacked(data));
    }

    // ฟังก์ชันที่คืนที่อยู่ของ contract นี้
    function getAddress() public view returns (address) {
        return address(this);
    }
}