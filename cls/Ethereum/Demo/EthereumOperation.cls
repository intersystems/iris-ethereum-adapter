Class Ethereum.Demo.EthereumOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "Ethereum.NodeJS.OutboundAdapter";

Property Adapter As Ethereum.NodeJS.OutboundAdapter;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "ContractFolder:Ethereum,Credentials:Ethereum:credentialsSelector,ContractAddress:Ethereum";

Property Credentials As %String;

Property ContractFolder As %String (MAXLEN=1000);

Property ContractABI As %Library.DynamicAbstractObject;

Property ContractBytecode As %String;

Property ContractAddress As %String;

Method GetBalance(pRequest As Ethereum.Demo.BalanceRequest, Output pResponse As Ens.StringContainer) As %Status
{
	try { 
		set address = ##class(Ethereum.Address).%New(pRequest.Account)
		set result = ..Adapter.Eth.GetBalance(address) // result - object of class Ethereum.Wei 
		set pResponse = ##class(Ens.StringContainer).%New(result.ToEther())
	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

Method SendFunds(pRequest As Ethereum.Demo.SendFundsRequest, Output pResponse As Ens.StringContainer) As %Status
{
	try {
	    $$$ThrowOnError(..DeferResponse(.deferred))


        // getting EthereumAccount(wallet) and privateKey
        do ##class(Ens.Config.Credentials).GetCredentialsObj(.cred, "Ethereum.Demo.EthereumOperation", "Ens.Config.Credentials", ..Credentials)
        set account = ##class(Ethereum.Address).%New(cred.Username)
        set privateKey = cred.Password

	    
	    set st = ..Adapter.SendFunds(.result,account,
                            privateKey,
                            ##class(Ethereum.Address).%New(pRequest.ToAddress),
                            ##class(Ethereum.Wei).WeiFromEther(pRequest.Amount),
                            ##class(Ethereum.Wei).%New(2100000),
                            ##class(Ethereum.Wei).%New(1000000000),
                            deferred)
        $$$ThrowOnError(st)
        $$$TRACE(result.%ToJSON())
        
	} catch ex {
	
	}
	return $$$OK
}

Method DeployContract(pRequest As Ethereum.Demo.DeployContractRequest, Output pResponse As Ens.StringContainer) As %Status
{
	try {
		set ..ContractFolder = pRequest.PathToContract
		
		//reading contract ABI
		set fileStream = ##class(%Stream.FileCharacter).%New()
    	set fileStream.Filename = ..ContractFolder_"abi.txt"
    	set ..ContractABI = [].%FromJSON(fileStream)
        
        //reading contract bytecode
        set fileStream = ##class(%Stream.FileCharacter).%New()
        set fileStream.Filename = ..ContractFolder_"bytecode.txt"
        set ..ContractBytecode = fileStream.Read()

		// getting EthereumAccount(wallet) and privateKey
		do ##class(Ens.Config.Credentials).GetCredentialsObj(.cred, "Ethereum.Demo.EthereumOperation", "Ens.Config.Credentials", ..Credentials)
		set account = ##class(Ethereum.Address).%New(cred.Username)
		set privateKey = cred.Password
		
		// get deployContract object
		set deployContract = ..Adapter.GetDeployContract(..ContractABI, ..ContractBytecode)
		do deployContract.SetOptions(account, privateKey,
                                    ##class(Ethereum.Wei).%New(1000000000), // 1Gwei 
                                    ##class(Ethereum.Wei).%New(2100000))

        // get Estimated Gas for this transaction
        set gasJSON = deployContract.EstimateGas("test") // test - contract constuctor arg
        set gas = gasJSON.gas
        $$$TRACE(gas)
        
        //deploy contract             
        do deployContract.SetOptions(account, privateKey,
                                    ##class(Ethereum.Wei).%New(1000000000), // 1Gwei 
                                    ##class(Ethereum.Wei).%New(gas))              
        
        set result = deployContract.Deploy("test") // test - contract constuctor arg
        set pResponse = ##class(Ens.StringContainer).%New(result.transactionHash)
		
	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

Method SetName(pRequest As Ethereum.Demo.SetNameRequest, Output pResponse As Ens.StringContainer) As %Status
{
	try {
	    $$$ThrowOnError(..Adapter.SetDeferredOptions())
	
        // getting EthereumAccount(wallet) and privateKey
		do ##class(Ens.Config.Credentials).GetCredentialsObj(.cred, "Ethereum.Demo.EthereumOperation", "Ens.Config.Credentials", ..Credentials)
		set account = ##class(Ethereum.Address).%New(cred.Username)
		set privateKey = cred.Password	
		
		//reading contract ABI
		set fileStream = ##class(%Stream.FileCharacter).%New()
    	set fileStream.Filename = ..ContractFolder_"abi.txt"
    	set ..ContractABI = [].%FromJSON(fileStream)			
		
		// get contract object
		set contract = ..Adapter.GetContract(##class(Ethereum.Address).%New(..ContractAddress),..ContractABI)
        $$$ThrowOnError(..DeferResponse(.deferred))

        // estimate gas
        do contract.SetOptions(account)
        set gasJSON = contract.EstimateGas("setName",pRequest.Name)
        $$$TRACE(gasJSON.gas)
        
        do contract.SetOptions(account, privateKey,
                               ##class(Ethereum.Wei).%New(1000000000), 
                               ##class(Ethereum.Wei).%New(100*gasJSON.gas),,deferred)                              
            
        set result = contract.setName(pRequest.Name) 
        $$$TRACE(result.transactionHash)

	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

Method Hello(pRequest As Ethereum.Demo.HelloRequest, Output pResponse As Ens.StringContainer) As %Status
{
	try {
		//reading contract ABI
		set fileStream = ##class(%Stream.FileCharacter).%New()
    	set fileStream.Filename = ..ContractFolder_"abi.txt"
    	set ..ContractABI = [].%FromJSON(fileStream)			
		
		set contract = ..Adapter.GetContract(##class(Ethereum.Address).%New(..ContractAddress),..ContractABI)
        set result = contract.hello()
        set pResponse = ##class(Ens.StringContainer).%New(result.args)
	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ethereum.Demo.BalanceRequest"> 
		<Method>GetBalance</Method>
	</MapItem>
	<MapItem MessageType="Ethereum.Demo.DeployContractRequest"> 
		<Method>DeployContract</Method>
	</MapItem>
	<MapItem MessageType="Ethereum.Demo.SetNameRequest"> 
		<Method>SetName</Method>
	</MapItem>	
	<MapItem MessageType="Ethereum.Demo.HelloRequest"> 
		<Method>Hello</Method>
	</MapItem>	
    <MapItem MessageType="Ethereum.Demo.SendFundsRequest"> 
        <Method>SendFunds</Method>
    </MapItem>  
	
			
</MapItems>
}

}
