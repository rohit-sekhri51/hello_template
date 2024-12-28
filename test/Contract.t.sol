// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/MyToken.sol";

contract TestCounter is Test {
    MyToken c;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        c = new MyToken(address(this));
    }

    function testExample(uint256 x) public {
        vm.assume(x < 1000);  // Only test if x is less than 1000
        assertEq(x + x, x * 2);
    }

    function testStringLength(uint256 len) public {
        vm.assume(len >= 1 && len <= 20);
        
        string memory testString = generateString(len);
        
        assertEq(bytes(testString).length, len);
    }

     function generateString(uint256 len) internal pure returns (string memory) {
        bytes memory strBytes = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            strBytes[i] = bytes1(uint8(97 + (i % 26)));
        }
        return string(strBytes);
    }

    function testAdmin() public {
        c.changeAdmin(0xE952553833027f08e40ccfB518458E9B9A035d22);
        assertEq(c.owner(),0xE952553833027f08e40ccfB518458E9B9A035d22);
        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.changeAdmin(address(this));
        assertEq(c.owner(),address(this));  
    }

    function testFailAdmin() public {
        c.changeAdmin(0xE952553833027f08e40ccfB518458E9B9A035d22);
        assertEq(c.owner(),0xE952553833027f08e40ccfB518458E9B9A035d22);
        //vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.changeAdmin(address(this));
        assertEq(c.owner(),address(this));  
    }

    function testDeposit() public {
        vm.deal(0xE952553833027f08e40ccfB518458E9B9A035d22, 2 ether);
        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.deposit{value: 2 ether}();
        assertEq(c.getBalance(),2 ether,"2 ether is Bal");
    }

    function testFailDeposit() public {
        vm.deal(0xE952553833027f08e40ccfB518458E9B9A035d22, 2 ether);
        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.deposit{value: 0.5 ether}();
        assertEq(c.getBalance(),2 ether,"2 ether is Bal");
    }

    function test_DealExample() public {
        address account = 0xE952553833027f08e40ccfB518458E9B9A035d22;
        uint256 balance = 10 ether;

        // Set the balance of `account` to `10 ether`
        vm.deal(account, balance);

        // Assert that the balance is set correctly
        assertEq(address(account).balance, balance);
    }

    function testHoax() public {
        hoax(0xE952553833027f08e40ccfB518458E9B9A035d22,100 ether);
        c.test{value: 100 ether}();
        assertEq(c.getBalance(),100 ether,"ok");
    }

    function testMint() public {
        c.mint(address(this), 100);
        assertEq(c.balanceOf(address(this)), 100,"Minting 100 RHT");
        assertEq(c.balanceOf(0xE952553833027f08e40ccfB518458E9B9A035d22), 0,"Minting 0 RHT");

        c.mint(0xE952553833027f08e40ccfB518458E9B9A035d22, 75);
        assertEq(c.balanceOf(0xE952553833027f08e40ccfB518458E9B9A035d22), 75,"Minting 0 RHT");
    }

    function testTransfer() public {
        c.mint(address(this), 100);
        c.transfer(0xE952553833027f08e40ccfB518458E9B9A035d22,15);
        assertEq(c.balanceOf(address(this)), 85,"Transfer 15/100 = 85 RHT tokens");
        assertEq(c.balanceOf(0xE952553833027f08e40ccfB518458E9B9A035d22), 15,"Send 15 RHT tokens");

        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.transfer(address(this),7);
        assertEq(c.balanceOf(address(this)), 92,"Transfer 7/85 = 92 RHT tokens");
        assertEq(c.balanceOf(0xE952553833027f08e40ccfB518458E9B9A035d22), 8,"Send 8 RHT tokens");
    }

    function test_ExpectEmit() public {
        c.mint(address(this), 600);
        // Check that topic 1, topic 2, and data are the same as the following emitted event.
        // Checking topic 3 here doesn't matter, because `Transfer` only has 2 indexed topics.
        vm.expectEmit(true, true, false, true);
        // The event we expect
        emit Transfer(address(this), 0xE952553833027f08e40ccfB518458E9B9A035d22, 250);
        // The event we get
        c.transfer(0xE952553833027f08e40ccfB518458E9B9A035d22, 250);
    }

    function testApprove() public {
        c.mint(address(this), 100);
        c.approve(0xE952553833027f08e40ccfB518458E9B9A035d22,33);
        assertEq(c.allowance(address(this),0xE952553833027f08e40ccfB518458E9B9A035d22), 33,"Allowance of 33");
        assertEq(c.balanceOf(address(this)),100,"Bal of 67");
        

        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.transferFrom(address(this),0x5E9dabB612D434fbDb22C63792E8Fd08613f1C3b,22);

        assertEq(c.allowance(address(this),0xE952553833027f08e40ccfB518458E9B9A035d22), 11,"Allowance of 11");
        assertEq(c.balanceOf(address(this)),78,"Bal of 78");
        assertEq(c.balanceOf(0x5E9dabB612D434fbDb22C63792E8Fd08613f1C3b), 22,"Bal of 22");
        
    }

    function test_ExpectEmitApprove() public {
        c.mint(address(this), 600);
        
        vm.expectEmit(true, true, false, true);
        emit Approval(address(this), 0xE952553833027f08e40ccfB518458E9B9A035d22, 100);

        c.approve(0xE952553833027f08e40ccfB518458E9B9A035d22, 100);
        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.transferFrom(address(this), 0xE952553833027f08e40ccfB518458E9B9A035d22, 70);
    }

    function testFailSpend() public {
        c.mint(address(this), 100);
        assertEq(c.balanceOf(address(this)),7,"ok. Bal: 100");
        // The 3 arg, error string, gets logged but not for other assertEq
    }

    function testFailTransfer() public {
        c.mint(address(this), 100);
        c.transfer(0xE952553833027f08e40ccfB518458E9B9A035d22,150);
        //assertEq(c.balanceOf(address(this)), 200,"Transfer 15/100 = 85 RHT tokens");
        // assertEq(c.balanceOf(0xE952553833027f08e40ccfB518458E9B9A035d22), 150,"Transfer 15/100 = 85 RHT tokens");
    }

    function testFailAllow() public {
        c.mint(address(this), 100);
        c.approve(0xE952553833027f08e40ccfB518458E9B9A035d22,33);
        assertEq(c.allowance(address(this),0xE952553833027f08e40ccfB518458E9B9A035d22), 33,"Allowance of 33");
        assertEq(c.balanceOf(address(this)),100,"Bal of 100");

        vm.prank(0xE952553833027f08e40ccfB518458E9B9A035d22);
        c.transferFrom(address(this),0x5E9dabB612D434fbDb22C63792E8Fd08613f1C3b,55);

    }

}



/*
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Contract.sol";

contract TestContract is Test {
    Contract c;

    function setUp() public {
        c = new Contract();
    }

    function testBar() public {
        assertEq(uint256(1), uint256(1), "ok");
    }

    function testFailInt() public {
        assertEq(uint256(1), uint256(2), "ok");
    } 

    function testBoo() public {
        assertTrue(bool (uint256(10) > uint256(1)));
    }

    function testFailAddr() public {
        assertEq(0x4776b69d56d9Ff7725D2eAdb283ABcF3B9B03B67,0xE952553833027f08e40ccfB518458E9B9A035d22,"ok");
    }
    
    function testFoo(uint256 x) public {
        vm.assume(x < type(uint128).max);
        assertEq(x + x, x * 2);
    }
}
*/