// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import {ERC20} from  "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {console} from "forge-std/Test.sol";

contract MyToken is ERC20 {
    address public owner;
    uint256 public minimumDeposit = 1 ether;

    constructor(address _admin) ERC20("Rohit","RHT") {
        owner = _admin;
    }

    function changeAdmin(address newAdmin) external {
        require(msg.sender == owner, "Only admin can change the admin");
        console.logAddress(msg.sender);
        owner = newAdmin;
    }

    function mint(address to, uint amount) public {
        // console.logUint(amount);
        // console.logAddress(to);
        // console.logString("Hey there D");
        _mint(to,amount);
    }

    function deposit() public payable {
        require(msg.value >= minimumDeposit, "Deposit is below minimum");
    }

    function test() public payable {
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // function getOwner() public view returns address {
    //     return address(this).owner;
    // }
}