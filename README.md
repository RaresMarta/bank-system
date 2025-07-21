# 🏦 Bank ATMs Management Service

A simple Ruby-based banking system that simulates ATM interactions: create accounts, deposit and withdraw money, and manage balances — all with daily withdrawal limits.

---

## 📋 Project Overview

You're developing the core software for a bank’s ATM and account system. The goal is to manage:

- ✅ User account creation
- 💸 Money deposits (unlimited)
- 🏧 Withdrawals (with daily and balance constraints)

---

## 🚀 Features

- 🔐 **Account Creation**
  Users can sign up with:
  - Name
  - Job title
  - Email
  - Address

- 💵 **Deposits**
  Unlimited deposit capability

- 💳 **Withdrawals**
  - Max $5,000 per day
  - Cannot exceed current account balance

- ✅ **Validation Logic**
  All withdrawals are checked against both:
  - Daily withdrawal limit
  - Available balance
