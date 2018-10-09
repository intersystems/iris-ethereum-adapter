// have to be install : 
// npm i express
// npm i body-parser
// npm install web3
// ethereumjs-util 
// ethereumjs-tx 
// eth-lightwallet
var Web3 = require('web3');
var util = require('ethereumjs-util');
var tx = require('ethereumjs-tx');
var lightwallet = require('eth-lightwallet');
var txutils = lightwallet.txutils;

var hostName;
var portNumber;
var responsePath;

var express = require('express')
var bodyParser=require('body-parser');
var app = express()
app.use(express.static(__dirname));

app.use(bodyParser.urlencoded({ extended: false }))

app.use(bodyParser.json()) 

app.use(function (req, res, next) {

    res.setHeader('Access-Control-Allow-Origin', '*');

    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

    res.setHeader('Access-Control-Allow-Credentials', true);

    next();
});

app.get('/', function (req, res) {
  res.send('Hello World')
})

const web3 = new Web3();


/**
@brief Call Contract Get Method
@detailed This function allows you to call any Get method of a smart contract and get data from it
@param res Http response to client
@param provider provider that provides access to the blockchain
@param interface smart contract ABI
@param contractAddress the address of the smart contract to which requests will be sent
@param method the name of the smart contract method that will be called
@param args arguments of method that will be called
@return Returns JSON object that contains the result of a method. Or returns an error
*/
function callContractGetMethod(res,provider,interface,contractAddress,method,args){
    web3.setProvider(new web3.providers.HttpProvider(provider));
    var contract = new web3.eth.Contract(interface,contractAddress);
    contract.methods[method](...args).call(function(err, result) {
        if(err) {
            console.log(err);
            res.end(err);
        } else {
            res.end(JSON.stringify({ args: result }));
        }
    });
}
/**
@brief Call Contract Set Method
@detailed This function allows you to call any Set method of a smart contract and get data from it
@param res Http response to client
@param provider provider that provides access to the blockchain
@param interface smart contract ABI
@param contractAddress the address of the smart contract to which requests will be sent
@param walletAddress the address of wallet from which will call the method
@param key private key from wallet
@param method the name of the smart contract method that will be called
@param amount amount in wei that will be included in transaction. Required for payable methods
@param responseToken a unique token for response to the client
@param args arguments of method that will be called
@return Returns JSON object that contains the transaction hash. Or returns an error
*/
function callContractSetMethod(res,provider,interface,contractAddress,walletAddress,key,method,amount,gasLimit,gasPrice,args, responseToken)
{
    web3.setProvider(new web3.providers.HttpProvider(provider));
    
    var privateKey = "0x" + key
    var contract = new web3.eth.Contract(interface, contractAddress);
    var transfer = contract.methods[method](...args);
    var encodedABI = transfer.encodeABI();

    var tx = {
    from: walletAddress,
    to: contractAddress,
    gasLimit: gasLimit,
    gasPrice: gasPrice,//web3.utils.toWei("0.000000001", "ether"),
    value:amount,//web3.utils.toWei(amount, "ether") ,
    data: encodedABI
    }; 
  
    web3.eth.accounts.signTransaction(tx, privateKey).then(signed => {
    var tran = web3.eth.sendSignedTransaction(signed.rawTransaction);

    tran.on('confirmation', (confirmationNumber, receipt) => {
      console.log('confirmation: ' + confirmationNumber);
    });

    tran.on('transactionHash', hash => {
      console.log('hash');
      console.log(hash);
      
      res.end(JSON.stringify({transactionHash: hash}));
    });

    tran.on('receipt', receipt => {
      console.log('reciept');
      console.log(receipt);
      if(responseToken != "")
      deferredRequest(responseToken , receipt);
    });

    tran.on('error', console.error);
  });
}

/**
@brief get wallet balance
@param res Http response to client
@param provider provider that provides access to the blockchain
@param walletAddress The wallet address whose balance will be returned
@return Returns JSON object that contains the wallet balance in wei. Or returns an error
*/
function getBalance(res , provider , walletAddress )
{
    web3.setProvider(new web3.providers.HttpProvider(provider));
    web3.eth.getBalance(walletAddress).then(function(balance) {
        res.end(JSON.stringify({balance: parseFloat(balance).toPrecision(12)}));
    }, function(err) {
        console.log(err);
    });
   
}


/**
@brief get last block number 
@param res Http response to client
@param provider provider that provides access to the blockchain
@return Returns JSON object that contains lats block number. Or returns an error
*/
function getLastBlockNumber(res, provider) {
    web3.setProvider(new web3.providers.HttpProvider(provider));
    web3.eth.getBlock('latest').then(function(result) {
        res.end(JSON.stringify({"lastBlockNumber": result.number}));
    }, function(err) {
        console.log(err);
    })
  }

  /**
@brief get Transaction Receipt
@detailed Returns the receipt of a transaction by transaction hash.
@param res Http response to client
@param provider provider that provides access to the blockchain
@return Returns JSON Object 
- A transaction receipt object, or null when no receipt was found:
<ul>
<li>blockNumber: Number - block number where this transaction was in</li>
<li>transactionHash: String, 32 Bytes - hash of the transaction.</li>
<li>transactionIndex: Number - integer of the transactions index position in the block.</li>
<li>from: String, 20 Bytes - address of the sender.</li>
<li>blockHash: String, 32 Bytes - hash of the block where this transaction was in.</li>
<li>to: String, 20 Bytes - address of the receiver. null when its a contract creation transaction.</li>
<li>cumulativeGasUsed: Number - The total amount of gas used when this transaction was executed in the block.</li>
<li>gasUsed: Number - The amount of gas used by this specific transaction alone.</li>
<li>contractAddress: String - 20 Bytes - The contract address created, if the transaction was a contract creation, otherwise null.</li>
<li>logs: Array - Array of log objects, which this transaction generated.</li>
<li>status: String - '0x0' indicates transaction failure , '0x1' indicates transaction succeeded.</li>
</ul>
*/
  function getTransactionReceipt(res,provider,transactionHash){
      web3.setProvider(new Web3.providers.HttpProvider(provider));
      //var receipt = 
      web3.eth.getTransactionReceipt(transactionHash).then(receipt=>   res.end(JSON.stringify({"transationReceipt": receipt})));
      //res.end(JSON.stringify({"transationReceipt": receipt}));
  }


  
/**
@brief Call Contract Get Method
@detailed This function allows you to call any Get method of a smart contract and get data from it
@param res Http response to client
@param provider provider that provides access to the blockchain
@param walletAddress the address of wallet from which will call the method
@param key private key from wallet
@param abi smart contract ABI
@param byteCode smart contract byte code
@param args parameters for constructor of smart contract 
@return Returns JSON object that contains the result of a method. Or returns an error
*/
function deployContract(res,provider,walletAddress , key, abi, byteCode,gasLimit,gasPrice, responseToken, args)
{
    web3.setProvider(new web3.providers.HttpProvider(provider));
    var privateKey = "0x" + key
    var contractInstance = new web3.eth.Contract(abi);
    var contractToDeploy = contractInstance.deploy({
        data: byteCode,
        arguments : args
        }).encodeABI();
  var tx = {
    from: walletAddress,
    nonce: web3.eth.getTransactionCount(walletAddress),
    gasLimit:gasLimit,
    gasPrice: gasPrice,
    data: contractToDeploy
  }; 
  
  web3.eth.accounts.signTransaction(tx, privateKey).then(signed => {
    var tran = web3.eth.sendSignedTransaction(signed.rawTransaction);

    tran.on('confirmation', (confirmationNumber, receipt) => {
      console.log('confirmation: ' + confirmationNumber);
    });

    tran.on('transactionHash', hash => {
      console.log('hash');
      console.log(hash);
      
      res.end(JSON.stringify({transactionHash: hash}));
    });

    tran.on('receipt', receipt => {
      console.log('reciept');
      console.log(receipt);
      console.log("receipt.contractAddress");
      console.log(receipt.contractAddress);
      if(responseToken != "")
      deferredRequest(responseToken , receipt);
    });

    tran.on('error', console.error);
  });

 }
 

 function sendCoinTransaction(res,provider,fromWalletAddress, key , toWalletAddress , amount,responseToken, gasLimit , gasPrice){
     
    web3.setProvider(new web3.providers.HttpProvider(provider));
    
    var privateKey = "0x" + key;
    var tx = {
    from: fromWalletAddress,
    to: toWalletAddress,
    nonce: web3.eth.getTransactionCount(fromWalletAddress),
    gasLimit: gasLimit,
    gasPrice: gasPrice,//web3.utils.toWei("0.000000001", "ether"),
    value: web3.utils.toWei(amount, "ether")
  }; 
  
    web3.eth.accounts.signTransaction(tx, privateKey).then(signed => {
    var tran = web3.eth.sendSignedTransaction(signed.rawTransaction);

    tran.on('confirmation', (confirmationNumber, receipt) => {
      console.log('confirmation: ' + confirmationNumber);
    });

    tran.on('transactionHash', hash => {
      console.log('hash');
      console.log(hash);
      
      res.end(JSON.stringify({transactionHash: hash}));
    });

    tran.on('receipt', receipt => {
      console.log('reciept');
      console.log(receipt);
      deferredRequest(responseToken , receipt);
    });

    tran.on('error', console.error);
  });
 }
 
//http://localhost/eth/deferred
//{
//  "responsetoken":<tokenvalue>,
//  "data": <тут все остальное> }


//Method that allow to send notification to client that transaction is proved
function deferredRequest(responseToken , data)
{           
    if( typeof hostName == 'undefined' || typeof portNumber == 'undefined' || typeof responsePath == 'undefined'){
        console.log('DeferredOptions are empty');
    }
    else{
        var http = require("http");
        var options = {
        hostname: hostName,
        port: portNumber,
        path: responsePath,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        }
        };
        var req = http.request(options, function(res) {
        console.log('Status: ' + res.statusCode);
        console.log('Headers: ' + JSON.stringify(res.headers));
        res.setEncoding('utf8');
        res.on('data', function (body) {
            console.log('Body: ' + body);
        });
        });
        req.on('error', function(e) {
        console.log('problem with request: ' + e.message);
        });
        var dataToSend = JSON.stringify({responseToken: responseToken,data: data});
        // write data to request body
        req.write(dataToSend);
        req.end();
    }
}

function callWeb3Method(res,provider,method,args)
{
    web3.setProvider(new web3.providers.HttpProvider(provider));
    try{
            web3.eth[method](...args).then(function(result) {
                res.end(JSON.stringify(result));
            }, function(err) {
                console.log(err);
            });
    }
    catch(err){
        res.statusCode = 400;
        res.end(JSON.stringify({error: err.message}));
    }
}
function estimateGasSetMethod(res,provider,interface,contractAddress,walletAddress,method,amount,args)
{
    web3.setProvider(new web3.providers.HttpProvider(provider));
 
    var contract = new web3.eth.Contract(interface, contractAddress);
    var transfer = contract.methods[method](...args);
    var encodedABI = transfer.encodeABI();

    var tx = {
    from: walletAddress,
    to: contractAddress,
    value:amount,
    data: encodedABI
    }; 
    
    web3.eth.estimateGas(tx).then(result => {
      console.log(result);
          
      res.write(JSON.stringify({gas: result}));
      res.end();
    });
  }

  function estimateGasDeployContract(res, provider, walletAddress, abi, byteCode , args)
  {
      web3.setProvider(new web3.providers.HttpProvider(provider));    
      var contractInstance = new web3.eth.Contract(abi);
      
      web3.eth.getTransactionCount(walletAddress).then(nonce => {
          var contractToDeploy = contractInstance.deploy({
              data: byteCode,
              arguments: args
              }).encodeABI();
              var tx = {
                  from: walletAddress,
                  nonce: nonce,
                  data: contractToDeploy
              }; 
              
              web3.eth.estimateGas(tx).then(result => {
                  console.log(result);
                      
                  res.write(JSON.stringify({gas: result}));
                  res.end();
              });
      });
      
  }


app.post('/callWeb3Method',function(req,res){
	callWeb3Method(res, req.body.provider,req.body.name, req.body.args);
    })

app.post('/callContractGetMethod',function(req,res){
	callContractGetMethod(res, req.body.provider, req.body.interface, req.body.contractAddress, req.body.name, req.body.args);
    })
    
app.post('/sendCoinTransaction',function(req,res){
    sendCoinTransaction(res,req.body.provider, req.body.fromWalletAddress, req.body.key,req.body.toWalletAddress,req.body.amount 
        ,req.body.responseToken,req.body.gasLimit,req.body.gasPrice);
    })
        
app.post('/callContractSetMethod',function(req,res){
    callContractSetMethod(res,req.body.provider, req.body.interface, req.body.contractAddress,req.body.walletAddress,req.body.key 
        ,req.body.name,req.body.amount,req.body.gasLimit,req.body.gasPrice,req.body.args, req.body.responseToken);
    })

app.post('/deployContract',function(req,res){
    deployContract(res,req.body.provider,req.body.walletAddress , req.body.key,  req.body.abi, req.body.byteCode,req.body.gasLimit,req.body.gasPrice, req.body.responseToken, req.body.args);
})

app.post('/setDeferredOptions', function(req,res){
    hostName = req.body.hostname;
    portNumber = req.body.port;
    responsePath = req.body.path;

    res.end("succeeded");
})

app.post('/estimateGasDeployContract',function(req,res){
	estimateGasDeployContract(res,req.body.provider,req.body.walletAddress 
        ,req.body.abi,req.body.byteCode,req.body.args);
    })

app.post('/estimateGasSetMethod',function(req,res){
estimateGasSetMethod(res,req.body.provider, req.body.abi, req.body.contractAddress,req.body.walletAddress 
    ,req.body.name,req.body.amount,req.body.args);
})

app.listen(3000,'localhost')
console.log('run');

