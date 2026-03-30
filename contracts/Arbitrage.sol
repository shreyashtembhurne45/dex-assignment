// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDEX {
    function swapAForB(uint256 amountAIn) external;
    function swapBForA(uint256 amountBIn) external;
    function spotPrice() external view returns (uint256);
    function getReserves() external view returns (uint256, uint256);
}

contract Arbitrage {

    address public owner;
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public minProfitThreshold;

    event ArbitrageExecuted(uint256 profit);

    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _minProfitThreshold,
        address _dex1,
        address _dex2
    ) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        minProfitThreshold = _minProfitThreshold;

        // Approve both DEXes on deploy — no separate step to forget
        IERC20(_tokenA).approve(_dex1, type(uint256).max);
        IERC20(_tokenA).approve(_dex2, type(uint256).max);
        IERC20(_tokenB).approve(_dex1, type(uint256).max);
        IERC20(_tokenB).approve(_dex2, type(uint256).max);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function executeArbitrage(
        address dex1,
        address dex2,
        uint256 amountIn
    ) external onlyOwner {
        require(amountIn > 0, "Amount must be greater than 0");

        uint256 initialBalance = tokenA.balanceOf(address(this));
        require(initialBalance >= amountIn, "Insufficient capital");

        uint256 price1 = IDEX(dex1).spotPrice();
        uint256 price2 = IDEX(dex2).spotPrice();

        if (price1 > price2) {
            // dex1 gives more B per A → sell A on dex1, buy A back on dex2
            IDEX(dex1).swapAForB(amountIn);
            uint256 tokenBReceived = tokenB.balanceOf(address(this));
            require(tokenBReceived > 0, "No TokenB received");
            IDEX(dex2).swapBForA(tokenBReceived);

        } else if (price2 > price1) {
            // dex2 gives more B per A → sell A on dex2, buy A back on dex1
            IDEX(dex2).swapAForB(amountIn);
            uint256 tokenBReceived = tokenB.balanceOf(address(this));
            require(tokenBReceived > 0, "No TokenB received");
            IDEX(dex1).swapBForA(tokenBReceived);

        } else {
            revert("No arbitrage opportunity");
        }

        uint256 finalBalance = tokenA.balanceOf(address(this));
        uint256 profit = finalBalance > initialBalance 
            ? finalBalance - initialBalance 
            : 0;

        require(profit > minProfitThreshold, "Insufficient profit");

        // Bug fix: only transfer profit, keep capital in contract
        if (profit > 0) {
            tokenA.transfer(owner, profit);
        }

        emit ArbitrageExecuted(profit);
    }

    function deposit(uint256 amount) external onlyOwner {
        tokenA.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external onlyOwner {
        uint256 balA = tokenA.balanceOf(address(this));
        uint256 balB = tokenB.balanceOf(address(this));
        if (balA > 0) tokenA.transfer(owner, balA);
        if (balB > 0) tokenB.transfer(owner, balB);
    }

    // Helper to diagnose before executing
    function checkOpportunity(
        address dex1, 
        address dex2
    ) external view returns (uint256 p1, uint256 p2, bool hasOpp) {
        p1 = IDEX(dex1).spotPrice();
        p2 = IDEX(dex2).spotPrice();
        hasOpp = (p1 != p2);
    }
}
