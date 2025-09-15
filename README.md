# HTLending – Simple DeFi Lending Protocol

MiniLending is a lightweight DeFi protocol that allows users to deposit ETH as collateral and borrow the stablecoin DUSD.  
This project is developed for **VietBUIDL Hackathon** as a Minimum Viable Product (MVP) showcasing the core mechanics of decentralized lending.

---

## 🚀 Features
- **Deposit & Withdraw**: Lock ETH as collateral and withdraw when debt is cleared.  
- **Borrow & Repay**: Borrow DUSD against collateral and repay by burning DUSD tokens.  
- **On-chain Stablecoin (DUSD)**: ERC20 token minted upon borrowing and burned upon repayment.  
- **Health Factor & Liquidation**: Risk monitoring system; unhealthy positions can be liquidated.  
- **Reputation System**: Users gain reputation points when repaying debts.  
- **Oracle Mock**: Admin can update ETH price to simulate market volatility.  

---

## 🛠️ Smart Contracts
- `MiniLending.sol` → main lending protocol logic  
- `DUSDToken.sol` → ERC20 stablecoin used in the protocol  

---

## 📦 Installation & Deployment

### Prerequisites
- [MetaMask](https://metamask.io/) wallet  
- [Remix IDE](https://remix.ethereum.org/)  
- ETH Testnet tokens (Sepolia / Holesky)  

### Steps
1. Open [Remix IDE](https://remix.ethereum.org/).  
2. Create a new file `MiniLending.sol` and paste the contract code.  
3. Compile the contract using Solidity compiler ^0.8.0.  
4. Switch MetaMask to a testnet (e.g., Holesky or Sepolia).  
5. Deploy the contract using **Injected Provider - MetaMask**.  
6. Confirm the transaction → you will get a **contract address**.  

---

## 📖 How to Use

### 1. Deposit ETH
```solidity
deposit() payable
