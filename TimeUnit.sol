// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0 < 0.9.0;

contract TimeUnit {

  uint256 public startTime;

  // Set the start time when the game starts
  function setStartTime() public {
    startTime = block.timestamp;
  }

  // Get the elapsed time in seconds
  function elapsedSeconds() public view returns (uint256) {
    return (block.timestamp - startTime);
  }

  // Get the elapsed time in minutes
  function elapsedMinutes() public view returns (uint256) {
    return (block.timestamp - startTime) / 1 minutes;
  }
}
