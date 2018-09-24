# iris-ethereum-adapter
InterSystems IRIS Interoperability Adapter for Ethereum

1. In nodejs folder install all necessary libs 
```
npm install
```

2. Install Adapter classes - in IRIS terminal
```
do $system.OBJ.Load("full-path-to-Build.EthereumAdapter.cls","ck")
do ##class(Build.EthereumAdapter).Build()
```

3. Ethereum.TestOperation.cls contains sample code in the business-operation that uses this adapter