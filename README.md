# iris-ethereum-adapter
InterSystems IRIS Interoperability Adapter for Ethereum

## Overview
This adapter (Ethereum.NodeJS.OutboundAdapter) allows you to perform basic operations in ethereum:
* deploy a smart contract
* call smart contract methods
* transfer funds from one account to another
* call methods to retrieve data from ethereum

This adapter consists of 2 parts.
One of its parts is a Nodejs application that must be run
before launching production that use business operations with this adapter.

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
1. Create a business-operation that uses Ethereum.NodeJS.OutboundAdapter
2. Add the business-operation to your Production.
3. On Production configuration page set settings for this business-operation:
    * HTTP Server - ip address of the server where nodejs app is runing (could be localhost for the same server)
    * HTTP Port - Nodejs TCP port (3000)
    * Provider - full path to http provider you use to connect to Ethereum network (e.g. https://ropsten.infura.io/<your infura token>)
Requests such as deploying a smart contract or calling a state-changing method can require a significant amount of time to complete. If you plan to use such requests, you can use the deferred response mechanism in IRIS. In this case, add a REST service that receives a response from the nodejs app when the transaction in ethereum is executed. In business-operation configuration set:
    * DeferredResponseHost, DeferredResponsePort, DeferredResponsePath

4. Ethereum.TestOperation.cls contains sample code to use 
