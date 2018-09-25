# iris-ethereum-adapter
InterSystems IRIS Interoperability Adapter for Ethereum

## Overview
This adapter allows you to perform basic operations in ethereum:
* deploy a smart contract
* call smart contract methods
* transfer funds from one account to another
* call methods to retrieve data from ethereum

This adapter consists of 2 parts.
One of its parts is a Nodejs application that must be run
before launching products that use business operations with this adapter.

## Installation
1. In nodejs folder install all necessary libs 
```
npm install
```
and run 
```
node server.js
```

2. Install Adapter classes - in IRIS terminal
```
do $system.OBJ.Load("full-path-to-Build.EthereumAdapter.cls","ck")
do ##class(Build.EthereumAdapter).Build()
```

Using adapter
1. Ethereum.TestOperation.cls contains sample code in the business-operation that uses this adapter
