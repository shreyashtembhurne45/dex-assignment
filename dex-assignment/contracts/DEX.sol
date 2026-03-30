// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LPToken.sol";

// ================================================================
// TASK 2 [25+15 points] — Core DEX Implementation
// "DEX.sol: The core DEX implementation should be in this file"
// "Use OpenZeppelin's IERC20 interface for token interactions"
// ================================================================
contract DEX {

    // ============================================================  
    // STATE VARIABLES
    // Section 4.1.3 — Tracking Metrics:
    // Track reserves internally instead of using balanceOf()
    // ============================================================

    // Section 4.4: "Use OpenZeppelin's IERC20 interface"
    IERC20 public tokenA;
    IERC20 public tokenB;

    // Section 4.1.1: "LP tokens (ERC-20) represent share of reserves"
    // Section 4.4: "LPToken.sol: Implement the LPTs to be minted
    //               and burned in the DEX"
    LPToken public lpToken;

    // Section 4.1.3: Internal reserves for TokenA and TokenB
    uint256 public reserveA;
    uint256 public reserveB;

    // Section 4.1.2: "The swap fee is fixed at 0.3% for all swaps"
    // 0.3% fee = trader keeps 99.7% = 997/1000 of input
    // Using integers because Solidity has no floating point numbers
    uint256 constant FEE_NUMERATOR = 997;
    uint256 constant FEE_DENOMINATOR = 1000;

    // ============================================================
    // EVENTS
    // ============================================================
    event LiquidityAdded(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 lpMinted
    );
    event LiquidityRemoved(
        address indexed provider,
        uint256 amountA,
        uint256 amountB,
        uint256 lpBurned
    );
    event Swap(
        address indexed trader,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOut
    );

    // ============================================================
    // CONSTRUCTOR
    // Section 4.4: "The DEX contract should be deployed with
    // two existing ERC20 token addresses"
    // this DEX can mint/burn LP tokens (Theory Question 1)
    // ============================================================
    constructor(address _tokenA, address _tokenB) {
        // Section 4.1.4 — Security and Validations:
        // "Implement sanity checks wherever necessary"
        require(
            _tokenA != address(0) && _tokenB != address(0),
            "Invalid token address"
        );
        require(_tokenA != _tokenB, "Tokens must be different");

        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);

        // DEX deploys and owns the LP token
        // Only this DEX contract can call mint() and burn()
        lpToken = new LPToken();
    }

    // ============================================================
    // Section 4.1.1 — Liquidity Pool & LP Tokens
    // ADD LIQUIDITY
    // "LPs deposit TokenA and TokenB while preserving the ratio"
    // "First depositor sets the initial ratio and receives LP tokens"
    // "Subsequent deposits must mint LP tokens proportionally"
    // "Transactions that violate this ratio should revert"
    // ============================================================
    function addLiquidity(uint256 amountA, uint256 amountB) external {

        // Section 4.1.4 — Security: basic input validation
        require(amountA > 0 && amountB > 0, "Amounts must be greater than 0");

        // Section 4.1.1 — Ratio preservation:
        // "any liquidity addition must satisfy x/y = depositA/depositB"
        // Using cross multiplication instead of division to avoid
        // rounding errors in integer math:
        // amountA/amountB == reserveA/reserveB
        // becomes amountA * reserveB == amountB * reserveA
        // Example from Table 2:
        // reserves = (200, 300), deposit = (100, 150)
        // 100 * 300 == 150 * 200 → 30000 == 30000 ✓
        if (reserveA > 0 && reserveB > 0) {
            require(
                amountA * reserveB == amountB * reserveA,
                "Token ratio must match pool ratio"
            );
        }

        // Pull tokens FROM user INTO this DEX contract
        // Requires user to have called approve() on each token first
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        // Section 4.1.1 — LP Token minting logic:
        uint256 lpSupply = lpToken.totalSupply();
        uint256 lpToMint;

        if (lpSupply == 0) {
            // First deposit — set baseline of 1000 LP tokens
            // "First depositor sets the initial ratio"
            // establishes the starting LP token supply
            lpToMint = 1000 * 10 ** 18;
        } else {
            // Section 4.1.1:
            // "Subsequent deposits must mint LP tokens proportionally
            //  to the share of liquidity added relative to current pool"
            // Formula: lpToMint = (amountA / reserveA) * lpSupply
            // Multiply before divide to preserve precision:
            lpToMint = (amountA * lpSupply) / reserveA;
        }

        // Section 4.1.3 — Update internal reserves
        reserveA += amountA;
        reserveB += amountB;

        // Mint LP tokens to the depositor
        lpToken.mint(msg.sender, lpToMint);

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
    }

    // ============================================================
    // Section 4.1.1 — Liquidity Pool & LP Tokens
    // REMOVE LIQUIDITY
    // "LP tokens are burned on withdrawals"
    // "LP operations preserve proportional ownership"
    // ============================================================
    function removeLiquidity(uint256 lpAmount) external {

        // Section 4.1.4 — Security: input validation
        require(lpAmount > 0, "LP amount must be greater than 0");

        uint256 lpSupply = lpToken.totalSupply();
        require(lpSupply > 0, "No liquidity in pool");

        // Section 4.1.1 — Proportional withdrawal:
        // "LP tokens represent share of reserves"
        uint256 amountA = (lpAmount * reserveA) / lpSupply;
        uint256 amountB = (lpAmount * reserveB) / lpSupply;

        require(amountA > 0 && amountB > 0, "Insufficient liquidity burned");

        // Section 4.1.4 — Security: Reentrancy protection
        // "Implement sanity checks wherever necessary and
        //  ensure safe arithmetic while minimizing code vulnerabilities"
        // Safe order is strictly: burn → update reserves → transfer

        // 1. Burn LP tokens first
        lpToken.burn(msg.sender, lpAmount);

        // 2. Update internal reserves
        reserveA -= amountA;
        reserveB -= amountB;

        // 3. Only then transfer tokens out
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
    }

    // ============================================================
    // Section 4.1.2 — Swapping Mechanism
    // SWAP A FOR B
    // "Swap fee is fixed at 0.3%"
    // "Swap price must be dynamically calculated on pool reserves"
    // ============================================================
    function swapAForB(uint256 amountAIn) external {

        // Section 4.1.4 — Security: input validation
        require(amountAIn > 0, "Amount must be greater than 0");
        require(reserveA > 0 && reserveB > 0, "Pool has no liquidity");

        // Section 4.1.2 — Apply 0.3% fee:
        uint256 amountAInWithFee = amountAIn * FEE_NUMERATOR;

        // Section 4.1.2 — Constant product formula:
        // Before swap: reserveA * reserveB = k
        // After swap:
        //   (reserveA + amountAIn_afterFee) * (reserveB - amountBOut) = k
        // Solving for amountBOut:
        //   amountBOut = (reserveB * amountAIn_afterFee)
        //                / (reserveA + amountAIn_afterFee)
        // FEE_DENOMINATOR scales correctly with FEE_NUMERATOR above
        uint256 amountBOut = (reserveB * amountAInWithFee) /
            (reserveA * FEE_DENOMINATOR + amountAInWithFee);

        // Section 4.1.4 — Security: output validation
        require(amountBOut > 0, "Insufficient output amount");
        require(amountBOut < reserveB, "Insufficient pool liquidity");

        // Pull TokenA from trader
        tokenA.transferFrom(msg.sender, address(this), amountAIn);

        // Section 4.1.3 — Update internal reserves
        // Full amountAIn goes in (fee stays in pool as part of reserveA)
        reserveA += amountAIn;
        reserveB -= amountBOut;

        // Send TokenB to trader
        tokenB.transfer(msg.sender, amountBOut);

        emit Swap(msg.sender, address(tokenA), amountAIn, amountBOut);
    }

    // ============================================================
    // Section 4.1.2 — Swapping Mechanism
    // SWAP B FOR A
    // "Traders can swap TokenA for TokenB AND VICE VERSA"
    // Exact mirror of swapAForB with A and B roles reversed
    // ============================================================
    function swapBForA(uint256 amountBIn) external {

        // Section 4.1.4 — Security: input validation
        require(amountBIn > 0, "Amount must be greater than 0");
        require(reserveA > 0 && reserveB > 0, "Pool has no liquidity");

        // Section 4.1.2 — Same fee logic as swapAForB
        uint256 amountBInWithFee = amountBIn * FEE_NUMERATOR;

        // Section 4.1.2 — Same constant product formula, A and B reversed
        uint256 amountAOut = (reserveA * amountBInWithFee) /
            (reserveB * FEE_DENOMINATOR + amountBInWithFee);

        // Section 4.1.4 — Security: output validation
        require(amountAOut > 0, "Insufficient output amount");
        require(amountAOut < reserveA, "Insufficient pool liquidity");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);

        // Section 4.1.3 — Update internal reserves
        reserveB += amountBIn;
        reserveA -= amountAOut;

        tokenA.transfer(msg.sender, amountAOut);

        emit Swap(msg.sender, address(tokenB), amountBIn, amountAOut);
    }

    // ============================================================
    // Section 4.1.3 — Tracking Metrics
    // GETTER FUNCTIONS
    // "Functions to read the current value of the reserves"
    // "Functions to retrieve the current price of TokenA in
    //  terms of TokenB and vice versa"
    // Also used by Task 3 (Arbitrage) — Section 5.3 says:
    // "Implement price comparison logic using spotPrice()
    //  from two DEX contracts"
    // ============================================================

    // Section 4.1.3: Read current reserves
    // Used by Python simulation (Section 4.2) to track TVL,
    // reserve ratios, and other metrics in Table 1
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // Section 4.1.1 + 4.1.3:
    // "The reserve ratio of TokenA to TokenB should be possible
    //  to read by a function. The return value is the Spot Price"
    // spotPrice = how much TokenB per 1 TokenA
    // Multiplied by 1e18 to preserve decimals in integer math
    // Example: reserveA=200, reserveB=300
    // spotPrice = 300/200 = 1.5 → returned as 1500000000000000000
    // Section 5.3 (Arbitrage) uses this to compare two DEXes
    function spotPrice() external view returns (uint256) {
        require(reserveA > 0, "No liquidity");
        return (reserveB * 10 ** 18) / reserveA;
    }

    // Section 4.1.3: "vice versa" — price of TokenB in TokenA terms
    function spotPriceInverse() external view returns (uint256) {
        require(reserveB > 0, "No liquidity");
        return (reserveA * 10 ** 18) / reserveB;
    }
}

//TokenA : 0xd9145CCE52D386f254917e481eB44e9943F39138
//TokenB : 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
// DEX1 : 0xDA0bab807633f07f013f94DD0E6A4F96F8742B53