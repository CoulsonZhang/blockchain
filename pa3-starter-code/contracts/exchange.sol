// =================== CS251 DEX Project =================== // 
//        @authors: Simon Tao '22, Mathew Hogan '22          //
// ========================================================= //    
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import './token.sol';
import '../libraries/ownable.sol';
import '../libraries/safemath.sol';

/* This exchange is based off of Uniswap V1. The original whitepaper for the constant product rule
 * can be found here:
 * https://github.com/runtimeverification/verified-smart-contracts/blob/uniswap/uniswap/x-y-k.pdf
 */

contract TokenExchange is Ownable {
    address public admin;

    address tokenAddr = 0xA03b2a2934512B3fD09BB5bBB614a8227ff92fDB;                              // TODO: Paste token contract address here.
    Onedollar private token = Onedollar(tokenAddr);         // TODO: Replace "Token" with your token class.             

    // Liquidity pool for the exchange
    uint public token_reserves = 0;
    uint public eth_reserves = 0;

    // Constant: x * y = k
    uint public k;
    
    // liquidity rewards
    uint private swap_fee_numerator = 0;       // TODO Part 5: Set liquidity providers' returns.
    uint private swap_fee_denominator = 100;
    
    event AddLiquidity(address from, uint amount);
    event RemoveLiquidity(address to, uint amount);

    constructor() 
    {
        admin = msg.sender;
    }


    /**
     * Initializes a liquidity pool between your token and ETH.
     * 
     * This is a payable function which means you can send in ETH as a quasi-parameter. In this
     * case, the amount of eth sent to the pool will be in msg.value and the number of tokens will
     * be amountTokens.
     *
     * Requirements:
     *  - the liquidity pool should be empty to start
     *  - the sender should send positive values for each
     */
    function createPool(uint amountTokens)
        external
        payable
        onlyOwner
    {
        // This function is already implemented for you; no changes needed

        // require pool does not yet exist
        require (token_reserves == 0, "Token reserves was not 0");
        require (eth_reserves == 0, "ETH reserves was not 0.");

        // require nonzero values were sent
        require (msg.value > 0, "Need ETH to create pool.");
        require (amountTokens > 0, "Need tokens to create pool.");

        token.transferFrom(msg.sender, address(this), amountTokens);
        eth_reserves = msg.value;
        token_reserves = amountTokens;
        k = eth_reserves * token_reserves;
    }

    // ============================================================
    //                    FUNCTIONS TO IMPLEMENT
    // ============================================================
      function checkbalance() 
        public 
        view
        returns (uint)
    {
        return token.balanceOf(msg.sender);
    }

      function checkETH() 
        public 
        payable 
        returns (uint)
    {
        return msg.value;
    }


    //Determine the price per token in ETH based on the current exchange rate. Be sure to use the SafeMath library when performing all arithmetic operations.
      function priceToken() 
        public 
        view
        returns (uint)
    {
        require(token_reserves > 0, "No token reserves");
        return SafeMath.div(eth_reserves, token_reserves);
    }

    //Determine the price per ETH in tokens based on the current exchange rate.
      function priceETH() 
        public 
        view
        returns (uint)
    {
        require(eth_reserves > 0, "No ETH reserves");
        return SafeMath.div(token_reserves, eth_reserves);
    }
    
    // Given an amount of tokens, calculates the corresponding amount of ETH 
    // based on the current exchange rate of the pool.
    //
    // NOTE: You can change the inputs, or the scope of your function, as needed.
    function amountTokenGivenETH(uint amountToken) 
        public 
        view
        returns (uint)
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate how much ETH is of equivalent worth based on the current exchange rate.
        */
        uint ethPrice = priceETH();
        return SafeMath.div(amountToken, ethPrice);
    }

    // Given an amount of ETH, calculates the corresponding amount of tokens 
    // based on the current exchange rate of the pool.
    //
    // NOTE: You can change the inputs, or the scope of your function, as needed.
    function amountETHGivenToken(uint amountETH)
        public
        view
        returns (uint)
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate how much of your token is of equivalent worth based on the current exchange rate.
        */
        uint tokenPrice = priceToken();
        return SafeMath.div(amountETH, tokenPrice);
    }


    /* ========================= Liquidity Provider Functions =========================  */ 

    /**
     * Adds liquidity given a supply of ETH (sent to the contract as msg.value).
     *
     * Calculates the liquidity to be added based on what was sent in and the prices. If the
     * caller possesses insufficient tokens to equal the ETH sent, then the transaction must
     * fail. A successful transaction should update the state of the contract, including the
     * new constant product k, and then Emit an AddLiquidity event.
     *
     * NOTE: You can change the inputs, or the scope of your function, as needed.
     */
    function addLiquidity(uint maxExchangeRate, uint minExchangeRate) 
        external 
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate the liquidity to be added based on what was sent in and the prices.
            If the caller possesses insufficient tokens to equal the ETH sent, then transaction must fail.
            Update token_reserves, eth_reserves, and k.
            Emit AddLiquidity event.
        */
        uint amountETH = msg.value;
        uint amountTokenRequired = SafeMath.div(SafeMath.mul(amountETH, token_reserves), eth_reserves);
        uint currentExchangeRate = SafeMath.mul(100, SafeMath.div(eth_reserves, token_reserves));
        require(currentExchangeRate <= maxExchangeRate && currentExchangeRate >= minExchangeRate, "Exchange rate out of bounds");


        require(token.balanceOf(msg.sender) >= amountTokenRequired, "Insufficient token balance");
        token.transferFrom(msg.sender, address(this), amountTokenRequired);

        eth_reserves = SafeMath.add(eth_reserves, amountETH);
        token_reserves = SafeMath.add(token_reserves, amountTokenRequired);
        
        k = SafeMath.mul(eth_reserves, token_reserves);

        emit AddLiquidity(msg.sender, amountETH);
    }


    /**
     * Removes liquidity given the desired amount of ETH to remove.
     *
     * Calculates the amount of your tokens that should be also removed. If the caller is not
     * entitled to remove the desired amount of liquidity, the transaction should fail. A
     * successful transaction should update the state of the contract, including the new constant
     * product k, transfer the ETH and Token to the sender and then Emit an RemoveLiquidity event.
     *
     * NOTE: You can change the inputs, or the scope of your function, as needed.
     */
    function removeLiquidity(uint amountETH, uint maxExchangeRate, uint minExchangeRate)
        public 
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate the amount of your tokens that should be also removed.
            Transfer the ETH and Token to the provider.
            Update token_reserves, eth_reserves, and k.
            Emit RemoveLiquidity event.
        */
        require(amountETH > 0, "Amount of ETH must be greater than zero");
        require(amountETH <= eth_reserves, "Insufficient ETH in reserves");
        uint currentExchangeRate = SafeMath.mul(100, SafeMath.div(eth_reserves, token_reserves));
        require(currentExchangeRate <= maxExchangeRate && currentExchangeRate >= minExchangeRate, "Exchange rate out of bounds");

        uint amountToken = SafeMath.div(SafeMath.mul(amountETH, token_reserves), eth_reserves);

        require(token.balanceOf(address(this)) >= amountToken, "Insufficient token in reserves");

        payable(msg.sender).transfer(amountETH);
        token.transfer(msg.sender, amountToken);

        eth_reserves = SafeMath.sub(eth_reserves, amountETH);
        token_reserves = SafeMath.sub(token_reserves, amountToken);

        k = SafeMath.mul(eth_reserves, token_reserves);

        emit RemoveLiquidity(msg.sender, amountETH);
    }

    /**
     * Removes all liquidity that the sender is entitled to withdraw.
     *
     * Calculate the maximum amount of liquidity that the sender is entitled to withdraw and then
     * calls removeLiquidity() to remove that amount of liquidity from the pool.
     *
     * NOTE: You can change the inputs, or the scope of your function, as needed.
     */
    function removeAllLiquidity(uint maxExchangeRate, uint minExchangeRate)
        external
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Decide on the maximum allowable ETH that msg.sender can remove.
            Call removeLiquidity().
        */
        uint userTokenBalance = token.balanceOf(msg.sender);
        require(userTokenBalance > 0, "No tokens to withdraw");
        uint currentExchangeRate = SafeMath.mul(100, SafeMath.div(eth_reserves, token_reserves));
        require(currentExchangeRate <= maxExchangeRate && currentExchangeRate >= minExchangeRate, "Exchange rate out of bounds");

        // Calculate the user's share of the pool
        uint userShare = (userTokenBalance * 1e18) / token_reserves;
        
        // Calculate the amount of ETH and tokens to remove based on the user's share
        uint userEthAmount = (eth_reserves * userShare) / 1e18;
        uint userTokenAmount = (token_reserves * userShare) / 1e18;

        // Ensure the amounts do not exceed the reserves
        userEthAmount = userEthAmount > eth_reserves ? eth_reserves : userEthAmount;
        userTokenAmount = userTokenAmount > userTokenBalance ? userTokenBalance : userTokenAmount;

        // Remove liquidity
        removeLiquidity(userEthAmount, userTokenAmount);
    }

    /***  Define helper functions for liquidity management here as needed: ***/

    function removeLiquidity(uint amountETH, uint amountToken) private {
        require(amountETH <= eth_reserves && amountToken <= token_reserves, "Insufficient liquidity in the pool");

        // Transfer ETH and tokens to the user
        payable(msg.sender).transfer(amountETH);
        token.transfer(msg.sender, amountToken);

        // Update the reserves
        eth_reserves -= amountETH;
        token_reserves -= amountToken;

        // Recalculate k
        k = eth_reserves * token_reserves;

        emit RemoveLiquidity(msg.sender, amountETH);
    }

    /* ========================= Swap Functions =========================  */ 

    /**
     * Swaps amountTokens of Token in exchange for ETH.
     *
     * Calculates the amount of ETH that should be swapped in order to keep the constant
     * product property, and transfers that amount of ETH to the provider. If the caller
     * has insufficient tokens, the transaction should fail. If performing the swap would
     * exhaust the total supply of ETH inside the exchange, the transaction must fail.
     *
     * Part 4 – Expand the function to take in additional parameters as needed. If the
     *          exchange rate is greater than the slippage limit, the swap should fail.
     *
     * Part 5 – Only exchange amountTokens minus the fee taken out for liquidity providers
     *          and keep track of the liquidity fees to be added back into the pool.
     *
     * NOTE: You can change the inputs, or the scope of your function, as needed.
     */
    function swapTokensForETH(uint amountTokens, uint maxExchangeRate)
        external 
        payable
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate amount of ETH should be swapped based on exchange rate.
            Transfer the ETH to the provider.
            If the caller possesses insufficient tokens, transaction must fail.
            If performing the swap would exhaus total ETH supply, transaction must fail.
            Update token_reserves and eth_reserves.

            Part 4: 
                Expand the function to take in addition parameters as needed.
                If current exchange_rate > slippage limit, abort the swap.
            
            Part 5:
                Only exchange amountTokens * (1 - liquidity_percent), 
                    where % is sent to liquidity providers.
                Keep track of the liquidity fees to be added.
        */
        require(amountTokens > 0, "Amount of tokens must be greater than zero");
        require(token.balanceOf(msg.sender) >= amountTokens, "Insufficient token balance");
        uint currentExchangeRate = SafeMath.mul(100, SafeMath.div(eth_reserves, token_reserves));

        require(currentExchangeRate <= maxExchangeRate, "Slippage exceeded");

        // Calculate the new token reserves after adding amountTokens
        uint newTokenReserves = SafeMath.add(token_reserves, amountTokens);
        
        // Calculate the new ETH reserves to maintain the constant product
        uint newEthReserves = SafeMath.div(k, newTokenReserves);
        uint amountETH = SafeMath.sub(eth_reserves, newEthReserves);

        require(amountETH <= eth_reserves, "Insufficient ETH in reserves");

        // Transfer tokens from the user to the contract
        token.transferFrom(msg.sender, address(this), amountTokens);

        // Transfer ETH from the contract to the user
        payable(msg.sender).transfer(amountETH);

        // Update the reserves
        eth_reserves = newEthReserves;
        token_reserves = newTokenReserves;


        // k = SafeMath.mul(eth_reserves, token_reserves);

        /***************************/
        // DO NOT CHANGE BELOW THIS LINE
        _checkRounding();
    }



    /**
     * Swaps msg.value ETH in exchange for your tokens.
     *
     * Calculates the amount of tokens that should be swapped in order to keep the constant
     * product property, and transfers that number of tokens to the sender. If performing
     * the swap would exhaust the total supply of tokens inside the exchange, the transaction
     * must fail.
     *
     * Part 4 – Expand the function to take in additional parameters as needed. If the
     *          exchange rate is greater than the slippage limit, the swap should fail.
     *
     * Part 5 – Only exchange amountTokens minus the fee taken out for liquidity providers
     *          and keep track of the liquidity fees to be added back into the pool.
     *
     * NOTE: You can change the inputs, or the scope of your function, as needed.
     */
    function swapETHForTokens(uint maxExchangeRate)
        external
        payable 
    {
        /******* TODO: Implement this function *******/
        /* HINTS:
            Calculate amount of your tokens should be swapped based on exchange rate.
            Transfer the amount of your tokens to the provider.
            If performing the swap would exhaus total token supply, transaction must fail.
            Update token_reserves and eth_reserves.

            Part 4: 
                Expand the function to take in addition parameters as needed.
                If current exchange_rate > slippage limit, abort the swap. 
            
            Part 5: 
                Only exchange amountTokens * (1 - %liquidity), 
                    where % is sent to liquidity providers.
                Keep track of the liquidity fees to be added.
        */
        uint amountETH = msg.value;
        require(amountETH > 0, "Amount of ETH must be greater than zero");

        // Calculate the new ETH reserves after adding amountETH
        uint newEthReserves = SafeMath.add(eth_reserves, amountETH);

        // Calculate the new token reserves to maintain the constant product
        uint newTokenReserves = SafeMath.div(k, newEthReserves);
        uint amountTokens = SafeMath.sub(token_reserves, newTokenReserves);

        require(amountTokens <= token.balanceOf(address(this)), "Insufficient token supply");
        uint currentExchangeRate = SafeMath.mul(100, SafeMath.div(token_reserves, eth_reserves));
        require(currentExchangeRate <= maxExchangeRate, "Slippage exceeded");

        // Transfer the calculated amount of tokens to the user
        token.transfer(msg.sender, amountTokens /* or amountTokensAfterFee if fee applied */);

        // Update the reserves
        eth_reserves = newEthReserves;
        token_reserves = newTokenReserves;

        // k = SafeMath.mul(eth_reserves, token_reserves);

        /**************************/
        // DO NOT CHANGE BELOW THIS LINE
        _checkRounding();

    }

    /** 
     * Checks that users are not able to get "free money" due to rounding errors.
     *
     * A liquidity provider should be able to input more (up to 1) tokens than they are theoretically
     * entitled to, and should be able to withdraw less (up to -1) tokens then they are entitled to.
     *
     * Checks for Math.abs(token_reserves * eth_reserves - k) < (token_reserves + eth_reserves + 1));
     * to account for the small decimal errors during uint division rounding.
     */
    function _checkRounding() private {
        uint check = token_reserves * eth_reserves;
        if (check >= k) {
            check = check - k;
        }
        else {
            check = k - check;
        }
        assert(check < (token_reserves + eth_reserves + 1));
        k = token_reserves * eth_reserves;             // reset k due to small rounding errors
    }

    /***  Define helper functions for swaps here as needed ***/

}
