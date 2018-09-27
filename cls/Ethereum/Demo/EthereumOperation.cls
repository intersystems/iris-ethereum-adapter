Class Ethereum.Demo.EthereumOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "Ethereum.NodeJS.OutboundAdapter";

Property Adapter As Ethereum.NodeJS.OutboundAdapter;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "ContractFolder:Ethereum,Credentials:Ethereum:credentialsSelector,ContractAddress:Ethereum";

Property Credentials As %String;

Property ContractFolder As %String;

Property ContractABI As %Library.DynamicAbstractObject;

Property ContractBytecode As %String;

Property ContractAddress As %String;

Method GetBalance(pRequest As Ethereum.Demo.BalanceRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try { 
		set address = ##class(Ethereum.Address).%New(pRequest.Account)
		set result = ..Adapter.Eth.GetBalance(address) // result - object of class Ethereum.Wei 
		set pResponse = ##class(Ens.StringResponse).%New(result.ToEther())
	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

Method DeployContract(pRequest As Ethereum.Demo.DeployContractRequest, Output pResponse As Ens.StringResponse) As %Status
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

        //deploy contract                           
        set result = deployContract.Deploy()
        set pResponse = ##class(Ens.StringResponse).%New(result.transactionHash)
		
	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

Method SetName(pRequest As Ethereum.Demo.SetNameRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try {
        // getting EthereumAccount(wallet) and privateKey
		do ##class(Ens.Config.Credentials).GetCredentialsObj(.cred, "Ethereum.Demo.EthereumOperation", "Ens.Config.Credentials", ..Credentials)
		set account = ##class(Ethereum.Address).%New(cred.Username)
		set privateKey = cred.Password	
		
		//reading contract ABI
		set fileStream = ##class(%Stream.FileCharacter).%New()
    	set fileStream.Filename = ..ContractFolder_"abi.txt"
    	set ..ContractABI = [].%FromJSON(fileStream)			
		
		// get contract object
		$$$TRACE(..ContractAddress)
		set contract = ..Adapter.GetContract(##class(Ethereum.Address).%New(..ContractAddress),..ContractABI)
        $$$ThrowOnError(..DeferResponse(.deferred))

        do contract.SetOptions(account, privateKey,
                               ##class(Ethereum.Wei).%New(1000000000), 
                               ##class(Ethereum.Wei).%New(2100000),,deferred)
            
        set result = contract.setName(pRequest.Name) 
        $$$TRACE(result.transactionHash)

	} catch ex {
		return ex.AsStatus()
	}
	return $$$OK
}

Method Hello(pRequest As Ethereum.Demo.HelloRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try {
		//reading contract ABI
		set fileStream = ##class(%Stream.FileCharacter).%New()
    	set fileStream.Filename = ..ContractFolder_"abi.txt"
    	set ..ContractABI = [].%FromJSON(fileStream)			
		
		set contract = ..Adapter.GetContract(##class(Ethereum.Address).%New(..ContractAddress),..ContractABI)
        set result = contract.hello()
        set pResponse = ##class(Ens.StringResponse).%New(result.args)
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
</MapItems>
}

}