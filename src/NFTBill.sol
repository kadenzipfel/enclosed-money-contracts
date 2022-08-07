// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/tokens/ERC1155.sol";
import "solmate/tokens/ERC20.sol";

contract NFTBill is ERC1155 {
    function deposit(address erc20, uint96 value) external payable {
        if (erc20 == address(0)) {
            require(value == 0, "Send value in ETH");
            require(msg.value > 0, "Send at least 1 wei");

            uint256 id = msg.value;
            _mint(msg.sender, id, 1, "");
        } else {
            require(msg.value == 0, "Do not send ETH");
            require(value > 0, "Send at least some coins");

            // The caller is expected to have `approve()`d this contract
            // for the amount being deposited
            ERC20(erc20).transferFrom(msg.sender, address(this), value);
            uint256 id = (uint256(uint160(erc20)) << 96) | value;
            _mint(msg.sender, id, 1, "");
        }
    }

    function withdraw(uint256 id) external {
        _burn(msg.sender, id, 1);
        address erc20 = address(uint160(id >> 96));
        uint96 value = uint96(id);

        if (erc20 == address(0)) {
            (bool ok, bytes memory data) = msg.sender.call{value: value}("");
            require(ok, string(data));
        } else {
            ERC20(erc20).transfer(msg.sender, value);
        }
    }

    function uri(uint256) public pure override returns (string memory) {
        return ""; // TODO on-chain renderer
    }
}