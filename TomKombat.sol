// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./ERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

interface IPresale {
    function buy(address buyer, address refer) external payable;
}
interface IBotProtect {
    function protect(address from, address to, uint amount) external;
}
contract TomKombat is ERC20, Ownable {

    address public PRESALE_ADDRESS;

    uint public startTrading;

    IBotProtect public BotProtect;

    mapping(address => bool) private whiteLists;

    constructor() ERC20("TomKombat Token", "TKB")
    {
        _mint(msg.sender, 1_000_000_000 * 10 ** 18);
        whiteLists[msg.sender] = true;
    }

    function _transfer(address from, address to, uint amount) internal override {
        if (startTrading == 0) {
            require(whiteLists[from] || whiteLists[to], "Trading begins once the token is officially listed.");
        }
        if (address(BotProtect) != address(0)) {
            BotProtect.protect(from, to, amount);
        }
        super._transfer(from, to, amount);
    }

    function buy(uint amount, address refer) external payable {
        require(PRESALE_ADDRESS != address(0), "presale not set");
        IPresale(PRESALE_ADDRESS).buy{value: msg.value}(msg.sender, refer);
    }

    function safeTransferFrom(address from, address to, uint amount) public {
        require(msg.sender == PRESALE_ADDRESS);
        transfer(from, to, amount);
    }

    function setPresale(address _presale) external onlyOwner {
        PRESALE_ADDRESS = _presale;
        whiteLists[PRESALE_ADDRESS] = true;
    }

    function enableTrading() external onlyOwner {
        startTrading = 1;
    }

    function addWhiteLists(address user, bool _wl) external onlyOwner {
        whiteLists[user] = _wl;
    }

    receive() payable external {}
}
