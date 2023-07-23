 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
contract FundMETest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    function setUp() public {
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.ran(); 
        vm.deal(USER,10e18);
    }

    function testMinimunDollarIsFive() public{      
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }
    function testMsgSenderIsOwner() public  {
        assertEq(fundme.getOwner(), msg.sender);
    }
    function testPriceFeedIsAccurate() public{
        console.log(block.chainid);
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }
     function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundme.fund();
    }
    
    function testFundUpdatedDataStructure() public{
        vm.prank(USER);
        fundme.fund{value: 10e18} ();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded,10e18);
    }
    function testFunderToArrayOfFunders() public{ 
        vm.prank(USER);
        fundme.fund{value: 10e18}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier fuded() {
        vm.prank(USER);
        fundme.fund{value: 10e18}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public fuded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }
    function testWithdrawWithASigleFunder() public fuded{
        uint256 startingOwnerBal = fundme.getOwner().balance;
        uint256 startingFundMeBal = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 endingOwnerBAl = fundme.getOwner().balance;
        uint256 endingFundMeBal = address(fundme).balance;
        
        assertEq(endingFundMeBal, 0);
        assertEq(startingFundMeBal + startingOwnerBal, endingOwnerBAl);    
    }
    function testWithdrawWithMultipleFunder() public fuded{
        uint160 numfunders = 10;
        uint160 staringFunderIndex = 1;  
        for(uint160 i = staringFunderIndex; i < numfunders; i++){
            hoax(address(i),10e18);
            fundme.fund{value: 10e18}();
        }   
        uint256 startingOwnerBal = fundme.getOwner().balance;
        uint256 startingFunMeBal = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank(); 

        assert(address(fundme).balance == 0);
        assert(startingFunMeBal + startingOwnerBal == fundme.getOwner().balance);
                             
    }
}
