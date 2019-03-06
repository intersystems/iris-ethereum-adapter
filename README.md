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

## How to start Demo
0. Before starting Demo
   * Chose Ethereum test network you will work with (we used ropsten)
   * Create a Ethereum wallet (account) in the selected network - the easiest way to do this is using the browser metamask plugin
   * Use https://faucet.ropsten.be/ to get test coins
   * In order to work with Ethereum, you need to either install the blockchain node locally (for example, by installing Geth) or use the Infura cloud service. (We used Infura). To use Infura - register at https://infura.io/ and get your key to work with the Infura API

1. Install adapter

2. Create a new web application
   * name: **/adaptertest**
   * Namespace: <yournamespace>
   * Enable: REST
   * Dispatch Class: **Ethereum.Demo.REST**
   
3. In the Interoperability->Configure->Credentials section of the Management Portal, create credentials
   * ID - any string (demo)
   * UserName - your Ethereum wallet address 
   * Password - your Private key
   
4. In the Management Portal open Ethereum.Demo.Production

5. For  Ethereum.Demo.EthereumOperation specify settings:
   * Provider  (https://ropsten.infura.io/<YourInfuraKey>)
   * DeferredResponseHost (localhost)
   * DeferredResponsePort (52773)
   * DeferredResponsePath (/adaptertest/deferred) (the application you created in step 2)
   * LoggerLevel:EA
   * LoggerFolder: log (in the nodejs folder create a subfolder log with write permissions) 
   * ContractFolder: /fullpathto/iris-ethereum-adapter/smartcontract/ (including trailing slash)
   * Credentials: demo (the credentials you created in step 3)
And Apply settings
   
6. Start Production

7. Using IRIS Interoperability Testing Service test  Ethereum.Demo.EthereumOperation 
   * send Ethereum.Demo.BalanceRequest with your wallet address
   * send Ethereum.Demo.DeployContractRequest with fullpath to smartcontrant’s folder 
      You will receive transaction hash. Copy this hash, open and find the transaction by hash on https://ropsten.etherscan.io/. 
      Copy Contract Address

8. Specify Contract Address in appropriate setting of the Ethereum.Demo.Ethereum Operation component

9. Continue testing  Ethereum.Demo.EthereumOperation
   * send Ethereum.Demo.HelloRequest
   * send Ethereum.Demo.SetNameRequest with your name
   * send Ethereum.Demo.HelloRequest again


For more information, sample code and discussion, go to the article on community.intersystems.com https://community.intersystems.com/post/ethereum-adapter-intersystems-iris-data-platform
