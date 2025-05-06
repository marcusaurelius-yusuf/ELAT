# Experimental Liberal-Anarchist Token (ELAT)

**ELAT** is a modular, self-regulating ERC-20 token contract designed for decentralized communities seeking to operate without a central bank. It blends liberal principles of fairness with anarchist ideals of decentralized autonomy, and incorporates programmable monetary policies.

## 🌐 Overview

This token contract supports:
- **Universal Basic Income (UBI)**
- **Proof-of-Labor minting**
- **Token Decay (Demurrage)**
- **Transaction Tax & Redistribution**
- **Oracle-controlled dynamic monetary policy**

All features can be toggled by the contract owner and parameters adjusted dynamically to adapt to the community’s needs.

---

## 🔐 Features

| Feature              | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| UBI                  | Periodic minting to eligible users                                          |
| Labor Minting        | Users can mint tokens by submitting periodic proof-of-labor                |
| Token Decay          | Holder balances decay periodically to encourage circulation                |
| Transaction Tax      | Transfers include an optional redistributive tax                           |
| Oracle Supply Logic  | Burn/mint actions adapt to inflation and velocity via external oracle feed |

---

## ⚙️ Configuration

All parameters (rates, thresholds, toggles) can be configured by the contract owner:

```solidity
toggleUBI(bool enabled);
setUBIAmount(uint256 amount);
submitLaborProof(); // once per day
toggleDecay(bool enabled);
toggleTax(bool enabled);
setTaxRecipient(address);
toggleOracleControl(bool enabled);
