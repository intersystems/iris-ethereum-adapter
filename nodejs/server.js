// have to be install : 
// npm i express
// npm i body-parser
// npm install web3
// npm install winston

var Web3 = require('web3');
var logger = require('./logger');

var hostName;
var portNumber;
var responsePath;

var express = require('express');
var bodyParser = require('body-parser');
var app = express();
app.use(express.static(__dirname));

app.use(bodyParser.urlencoded({ extended: false }));

app.use(bodyParser.json());

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
                logger.writeLog(
                    {
                        methodName: 'callContractGetMethod',
                        callParameters:
                        {
                            provider: provider,
                            interface: interface,
                            contractAddress: contractAddress,
                            method: method,
                            args: args
                        },
                        errorMessage: err.message
                    },
                    'error');
                res.end(JSON.stringify({ status: 0, error: err.message }));
            } else {
                res.end(JSON.stringify({ status: 1, data: { args: result } }));
                logger.writeLog(
                    {
                        methodName: 'callContractGetMethod',
                        callParameters:
                        {
                            provider: provider,
                            interface: interface,
                            contractAddress: contractAddress,
                            method: method,
                            args: args
                        },
                        data: result
                    },
                    'info');
            }
        });
    }
    catch (err) {
        logger.writeLog(
            {
                methodName: 'callContractGetMethod',
                callParameters:
                {
                    provider: provider,
                    interface: interface,
                    contractAddress: contractAddress,
                    method: method,
                    args: args
                },
                errorMessage: err.message
            },
            'error');
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

                logger.writeLog(
                    {
                        methodName: 'callContractSetMethod',
                        callParameters:
                        {  
                            provider: provider,
                            interface: interface,
                            contractAddress: contractAddress,
                            walletAddress: walletAddress,
                            key : key,
                            method: method,
                            amount: amount,
                            gasLimit: gasLimit,
                            gasPrice: gasPrice,
                            args: args,
                            responseToken: responseToken
                        },
                    },
                    'info');
            });

            tran.on('receipt', receipt => {
                console.log('reciept');
                console.log(receipt);
                if (responseToken != "")
                    deferredRequest(responseToken, 1, receipt);
            });

            tran.on('error', error => {
                console.log(error);

                res.end(JSON.stringify({ status: 0, error: error.message }));
        
                deferredRequest(responseToken, 0, error);
                logger.writeLog(
                    {
                        methodName: 'callContractSetMethod',
                        callParameters:
                        {  
                            provider: provider,
                            interface: interface,
                            contractAddress: contractAddress,
                            walletAddress: walletAddress,
                            key : key,
                            method: method,
                            amount: amount,
                            gasLimit: gasLimit,
                            gasPrice: gasPrice,
                            args: args,
                            responseToken: responseToken
                        },
                        errorMessage: error.message
                    },
                    'error');
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'callContractSetMethod',
                callParameters:
                {  
                    provider: provider,
                    interface: interface,
                    contractAddress: contractAddress,
                    walletAddress: walletAddress,
                    key : key,
                    method: method,
                    amount: amount,
                    gasLimit: gasLimit,
                    gasPrice: gasPrice,
                    args: args,
                    responseToken: responseToken
                },
                errorMessage: err.message
            },
            'error');
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

                logger.writeLog(
                    {
                        methodName: 'deployContract',
                        callParameters:
                        {  
                            provider: provider,
                            abi: abi,
                            walletAddress: walletAddress,
                            key : key,
                            byteCode: byteCode,
                            gasLimit: gasLimit,
                            gasPrice: gasPrice,
                            args: args,
                            responseToken: responseToken
                        },
                    },
                    'info');
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
                res.end(JSON.stringify({ status: 0, error: error.message }));
        
                deferredRequest(responseToken, 0, error);
                logger.writeLog(
                    {
                        methodName: 'deployContract',
                        callParameters:
                        {  
                            provider: provider,
                            abi: abi,
                            walletAddress: walletAddress,
                            key : key,
                            byteCode: byteCode,
                            gasLimit: gasLimit,
                            gasPrice: gasPrice,
                            args: args,
                            responseToken: responseToken
                        },
                        errorMessage: error.message
                    },
                    'error');
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'deployContract',
                callParameters:
                {  
                    provider: provider,
                    abi: abi,
                    walletAddress: walletAddress,
                    key : key,
                    byteCode: byteCode,
                    gasLimit: gasLimit,
                    gasPrice: gasPrice,
                    args: args,
                    responseToken: responseToken
                },
                errorMessage: err.message
            },
            'error');
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
            value: amount//web3.utils.toWei(amount, "ether")
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
               logger.writeLog(
                    {
                        methodName: 'sendCoinTransaction',
                        callParameters:
                        {  
                            provider: provider,
                            fromWalletAddress: fromWalletAddress,
                            key : key,
                            toWalletAddress: toWalletAddress,
                            amount: amount,
                            gasLimit: gasLimit,
                            gasPrice: gasPrice,
                            responseToken: responseToken
                        },
                    },
                    'info');
            });

            tran.on('receipt', receipt => {
                console.log('reciept');
                console.log(receipt);
                deferredRequest(responseToken, 1, receipt);
            });

            tran.on('error', error => {
                res.end(JSON.stringify({ status: 0, error: error.message }));
        
                deferredRequest(responseToken, 0, error);
                logger.writeLog(
                    {
                        methodName: 'sendCoinTransaction',
                        callParameters:
                        {  
                            provider: provider,
                            fromWalletAddress: fromWalletAddress,
                            key : key,
                            toWalletAddress: toWalletAddress,
                            amount: amount,
                            gasLimit: gasLimit,
                            gasPrice: gasPrice,
                            responseToken: responseToken
                        },
                        errorMessage: error.message
                    },
                    'error');
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'sendCoinTransaction',
                callParameters:
                {  
                    provider: provider,
                    fromWalletAddress: fromWalletAddress,
                    key : key,
                    toWalletAddress: toWalletAddress,
                    amount: amount,
                    gasLimit: gasLimit,
                    gasPrice: gasPrice,
                    responseToken: responseToken
                },
                errorMessage: err.message
            },
            'error');
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
        if (status == 0){
            dataToSend = JSON.stringify({ status: status, error: { responseToken: responseToken, data: data } });
            logger.writeLog(
                {
                    methodName: 'deferredRequest',
                    callParameters:
                    {  
                        responseToken: responseToken,
                        status: status
                    },
                    errorMessage: data
                },
                'error');
        }
        else{
            dataToSend = JSON.stringify({ status: status, data: { responseToken: responseToken, data: data } });
            logger.writeLog(
                {
                    methodName: 'deferredRequest',
                    callParameters:
                    {  
                        responseToken: responseToken,
                        status: status,
                        data: data
                    }
                },
                'info');
        }
        req.write(dataToSend);
        req.end();
    }
}


function callWeb3Method(res, provider, method, args) {
    try {
        web3.setProvider(new web3.providers.HttpProvider(provider));

        web3.eth[method](...args).then(function (result) {
            res.end(JSON.stringify({ status: 1, data: result }));
            logger.writeLog(
                {
                    methodName: 'callWeb3Method',
                    callParameters:
                    {  
                        provider: provider,
                        method: method,
                        args: args,
                        result: result
                    }
                },
                'info');
        }, function (err) {
            console.log(err);
            res.end(JSON.stringify({ status: 0, error: err.message }));
            logger.writeLog(
                {
                    methodName: 'callWeb3Method',
                    callParameters:
                    {  
                        provider: provider,
                        method: method,
                        args: args
                    },
                    error: err.message
                },
                'error');
        });
    }
    catch (err) {
        res.statusCode = 400;
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'callWeb3Method',
                callParameters:
                {  
                    provider: provider,
                    method: method,
                    args: args
                },
                error: err.message
            },
            'error');
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
            logger.writeLog(
                {
                    methodName: 'estimateGasSetMethod',
                    callParameters:
                    {  
                        provider: provider,
                        interface: interface,
                        contractAddress: contractAddress,
                        walletAddress: walletAddress,
                        method: method,
                        amount,amount,
                        args: args,
                        result: result
                    }
                },
                'info');
        }, function (err) {
            console.log(err);
            res.end(JSON.stringify({ status: 0, error: err.message }));
            logger.writeLog(
                {
                    methodName: 'estimateGasSetMethod',
                    callParameters:
                    {  
                        provider: provider,
                        interface: interface,
                        contractAddress: contractAddress,
                        walletAddress: walletAddress,
                        method: method,
                        amount,amount,
                        args: args
                    },
                    error: err.message
                },
                'error');
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'estimateGasSetMethod',
                callParameters:
                {  
                    provider: provider,
                    interface: interface,
                    contractAddress: contractAddress,
                    walletAddress: walletAddress,
                    method: method,
                    amount,amount,
                    args: args
                },
                error: err.message
            },
            'error');
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
                logger.writeLog(
                    {
                        methodName: 'estimateGasDeployContract',
                        callParameters:
                        {  
                            provider: provider,
                            abi: abi,
                            walletAddress: walletAddress,
                            byteCode: byteCode,
                            args: args,
                            result: result
                        }
                    },
                    'info');
            }, function (err) {
                console.log(err);
                res.end(JSON.stringify({ status: 0, error: err.message }));
                logger.writeLog(
                    {
                        methodName: 'estimateGasDeployContract',
                        callParameters:
                        {  
                            provider: provider,
                            abi: abi,
                            walletAddress: walletAddress,
                            byteCode: byteCode,
                            args: args
                        },
                        error: err.message
                    },
                    'error');
            });
        });
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'estimateGasDeployContract',
                callParameters:
                {  
                    provider: provider,
                    abi: abi,
                    walletAddress: walletAddress,
                    byteCode: byteCode,
                    args: args
                },
                error: err.message
            },
            'error');
    }
}


app.post('/callWeb3Method', function (req, res) {
    try {
        callWeb3Method(res, req.body.provider, req.body.name, req.body.args);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));

        logger.writeLog(
            {
                methodName: 'callWeb3Method',
                callParameters:
                {  
                    provider: req.body.provider,
                    name: req.body.name,
                    args: req.body.provider.args
                },
                error: err.message
            },
            'error');
    }
})

app.post('/callContractGetMethod', function (req, res) {
    try {
        callContractGetMethod(res, req.body.provider, req.body.interface, req.body.contractAddress, req.body.name, req.body.args);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));

        logger.writeLog(
            {
                methodName: 'callContractGetMethod',
                callParameters:
                {  
                    provider: req.body.provider,
                    interface: req.body.interface,
                    contractAddress: req.body.contractAddress,
                    name: req.body.name,
                    args: req.body.provider.args
                },
                error: err.message
            },
            'error');
    }
})

app.post('/sendCoinTransaction', function (req, res) {
    try {
        sendCoinTransaction(res, req.body.provider, req.body.fromWalletAddress, req.body.key, req.body.toWalletAddress, req.body.amount
            , req.body.responseToken, req.body.gasLimit, req.body.gasPrice);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'sendCoinTransaction',
                callParameters:
                {  
                    provider: req.body.provider,
                    fromWalletAddress: req.body.fromWalletAddress,
                    contractAddress: req.body.contractAddress,
                    key: req.body.key,
                    toWalletAddress: req.body.toWalletAddress,
                    amount: req.body.amount,
                    responseToken: req.body.responseToken,
                    gasLimit: req.body.gasLimit,
                    gasPrice: req.body.gasPrice
                },
                error: err.message
            },
            'error');
    }
})

app.post('/callContractSetMethod', function (req, res) {
    try {
        callContractSetMethod(res, req.body.provider, req.body.interface, req.body.contractAddress, req.body.walletAddress, req.body.key
            , req.body.name, req.body.amount, req.body.gasLimit, req.body.gasPrice, req.body.args, req.body.responseToken);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'callContractSetMethod',
                callParameters:
                {  
                    provider: req.body.provider,
                    interface: req.body.interface,
                    contractAddress: req.body.contractAddress,
                    walletAddress: req.body.walletAddress,
                    key: req.body.key,
                    name: req.body.name,
                    responseToken: req.body.responseToken,
                    gasLimit: req.body.gasLimit,
                    gasPrice: req.body.gasPrice,
                    args: req.body.args
                },
                error: err.message
            },
            'error');
    }
})

app.post('/deployContract', function (req, res) {
    try {
        deployContract(res, req.body.provider, req.body.walletAddress, req.body.key, req.body.abi, req.body.byteCode, req.body.gasLimit, req.body.gasPrice, req.body.responseToken, req.body.args);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'deployContract',
                callParameters:
                {  
                    provider: req.body.provider,
                    walletAddress: req.body.walletAddress,
                    key: req.body.key,
                    abi: req.body.abi,
                    byteCode : req.body.byteCode,
                    responseToken: req.body.responseToken,
                    gasLimit: req.body.gasLimit,
                    gasPrice: req.body.gasPrice,
                    args: req.body.args
                },
                error: err.message
            },
            'error');
    }
})

app.post('/setDeferredOptions', function (req, res) {
    try {
        hostName = req.body.hostname;
        portNumber = req.body.port;
        responsePath = req.body.path;

        res.end(JSON.stringify({ status: 1, data: "succeeded" }));
        logger.writeLog(
            {
                methodName: 'setDeferredOptions',
                callParameters:
                {  
                    hostName: req.body.hostname,
                    portNumber: req.body.port,
                    responsePath: req.body.path
                }
            },
            'info');
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'setDeferredOptions',
                callParameters:
                {  
                    hostName: req.body.hostname,
                    portNumber: req.body.port,
                    responsePath: req.body.path
                },
                error: err.message
            },
            'error');
    }
})

app.post('/estimateGasDeployContract', function (req, res) {
    try {
        estimateGasDeployContract(res, req.body.provider, req.body.walletAddress
            , req.body.abi, req.body.byteCode, req.body.args);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'estimateGasDeployContract',
                callParameters:
                {  
                    provider: req.body.provider,
                    walletAddress: req.body.walletAddress,
                    abi: req.body.abi,
                    byteCode: req.body.byteCode, 
                    args: req.body.args
                },
                error: err.message
            },
            'error');
    }
})

app.post('/estimateGasSetMethod', function (req, res) {
    try {
        estimateGasSetMethod(res, req.body.provider, req.body.abi, req.body.contractAddress, req.body.walletAddress
            , req.body.name, req.body.amount, req.body.args);
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'estimateGasSetMethod',
                callParameters:
                {  
                    provider: req.body.provider,
                    walletAddress: req.body.walletAddress,
                    abi: req.body.abi,
                    contractAddress:  req.body.contractAddress,
                    name: req.body.name, 
                    amount: req.body.amount,
                    args: req.body.args
                },
                error: err.message
            },
            'error');
    }
})

app.post('/setLogger', function (req, res) {
    try {
        logger.setLogger(req.body.level, req.body.pathToFile);

        res.end(JSON.stringify({ status: 1, data: "succeeded" }));
        logger.writeLog(
            {
                methodName: 'setLogger',
                callParameters:
                {  
                    level: req.body.level,
                    pathToFile: req.body.pathToFile
                }
            },
            'info');
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'setLogger',
                callParameters:
                {  
                    level: req.body.level,
                    pathToFile: req.body.pathToFile
                },
                error: err.message
            },
            'error');
    }
})

app.post('/disableLogger', function (req, res) {
    try {
        logger.disableLogger(req.body.level);

        res.end(JSON.stringify({ status: 1, data: "succeeded" }));

        logger.writeLog(
            {
                methodName: 'disableLogger',
                callParameters:
                {  
                    level: req.body.level
                }
            },
            'info');
    }
    catch (err) {
        res.end(JSON.stringify({ status: 0, error: err.message }));
        logger.writeLog(
            {
                methodName: 'disableLogger',
                callParameters:
                {  
                    level: req.body.level
                },
                error: err.message
            },
            'error');
    }
})

app.listen(3000, 'localhost')
console.log('run');