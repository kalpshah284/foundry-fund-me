 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interaction.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
contract InteractionTest is Test {
     FundMe fundme;
    address USER = makeAddr("user");
    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.ran(); 
        vm.deal(USER,10e18);
    } 
    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));
    }
        
      
}   