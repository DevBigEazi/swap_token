// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import { ERC20Token } from "./IERC20.sol";

contract SwapToken {
    ERC20Token public dltToken;
    ERC20Token public usdtToken;
    address owner;
    bool internal locked;
    uint256 internal constant ONE_DLT_TO_USDT = 1;

    enum Token {NONE, DLT, USDT }

    mapping (Token => uint256)  contractBalances;

    constructor(ERC20Token _dltTokenCAddr, ERC20Token _usdtTokenCAddr){
        dltToken = _dltTokenCAddr;
        usdtToken = _usdtTokenCAddr;
        owner = msg.sender;
    }

    event SwapSuccessful(address indexed from, address indexed to, uint256 amount);
    event WithdrawSuccessful(address indexed owner, Token indexed _name, uint256 amount);


    modifier reentrancyGuard() {
        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can access");
        _;
    }

    function swapDLTtoUsdt(address _from, uint256 _amount) external reentrancyGuard  {
        require(msg.sender != address(0), "Zero not allowed");
        require(_amount > 0 , "Cannot swap zero amount");

        uint256 standardAmount = _amount * 10**18;

        uint256 userBal = dltToken.balanceOf(msg.sender);

        require(userBal >= _amount, "Your balance is not enough");

        uint256 allowance = dltToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Token allowance too low");

        bool deducted = dltToken.transferFrom(_from, address(this), standardAmount);

        require(deducted, "Excution failed");

        contractBalances[Token.DLT] +=  standardAmount;


        uint256 swapedValue = DLT_USDT_Rate(standardAmount, Token.DLT);

        bool swapped = usdtToken.transfer(msg.sender, swapedValue);



        if (swapped) {

            contractBalances[Token.USDT] +=  swapedValue;



            emit SwapSuccessful(_from, address(this), standardAmount );
        }

    }

    function swapUsdtToDLT(address _from, uint256 _amount) external reentrancyGuard {
        require(msg.sender != address(0), "Zero not allowed");
        require(_amount > 0 , "Cannot swap zero amount");

        uint256 standardAmount = _amount * 10**18;

        uint256 userBal = usdtToken.balanceOf(msg.sender);


        require(userBal >= _amount, "Your balance is not enough");

       
        uint256 allowance = usdtToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Token allowance too low");


        bool deducted = usdtToken.transferFrom(_from, address(this), standardAmount);

        require(deducted, "Excution failed");

        contractBalances[Token.USDT] +=  standardAmount;


        uint256 swapedValue = DLT_USDT_Rate(standardAmount, Token.USDT);

        bool swapped = usdtToken.transfer(msg.sender, swapedValue);

        if (swapped) {

            contractBalances[Token.DLT] +=  swapedValue;


            emit SwapSuccessful(_from, address(this), standardAmount );
        }


    }


        function getContractBalance() external view onlyOwner returns (uint256 contractUsdtbal_, uint256 contractDLTbal_) {
        contractUsdtbal_ = usdtToken.balanceOf(address(this));
        contractDLTbal_ = dltToken.balanceOf(address(this));
    }


      function withdraw(Token _name, uint256 _amount) external onlyOwner  {
        require(_amount > 0, "balance is less");

        uint256 bal = contractBalances[_name];

        require(bal >= _amount, "Insufficient contract balance");


        if(Token.DLT == _name) {

         dltToken.transfer(msg.sender, _amount);

         
        emit WithdrawSuccessful(msg.sender, _name, _amount);


        }else  if(Token.USDT == _name) {
         usdtToken.transfer(msg.sender, _amount);

         
        emit WithdrawSuccessful(msg.sender, _name, _amount);


        }

        revert("Token not defined");
    }



 function DLT_USDT_Rate (uint256 _amount, Token _token) internal pure returns (uint256 swapedValue_) {
        if(_token == Token.USDT) {
            swapedValue_ = _amount * ONE_DLT_TO_USDT;  
        } else if(_token == Token.DLT) {
            swapedValue_ = _amount  / ONE_DLT_TO_USDT ;
        } else {
            revert("Unsupported currency");
        }
        return swapedValue_;
    }
}