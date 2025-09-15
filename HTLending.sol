// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title MiniLending - Simple DeFi Lending Protocol with ERC20 stablecoin
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

/// @dev Token DUSD đơn giản
contract DUSDToken is IERC20 {
    string public name = "Demo USD";
    string public symbol = "DUSD";
    uint8 public decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough DUSD");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function mint(address to, uint256 amount) external override {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function burn(address from, uint256 amount) external override {
        require(balanceOf[from] >= amount, "Not enough balance to burn");
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }
}

contract MiniLending {
    mapping(address => uint256) public collateralETH;
    mapping(address => uint256) public debtDUSD;
    mapping(address => uint256) public reputation;

    uint256 public collateralRatio = 150; // 150%
    uint256 public priceETH = 2000 * 1e18; // giả định 1 ETH = 2000$
    uint256 public constant DECIMALS = 1e18;

    DUSDToken public dusd;

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Liquidate(address indexed liquidator, address indexed user);

    constructor() {
        dusd = new DUSDToken();
    }

    // Gửi ETH làm tài sản thế chấp
    function deposit() external payable {
        collateralETH[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Vay DUSD dựa trên collateral
    function borrow(uint256 amountDUSD) external {
        uint256 collateralValue = (collateralETH[msg.sender] * priceETH) / DECIMALS;
        uint256 maxBorrow = collateralValue * 100 / collateralRatio;

        require(amountDUSD <= maxBorrow, "Not enough collateral");
        debtDUSD[msg.sender] += amountDUSD;
        dusd.mint(msg.sender, amountDUSD);
        emit Borrow(msg.sender, amountDUSD);
    }

    // Trả nợ
    function repay(uint256 amountDUSD) external {
        require(debtDUSD[msg.sender] >= amountDUSD, "Too much repay");
        require(dusd.balanceOf(msg.sender) >= amountDUSD, "Not enough DUSD in wallet");

        dusd.burn(msg.sender, amountDUSD);
        debtDUSD[msg.sender] -= amountDUSD;

        // tăng điểm uy tín khi trả nợ
        reputation[msg.sender] += 1;

        emit Repay(msg.sender, amountDUSD);
    }

    // Rút ETH (chỉ khi không có nợ)
    function withdraw(uint256 amountETH) external {
        require(debtDUSD[msg.sender] == 0, "Clear debt first");
        require(collateralETH[msg.sender] >= amountETH, "Not enough collateral");
        collateralETH[msg.sender] -= amountETH;
        payable(msg.sender).transfer(amountETH);
        emit Withdraw(msg.sender, amountETH);
    }

    // Xem tỷ lệ an toàn
    function healthFactor(address user) public view returns (uint256) {
        if (debtDUSD[user] == 0) return type(uint256).max;
        uint256 collateralValue = (collateralETH[user] * priceETH) / DECIMALS;
        return (collateralValue * 100) / debtDUSD[user];
    }

    // Thanh lý user nếu HF < 100%
    function liquidate(address user) external {
        require(healthFactor(user) < 100, "User still healthy");

        uint256 seizedCollateral = collateralETH[user];
        collateralETH[user] = 0;
        debtDUSD[user] = 0;

        payable(msg.sender).transfer(seizedCollateral);

        emit Liquidate(msg.sender, user);
    }

    // Admin cập nhật giá ETH (mock oracle)
    function updatePrice(uint256 newPrice) external {
        priceETH = newPrice;
    }
}