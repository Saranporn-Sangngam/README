// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract CommitReveal {

  uint8 public max = 100; // กำหนดค่าสูงสุดในการคำนวณสุ่ม ซึ่งจะใช้ในการสุ่มค่า random

  // โครงสร้าง Commit ที่เก็บข้อมูลการ commit ของผู้เล่น
  struct Commit {
    bytes32 commit; // hash ที่ commit
    uint64 block;   // หมายเลขบล็อกที่ทำการ commit
    bool revealed;  
  }

  
  mapping (address => Commit) public commits;

  // ฟังก์ชัน commit รับค่า dataHash เพื่อบันทึกข้อมูล commit ของผู้เล่น
  function commit(bytes32 dataHash) public {
    commits[msg.sender].commit = dataHash;  // เก็บค่า hash ที่ commit
    commits[msg.sender].block = uint64(block.number);  // เก็บหมายเลขบล็อกที่ commit
    commits[msg.sender].revealed = false;  // ตั้งค่าสถานะ revealed เป็น false
    emit CommitHash(msg.sender, commits[msg.sender].commit, commits[msg.sender].block);  // Emit event แจ้งการ commit
  }

  event CommitHash(address sender, bytes32 dataHash, uint64 block);  // Event ที่แจ้งการ commit ของผู้เล่น

  // ฟังก์ชัน reveal เปิดเผยข้อมูลที่ commit ก่อนหน้า
  function reveal(bytes32 revealHash) public {
    // ตรวจสอบว่าไม่ได้เปิดเผยข้อมูลไปแล้ว
    require(commits[msg.sender].revealed == false, "CommitReveal::reveal: Already revealed");
    commits[msg.sender].revealed = true;  // ตั้งค่าสถานะ revealed เป็น true

    // ตรวจสอบว่า revealHash ที่เปิดเผยตรงกับค่า commit ที่เก็บไว้
    require(getHash(revealHash) == commits[msg.sender].commit, "CommitReveal::reveal: Revealed hash does not match commit");

    // ตรวจสอบว่า การเปิดเผยเกิดขึ้นในบล็อกที่ต่างจากบล็อกที่ commit
    require(uint64(block.number) > commits[msg.sender].block, "CommitReveal::reveal: Reveal and commit happened on the same block");

    // ตรวจสอบว่าเปิดเผยไม่เกิน 250 บล็อกจากการ commit
    require(uint64(block.number) <= commits[msg.sender].block + 250, "CommitReveal::reveal: Revealed too late");

    // ใช้ blockhash ของบล็อกที่ commit ข้อมูลเพื่อคำนวณ random number
    bytes32 blockHash = blockhash(commits[msg.sender].block);
    
    // ใช้ revealHash และ blockHash ในการคำนวณ random number เพื่อให้สุ่มได้โดยที่ไม่นักขุดไม่สามารถเดาได้
    uint random = uint(keccak256(abi.encodePacked(blockHash, revealHash))) % max;
    
    emit RevealHash(msg.sender, revealHash, random);  // Emit event แจ้งการเปิดเผยข้อมูลและค่า random ที่สุ่มได้
  }

  event RevealHash(address sender, bytes32 revealHash, uint random);  // Event ที่แจ้งการเปิดเผยข้อมูล

  // ฟังก์ชันนี้ใช้ในการคำนวณค่า hash ของข้อมูลที่ส่งมา
  function getHash(bytes32 data) public pure returns(bytes32){
    return keccak256(abi.encodePacked(data));  // คำนวณและส่งคืนค่า hash
  }
}
