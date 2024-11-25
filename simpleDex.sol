// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title SimpleDEX
/// @author Diego Sani
/// @notice Este contrato implementa un intercambio descentralizado simple (DEX)
/// @dev Incluye protección contra ataques de reentrancy
contract SimpleDEX is Ownable, ReentrancyGuard {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    
    uint256 public reserveA;
    uint256 public reserveB;
    
    error InvalidToken();
    error InsufficientLiquidity();
    error InvalidAmount();
    error TransferFailed();
    error PriceImpactTooHigh();
    
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event Swap(address indexed sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    
    constructor(address _tokenA, address _tokenB, address initialOwner) Ownable(initialOwner) {
        if(_tokenA == address(0) || _tokenB == address(0)) revert InvalidToken();
        if(_tokenA == _tokenB) revert InvalidToken();
        
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    function _safeTransferFrom(IERC20 token, address from, uint256 amount) private {
        bool success = token.transferFrom(from, address(this), amount);
        if(!success) revert TransferFailed();
    }
    
    function _safeTransfer(IERC20 token, address to, uint256 amount) private {
        bool success = token.transfer(to, amount);
        if(!success) revert TransferFailed();
    }
    
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner nonReentrant {
        if(amountA == 0 || amountB == 0) revert InvalidAmount();
        
        reserveA += amountA;
        reserveB += amountB;
        
        _safeTransferFrom(tokenA, msg.sender, amountA);
        _safeTransferFrom(tokenB, msg.sender, amountB);
        
        emit LiquidityAdded(msg.sender, amountA, amountB);
    }
    
    function _calculateSwapAmount(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256) {
        if(reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();
        
        uint256 amountWithFee = amountIn * 997; // 0.3% fee
        uint256 numerator = amountWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountWithFee;
        
        return numerator / denominator;
    }
    
    function swapAforB(uint256 amountAIn) external nonReentrant {
        if(amountAIn == 0) revert InvalidAmount();
        
        uint256 amountBOut = _calculateSwapAmount(amountAIn, reserveA, reserveB);
        if(amountBOut == 0 || amountBOut >= reserveB) revert PriceImpactTooHigh();
        
        reserveA += amountAIn;
        reserveB -= amountBOut;
        
        _safeTransferFrom(tokenA, msg.sender, amountAIn);
        _safeTransfer(tokenB, msg.sender, amountBOut);
        
        emit Swap(msg.sender, address(tokenA), address(tokenB), amountAIn, amountBOut);
    }
    
    function swapBforA(uint256 amountBIn) external nonReentrant {
        if(amountBIn == 0) revert InvalidAmount();
        
        uint256 amountAOut = _calculateSwapAmount(amountBIn, reserveB, reserveA);
        if(amountAOut == 0 || amountAOut >= reserveA) revert PriceImpactTooHigh();
        
        reserveB += amountBIn;
        reserveA -= amountAOut;
        
        _safeTransferFrom(tokenB, msg.sender, amountBIn);
        _safeTransfer(tokenA, msg.sender, amountAOut);
        
        emit Swap(msg.sender, address(tokenB), address(tokenA), amountBIn, amountAOut);
    }
    
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner nonReentrant {
        if(amountA == 0 || amountB == 0) revert InvalidAmount();
        if(amountA > reserveA || amountB > reserveB) revert InsufficientLiquidity();
        
        reserveA -= amountA;
        reserveB -= amountB;
        
        _safeTransfer(tokenA, msg.sender, amountA);
        _safeTransfer(tokenB, msg.sender, amountB);
        
        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }
    
    function getPrice(address _token) external view returns (uint256) {
        if(_token != address(tokenA) && _token != address(tokenB)) revert InvalidToken();
        if(reserveA == 0 || reserveB == 0) revert InsufficientLiquidity();
        
        return _token == address(tokenA) 
            ? (reserveB * 1e18) / reserveA 
            : (reserveA * 1e18) / reserveB;
    }
}
