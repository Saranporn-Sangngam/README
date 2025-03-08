// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract RPS {
    uint public numPlayer = 0; // จำนวนผู้เล่นที่เข้าร่วมเกม
    uint public reward = 0;     // จำนวนรางวัล (Ether) ที่ผู้เล่นจะได้รับ
    mapping (address => uint) public player_choice; // เก็บการเลือกของผู้เล่น: 0 - Rock, 1 - Paper , 2 - Scissors
    mapping(address => bool) public player_not_played; // ตรวจสอบว่าผู้เล่นยังไม่ได้เลือกหรือยัง
    address[] public players; // รายชื่อผู้เล่น

    // ฟังก์ชันตรวจสอบว่า address ที่จะเข้าร่วมเกมมีสิทธิ์หรือไม่
    address[4] public allowedPlayers = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, // player 1
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, // player 2
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, // player 3
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB  // player 4
    ];

    uint public numInput = 0; // จำนวนผู้เล่นที่ทำการเลือกแล้ว

    // ฟังก์ชันเพิ่มผู้เล่นเข้าเกม
    function addPlayer() public payable {
        require(numPlayer < 2, "Maximum players reached!"); // ต้องมีผู้เล่นไม่เกิน 2 คนในเกม
        require(isAllowed(msg.sender), "You are not allowed to play!"); // ตรวจสอบว่า address สามารถเล่นได้หรือไม่
        if (numPlayer > 0) {
            require(msg.sender != players[0], "You cannot play against yourself!"); // ผู้เล่นใหม่ต้องไม่เป็นตัวเอง
        }
        require(msg.value == 1 ether, "You need to send exactly 1 ether to play"); // ต้องส่ง Ether มาที่ contract เท่ากับ 1
        reward += msg.value; // เพิ่ม Ether ที่ส่งมาในรางวัล
        player_not_played[msg.sender] = true; // ผู้เล่นยังไม่ได้เลือก
        players.push(msg.sender); // เพิ่มผู้เล่นเข้าไปในลิสต์
        numPlayer++; // เพิ่มจำนวนผู้เล่น
    }

    // ฟังก์ชันตรวจสอบว่า address ที่เข้าร่วมเกมมีสิทธิ์หรือไม่
    function isAllowed(address player) public view returns(bool) {
        for (uint i = 0; i < allowedPlayers.length; i++) {
            if (allowedPlayers[i] == player) {
                return true; // หาก address ตรงกับที่อนุญาต จะอนุญาตให้เล่น
            }
        }
        return false; // หากไม่ตรงกับที่อนุญาต จะไม่ให้เล่น
    }

    // ฟังก์ชันให้ผู้เล่นเลือกเกม (Rock, Paper, Scissors)
    function input(uint choice) public  {
        require(numPlayer == 2, "There must be exactly 2 players"); // ต้องมีผู้เล่น 2 คนในเกม
        require(player_not_played[msg.sender], "You have already made your choice!"); // ตรวจสอบว่าผู้เล่นยังไม่ได้เลือก
        require(choice == 0 || choice == 1 || choice == 2, "Invalid choice! Choose 0, 1, or 2"); // ตรวจสอบว่าเลือกค่า 0, 1 หรือ 2 (Rock, Paper, Scissors)
        player_choice[msg.sender] = choice; // เก็บการเลือกของผู้เล่น
        player_not_played[msg.sender] = false; // ตั้งค่าสถานะว่าผู้เล่นได้เลือกแล้ว
        numInput++; // เพิ่มจำนวนการเลือก
        if (numInput == 2) { // เมื่อผู้เล่นทั้งสองคนเลือกแล้ว
            _checkWinnerAndPay(); // ตรวจสอบผู้ชนะและจ่ายรางวัล
        }
    }

    // ฟังก์ชันตรวจสอบผู้ชนะและทำการจ่ายรางวัล
    function _checkWinnerAndPay() private {
        uint p0Choice = player_choice[players[0]]; // ตัวเลือกของผู้เล่นที่ 0
        uint p1Choice = player_choice[players[1]]; // ตัวเลือกของผู้เล่นที่ 1
        address payable account0 = payable(players[0]); // ที่อยู่ของผู้เล่นที่ 0
        address payable account1 = payable(players[1]); // ที่อยู่ของผู้เล่นที่ 1

        // กฎ RPS (Rock beats Scissors, Scissors beats Paper, Paper beats Rock)
        if ((p0Choice + 1) % 3 == p1Choice) { // ถ้าผู้เล่นที่ 0 ชนะ
            account1.transfer(reward); // จ่ายรางวัลให้ผู้เล่นที่ 1
        }
        else if ((p1Choice + 1) % 3 == p0Choice) { // ถ้าผู้เล่นที่ 1 ชนะ
            account0.transfer(reward); // จ่ายรางวัลให้ผู้เล่นที่ 0
        }
        else { // ถ้าผลเป็นเสมอ
            account0.transfer(reward / 2); // จ่ายครึ่งหนึ่งของรางวัลให้ผู้เล่นที่ 0
            account1.transfer(reward / 2); // จ่ายครึ่งหนึ่งของรางวัลให้ผู้เล่นที่ 1
        }
    }
}
