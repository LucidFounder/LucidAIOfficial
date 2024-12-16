// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LUCIDAI is Ownable, ERC20 {
    bool public airdropped = false;
    bool public tradingEnabled = false;
    uint256 public maxHoldingAmount = 2e7*(10**18);
    address public uniswapV2Pair;
    address public presaleContract;

    constructor(uint256 _totalSupply) ERC20("LUCIDAI", "LUCIDAI") {
        _mint(msg.sender, _totalSupply);
    }

    function setUniswapPair(address _uniswapV2Pair) external onlyOwner {
        if (!tradingEnabled) {
            uniswapV2Pair = _uniswapV2Pair;
        }
    }

    function setPresaleContract(address _presaleContract) external onlyOwner {
        if (!tradingEnabled) {
            presaleContract = _presaleContract;
        }
    }

    function setAirdropped() external onlyOwner {
        if (!airdropped) {
            airdropped = true;
        }
    }

    function setFinalizeLaunch() external onlyOwner {
        if (!tradingEnabled) {
            tradingEnabled = true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) override internal virtual {
        if (!airdropped) {
            require(
                // 0 address only comes from minting
                from == address(0) || from == owner() || from == presaleContract, 
                "Trading is not enabled, airdrop commencing."
            );
            return;
        }

        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner() || from == presaleContract, "Pool is being created.");
            return;
        }

        if (to != uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount, "Exceeds max holding");
        }
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
