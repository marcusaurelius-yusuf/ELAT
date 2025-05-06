// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IOracle {
    function getInflationRate() external view returns (uint256);
    function getVelocity() external view returns (uint256);
}

contract ELAT is ERC20, Ownable {
    uint256 public decayRate = 100; // in basis points (100 = 1%)
    uint256 public taxRate = 100; // in basis points (100 = 1%)
    address public taxRecipient;
    uint256 public ubiAmount;
    bool public decayEnabled = false;
    bool public taxEnabled = false;
    bool public ubiEnabled = false;
    bool public oracleControlEnabled = false;

    IOracle public oracle;
    uint256 public inflationThreshold = 500; // 5%
    uint256 public velocityThreshold = 1000; // arbitrary

    mapping(address => bool) public isEligibleForUBI;
    mapping(address => uint256) public lastClaimedUBI;

    mapping(address => uint256) public lastLaborProof;
    uint256 public laborCooldown = 1 days;
    uint256 public laborReward = 5 * 10 ** 18;

    constructor() ERC20("Experimental Liberal-Anarchist Token", "ELAT") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
        taxRecipient = msg.sender;
        ubiAmount = 10 * 10 ** decimals();
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    // Enable/disable features
    function toggleDecay(bool _enabled) external onlyOwner {
        decayEnabled = _enabled;
    }

    function toggleTax(bool _enabled) external onlyOwner {
        taxEnabled = _enabled;
    }

    function toggleUBI(bool _enabled) external onlyOwner {
        ubiEnabled = _enabled;
    }

    function toggleOracleControl(bool _enabled) external onlyOwner {
        oracleControlEnabled = _enabled;
    }

    function setOracle(address _oracle) external onlyOwner {
        oracle = IOracle(_oracle);
    }

    function setUBIAmount(uint256 _amount) external onlyOwner {
        ubiAmount = _amount;
    }

    function setTaxRecipient(address _recipient) external onlyOwner {
        taxRecipient = _recipient;
    }

    function setDecayRate(uint256 _rate) external onlyOwner {
        decayRate = _rate;
    }

    function setTaxRate(uint256 _rate) external onlyOwner {
        taxRate = _rate;
    }

    function setThresholds(uint256 _inflation, uint256 _velocity) external onlyOwner {
        inflationThreshold = _inflation;
        velocityThreshold = _velocity;
    }

    // Labor-based minting (Proof-of-Labor)
    function submitLaborProof() external {
        require(block.timestamp >= lastLaborProof[msg.sender] + laborCooldown, "Wait for cooldown");
        _mint(msg.sender, laborReward);
        lastLaborProof[msg.sender] = block.timestamp;
    }

    function setLaborReward(uint256 _reward) external onlyOwner {
        laborReward = _reward;
    }

    function setLaborCooldown(uint256 _cooldown) external onlyOwner {
        laborCooldown = _cooldown;
    }

    // UBI distribution
    function claimUBI() external {
        require(ubiEnabled, "UBI not enabled");
        require(isEligibleForUBI[msg.sender], "Not eligible for UBI");
        require(block.timestamp >= lastClaimedUBI[msg.sender] + 1 days, "UBI can be claimed once per day");
        _mint(msg.sender, ubiAmount);
        lastClaimedUBI[msg.sender] = block.timestamp;
    }

    function setEligibility(address user, bool eligible) external onlyOwner {
        isEligibleForUBI[user] = eligible;
    }

    // Override transfer to apply decay and tax
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (oracleControlEnabled) {
            uint256 inflation = oracle.getInflationRate();
            uint256 velocity = oracle.getVelocity();
            if (inflation > inflationThreshold) {
                uint256 burnAmount = (amount * inflation) / 10000;
                _burn(sender, burnAmount);
                amount -= burnAmount;
            }
            if (velocity < velocityThreshold) {
                _mint(sender, ubiAmount / 10); // oracle-triggered stimulus
            }
        }

        if (decayEnabled) {
            uint256 decay = (balanceOf(sender) * decayRate) / 10000;
            _burn(sender, decay);
        }

        if (taxEnabled && taxRecipient != address(0)) {
            uint256 tax = (amount * taxRate) / 10000;
            super._transfer(sender, taxRecipient, tax);
            amount -= tax;
        }

        super._transfer(sender, recipient, amount);
    }

    // Manual mint/burn (for supply control if needed)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}