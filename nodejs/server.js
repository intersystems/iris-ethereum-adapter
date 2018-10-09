// have to be install : 
// npm i express
// npm i body-parser
// npm install web3
// ethereumjs-util 
// ethereumjs-tx 
// eth-lightwallet
var Web3 = require('web3');

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
function callContractGetMethod(res, provider, interface, contractAddress, method, args) {
    try {
    web3.setProvider(new web3.providers.HttpProvider(provider));
        var contract = new web3.eth.Contract(interface, contractAddress);
        contract.methods[method](...args).call(function (err, result) {
            if (err) {
                console.log(err);
                res.end(JSON.stringify({ status: 0, error: err }));
            } else {
                res.end(JSON.stringify({ status: 1, data: { args: result } }));
            }
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
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
function callContractSetMethod(res, provider, interface, contractAddress, walletAddress, key, method, amount, gasLimit, gasPrice, args, responseToken) {
    try {
        web3.setProvider(new web3.providers.HttpProvider(provider));

        var privateKey = "0x" + key
        var contract = new web3.eth.Contract(interface, contractAddress);
        var transfer = contract.methods[method](...args);
        var encodedABI = transfer.encodeABI();

        var tx = {
            from: walletAddress,
            to: contractAddress,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            value: amount,
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

                res.end(JSON.stringify({ status: 1, data: { transactionHash: hash } }));
            });

            tran.on('receipt', receipt => {
                console.log('reciept');
                console.log(receipt);
                if (responseToken != "")
                    deferredRequest(responseToken, 1, receipt);
            });

            tran.on('error', error => {
                console.log(error);
                deferredRequest(responseToken, 0, error);
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
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
function deployContract(res, provider, walletAddress, key, abi, byteCode, gasLimit, gasPrice, responseToken, args) {
    try {
        web3.setProvider(new web3.providers.HttpProvider(provider));
        var privateKey = "0x" + key
        var contractInstance = new web3.eth.Contract(abi);
        var contractToDeploy = contractInstance.deploy({
            data: byteCode,
            arguments: args
        }).encodeABI();
        var tx = {
            from: walletAddress,
            nonce: web3.eth.getTransactionCount(walletAddress),
            gasLimit: gasLimit,
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

                res.end(JSON.stringify({ status: 1, data: { transactionHash: hash } }));
            });

            tran.on('receipt', receipt => {
                console.log('reciept');
                console.log(receipt);
                console.log("receipt.contractAddress");
                console.log(receipt.contractAddress);
                if (responseToken != "")
                    deferredRequest(responseToken, 1, receipt);
            });

            tran.on('error', error => {
                console.log(error);
                deferredRequest(responseToken, 0, error);
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
}
 

function sendCoinTransaction(res, provider, fromWalletAddress, key, toWalletAddress, amount, responseToken, gasLimit, gasPrice) {
    try {
        web3.setProvider(new web3.providers.HttpProvider(provider));

        var privateKey = "0x" + key;
        var tx = {
            from: fromWalletAddress,
            to: toWalletAddress,
            nonce: web3.eth.getTransactionCount(fromWalletAddress),
            gasLimit: gasLimit,
            gasPrice: gasPrice,
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

                res.end(JSON.stringify({ status: 1, data: { transactionHash: hash } }));
            });

            tran.on('receipt', receipt => {
                console.log('reciept');
                console.log(receipt);
                deferredRequest(responseToken, 1, receipt);
            });

            tran.on('error', error => {
                console.log(error);
                deferredRequest(responseToken, 0, error);
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
}


function deferredRequest(responseToken, status, data) {
    if (typeof hostName == 'undefined' || typeof portNumber == 'undefined' || typeof responsePath == 'undefined') {
        console.log('DeferredOptions are empty');
    }
    else {
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
        var req = http.request(options, function (res) {
            console.log('Status: ' + res.statusCode);
            console.log('Headers: ' + JSON.stringify(res.headers));
            res.setEncoding('utf8');
            res.on('data', function (body) {
                console.log('Body: ' + body);
            });
        });
        req.on('error', function (e) {
            console.log('problem with request: ' + e.message);
        });
        var dataToSend;
        if (status == 0)
            dataToSend = JSON.stringify({ status: status, error: { responseToken: responseToken, data: data } });
        else
            dataToSend = JSON.stringify({ status: status, data: { responseToken: responseToken, data: data } });
        req.write(dataToSend);
        req.end();
    }
}


function callWeb3Method(res, provider, method, args) {
    try {
        web3.setProvider(new web3.providers.HttpProvider(provider));

        web3.eth[method](...args).then(function (result) {
            res.end(JSON.stringify({ status: 1, data: result }));
        }, function (err) {
            console.log(err);
            res.end(JSON.stringify({ status: 0, data: err }));
        });
    }
    catch (err) {
        res.statusCode = 400;
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
}



function estimateGasSetMethod(res, provider, interface, contractAddress, walletAddress, method, amount, args) {
    try {
        web3.setProvider(new web3.providers.HttpProvider(provider));

        var contract = new web3.eth.Contract(interface, contractAddress);
        var transfer = contract.methods[method](...args);
        var encodedABI = transfer.encodeABI();

        var tx = {
            from: walletAddress,
            to: contractAddress,
            value: amount,
            data: encodedABI
        };

        web3.eth.estimateGas(tx).then(result => {
            console.log(result);
            res.write(JSON.stringify({ status: 1, data: { gas: result } }));
            res.end();
        }, function (err) {
            console.log(err);
            res.end(JSON.stringify({ status: 0, error: err }));
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
}

  function estimateGasDeployContract(res, provider, walletAddress, abi, byteCode, args) {
    try {
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

                res.write(JSON.stringify({ status: 1, data: { gas: result } }));
                res.end();
            }, function (err) {
                console.log(err);
                res.end(JSON.stringify({ status: 0, error: err }));
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
    }
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

    res.end(JSON.stringify({ status: 1, data: "succeeded" }))
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

