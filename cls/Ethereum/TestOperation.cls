Class Ethereum.TestOperation extends Ens.BusinessOperation {

Parameter ADAPTER = "Ethereum.NodeJS.OutboundAdapter";

Property Adapter As Ethereum.NodeJS.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method Test(pInput As Ens.StringRequest, Output pOutput As Ens.StringResponse) As %Status
{
    try {
        #dim contract as Ethereum.Contract
        #dim deployContract as Ethereum.DeployContract
    
        /*** set your account information here ***/
        set account = ""
        set privateKey = ""
    
        
        set contractABI = [{"constant":true,"inputs":[],"name":"hello","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getPersons","outputs":[{"name":"","type":"address[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_address","type":"address"}],"name":"getPerson","outputs":[{"name":"age","type":"uint256"},{"name":"fName","type":"bytes16"},{"name":"lName","type":"bytes16"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_address","type":"address"},{"name":"_age","type":"uint256"},{"name":"_fName","type":"bytes16"},{"name":"_lName","type":"bytes16"}],"name":"setPerson","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"countPersons","outputs":[{"name":"count","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"personAddresses","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"newName","type":"string"}],"name":"setName","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"name":"fName","type":"bytes16"},{"indexed":false,"name":"lName","type":"bytes16"},{"indexed":false,"name":"age","type":"uint256"}],"name":"setPersonInfo","type":"event"}]
        set contractByteCode = "0x6080604052336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550610bb6806100536000396000f300608060405260043610610083576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806319ff1d21146100885780634c6b6c6f14610118578063552d2d5c14610184578063a110034a14610235578063ae8562ee146102bc578063b83ce111146102e7578063c47f002714610354575b600080fd5b34801561009457600080fd5b5061009d6103bd565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100dd5780820151818401526020810190506100c2565b50505050905090810190601f16801561010a5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561012457600080fd5b5061012d61049d565b6040518080602001828103825283818151815260200191508051906020019060200280838360005b83811015610170578082015181840152602081019050610155565b505050509050019250505060405180910390f35b34801561019057600080fd5b506101c5600480360381019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061052b565b60405180848152602001836fffffffffffffffffffffffffffffffff19166fffffffffffffffffffffffffffffffff19168152602001826fffffffffffffffffffffffffffffffff19166fffffffffffffffffffffffffffffffff19168152602001935050505060405180910390f35b34801561024157600080fd5b506102ba600480360381019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291908035906020019092919080356fffffffffffffffffffffffffffffffff1916906020019092919080356fffffffffffffffffffffffffffffffff19169060200190929190505050610640565b005b3480156102c857600080fd5b506102d16108af565b6040518082815260200191505060405180910390f35b3480156102f357600080fd5b50610312600480360381019080803590602001909291905050506108bc565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561036057600080fd5b506103bb600480360381019080803590602001908201803590602001908080601f01602080910402602001604051908101604052809392919081815260200183838082843782019150505050505091929192905050506108fa565b005b60606104986040805190810160405280600b81526020017f48656c6c6f206e616d652100000000000000000000000000000000000000000081525060038054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561048e5780601f106104635761010080835404028352916020019161048e565b820191906000526020600020905b81548152906001019060200180831161047157829003601f168201915b5050505050610914565b905090565b6060600280548060200260200160405190810160405280929190818152602001828054801561052157602002820191906000526020600020905b8160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190600101908083116104d7575b5050505050905090565b6000806000600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000154600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060010160009054906101000a900470010000000000000000000000000000000002600160008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060010160109054906101000a9004700100000000000000000000000000000000029250925092509193909250565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561069d57600080fd5b600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020905060008160010160009054906101000a905050601060ff16148015610716575060008160010160109054906101000a905050601060ff16145b8015610726575060008160000154145b156107925760028590806001815401808255809150509060018203906000526020600020016000909192909190916101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550505b838160000181905550828160010160006101000a8154816fffffffffffffffffffffffffffffffff021916908370010000000000000000000000000000000090040217905550818160010160106101000a8154816fffffffffffffffffffffffffffffffff0219169083700100000000000000000000000000000000900402179055507f9f7d1862d9a9a2433162e143f6d23cf178e55ef64fe3d6639eb1520de064613a83838660405180846fffffffffffffffffffffffffffffffff19166fffffffffffffffffffffffffffffffff19168152602001836fffffffffffffffffffffffffffffffff19166fffffffffffffffffffffffffffffffff19168152602001828152602001935050505060405180910390a15050505050565b6000600280549050905090565b6002818154811015156108cb57fe5b906000526020600020016000915054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b8060039080519060200190610910929190610ae5565b5050565b606080606080606060008088955087945084518651016040519080825280601f01601f19166020018201604052801561095c5781602001602082028038833980820191505090505b50935083925060009150600090505b8551811015610a1e57858181518110151561098257fe5b9060200101517f010000000000000000000000000000000000000000000000000000000000000090047f01000000000000000000000000000000000000000000000000000000000000000283838060010194508151811015156109e157fe5b9060200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a905350808060010191505061096b565b600090505b8451811015610ad6578481815181101515610a3a57fe5b9060200101517f010000000000000000000000000000000000000000000000000000000000000090047f0100000000000000000000000000000000000000000000000000000000000000028383806001019450815181101515610a9957fe5b9060200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a9053508080600101915050610a23565b82965050505050505092915050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f10610b2657805160ff1916838001178555610b54565b82800160010185558215610b54579182015b82811115610b53578251825591602001919060010190610b38565b5b509050610b619190610b65565b5090565b610b8791905b80821115610b83576000816000905550600101610b6b565b5090565b905600a165627a7a72305820888dec3050b56b4da71530714a4e39364f057deacc8eb4d5d6537f73e3fadfb80029"
       
        /*** change next line after deploy contract ***/
        set contractAddress = ""
        
        set accountAddress = ""
        set accountKey = ""
        set accountAddress2 = ""
        
        if (pInput.StringValue = "Send") {
            $$$TRACE("Send fund")
            $$$ThrowOnError(..DeferResponse(.deferred))
            $$$ThrowOnError(..Adapter.SendFunds(.result,##class(Ethereum.Address).%New(accountAddress),accountKey,##class(Ethereum.Address).%New(accountAddress2),##class(Ethereum.Wei).WeiFromEther(2),##class(Ethereum.Wei).%New(1000000000),##class(Ethereum.Wei).%New(2100000),deferred))
            $$$TRACE(result.%ToJSON())
            
        } elseif (pInput.StringValue = "Deploy") {

            $$$TRACE("Deploy contract")
            /*set deployContract = ..Adapter.GetDeployContract(contractABI.%ToJSON(),contractByteCode)
            do deployContract.SetOptions(##class(Ethereum.Address).%New(account),
                                    privateKey,
                                    ##class(Ethereum.Wei).%New(1000000000), 
                                    ##class(Ethereum.Wei).%New(2100000))*/
            
            
            /// alternative way to pass arguments (2 lines above and 1 line below are equivalent)
            /// vvv                       
            set deployContract = ..Adapter.GetDeployContract(contractABI,contractByteCode,{"account":(account), "key":(privateKey), "gas":1000000000,"gasLimit":2100000})                        
                                    
            $$$ThrowOnError(..DeferResponse(.deferred))
            set result = deployContract.Deploy(deferred)
            $$$TRACE(result.%ToJSON())
            
        } elseif (pInput.StringValue = "SetName") {
            
            $$$TRACE("SetName")
            set contract = ..Adapter.GetContract(##class(Ethereum.Address).%New(contractAddress),contractABI.%ToJSON())
            $$$ThrowOnError(..DeferResponse(.deferred))
            do contract.SetOptions(##class(Ethereum.Address).%New(account),
                                    privateKey,
                                    ##class(Ethereum.Wei).%New(1000000000), 
                                    ##class(Ethereum.Wei).%New(2100000),,deferred)
            
            set result = contract.setName("New Name") // input your name
            $$$TRACE(result.%ToJSON())
            
        } elseif (pInput.StringValue = "Hello") {
            
            $$$TRACE("Hello")
            set contract = ..Adapter.GetContract(##class(Ethereum.Address).%New(contractAddress),contractABI.%ToJSON())
            set result = contract.hello()
            $$$TRACE(result.%ToJSON())
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = result.%ToJSON()
        } elseif (pInput.StringValue = "BlockNumber") {
            $$$TRACE("BlockNumber")
            set blockNumber = ..Adapter.Eth.GetBlockNumber()
            $$$TRACE(blockNumber)
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = blockNumber

        } elseif (pInput.StringValue = "GetBalance") {
            $$$TRACE("GetBalance")

            // balance of the account in the first ethereum block
            set balance = ..Adapter.Eth.GetBalance(##class(Ethereum.Address).%New("0xa0952608fc792a227c186d6aeb82e178032daefc"),1)
            $$$TRACE("initial balance "_balance.ToEther())


            set balance = ..Adapter.Eth.GetBalance(##class(Ethereum.Address).%New("0x81b7E08F65Bdf5648606c89998A9CC8164397647"))
            $$$TRACE("current balance "_balance.ToEther())

            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = balance.ToEther()
            
        } elseif (pInput.StringValue = "GetBlock") {
            $$$TRACE("GetBlock")
            set block = ..Adapter.Eth.GetBlock("latest",1)
            $$$TRACE(block.%ToJSON())
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = block.%ToJSON()
        } elseif (pInput.StringValue = "GasPrice") {
            #dim gas as Ethereum.Wei
            $$$TRACE("GasPrice")
            set gas = ..Adapter.Eth.GetGasPrice()
            $$$TRACE("wei: "_gas.WeiGet()_"; eth: "_gas.ToEther())
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = gas.WeiGet()
        } elseif ( pInput.StringValue = "GetStorageAt") {
            set storage = ..Adapter.Eth.GetStorageAt(##class(Ethereum.Address).%New("0xed63630279b510ad8a54b50a37488c3b343ce14d"),0)
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = storage
        } elseif ( pInput.StringValue = "GetCode") {
            set code = ..Adapter.Eth.GetCode(##class(Ethereum.Address).%New("0xed63630279b510ad8a54b50a37488c3b343ce14d"))
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = code
        } elseif ( pInput.StringValue = "GetBlockTransactionCount") {
            set txnum = ..Adapter.Eth.GetBlockTransactionCount()
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = txnum
        } elseif ( pInput.StringValue = "GetTransaction") {
            set transaction = ..Adapter.Eth.GetTransaction("0x88c1bd22180d2cad98f08849a10033f06ad8b7da94169e1fa8802377fabf1369")
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = transaction.%ToJSON()
        } elseif ( pInput.StringValue = "GetTransactionFromBlock") {
            set transaction = ..Adapter.Eth.GetTransactionFromBlock()
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = transaction.%ToJSON()
        } elseif ( pInput.StringValue = "GetTransactionReceipt") {
            set transaction = ..Adapter.Eth.GetTransactionReceipt("0x88c1bd22180d2cad98f08849a10033f06ad8b7da94169e1fa8802377fabf1369")
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = transaction.%ToJSON()
        } elseif ( pInput.StringValue = "GetTransactionCount") {
            set num = ..Adapter.Eth.GetTransactionCount(##class(Ethereum.Address).%New("0x52033646a5688528c5e9ba14ddb55ec98b6a384f"))
            set pOutput = ##class(Ens.StringResponse).%New()
            set pOutput.StringValue = num
        }


    } catch ex {
        #dim ex as %Exception.AbstractException
        return ex.AsStatus() 
    }
	return $$$OK
}

XData MessageMap {
<MapItems>
    <MapItem MessageType="Ens.StringRequest">
        <Method>Test</Method>
    </MapItem>
</MapItems>
}

}