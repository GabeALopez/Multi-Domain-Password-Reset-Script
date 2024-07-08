# Multi-Domain Password Reset Script

## Description

A script that allows users to change passwords across multiple AD domains using domain credentials, but it cannot change passwords for expired accounts

## Features

- Change passwords in multiple Active Directory (AD) domains
- Easy-to-use interface
- Secure password handling
- Utilizes a CSV file for input data

## Requirements

- Windows PowerShell
- Active Directory module for Windows PowerShell

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/multi-domain-password-reset-script.git
    ```
2. Navigate to the project directory:
    ```bash
    cd multi-domain-password-reset-script
    ```

## CSV File Format

The script requires a CSV file with the following columns:

- `Id`
- `Domains`
- `UserName`
- `FQDNDomain`

Example:
```csv
Id,Domains,UserName,FQDNDomain
1,foo,admin,foo.bar.org
2,foobar,admin,bar.foo.bar.org
3,barfoo,admin,foo.bar2