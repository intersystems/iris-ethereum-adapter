Class Ethereum.NodeJS.OutboundAdapter extends EnsLib.HTTP.OutboundAdapter
{

    Parameter CHARSET = "UTF-8";

    Parameter SETTINGS = "Provider:Ethereum,DeferredResponseHost:Ethereum,DeferredResponsePort:Ethereum,DeferredResponsePath:Ethereum";
    
    /// Enter full path to http provider you use to connect to Ethereum network
    /// https://<network>.infura.io/<your-api-key>
    /// get <your-api-key> at https://infura.io/
    /// and choose <network> here https://infura.io/docs/gettingStarted/chooseaNetwork
    Property Provider;  
    
    // Deferred Response Host (e.g. localhost), IRIS web-server host, where IRIS is ready to receive requests
    Property DeferredResponseHost [InitialExpression = "" ];
    
    // Deferred Response Port (e.g. 57772), IRIS web-server port
    Property DeferredResponsePort [InitialExpression = "" ];
    
    // Deferred Response Path (e.g. /eth/deferred), full path, including IRIS web-app (/eth) and routing path (/deferred)
    Property DeferredResponsePath [InitialExpression = "" ];
     
    Property Eth As Ethereum.Eth;
    
    Method OnInit() As %Status
    {
        set ..Eth = ##class(Ethereum.Eth).%New($this)
        return:('$isObject(..Eth)) $$$ERROR($$$GeneralError, "Unable to create Eth object") 
        do ..SetDeferredOptions()
        return $$$OK
    }
    
	Method GetContract(address as Ethereum.Address = "", abi as %String= "", options as %Library.DynamicObject = "") as Ethereum.Contract
	{
		set contract = ##class(Ethereum.Contract).%New($this, address, abi, options)
		if ('$IsObject(contract)) {
		   throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Unable to create Contract object"))
		}
		return contract
	}
	
	Method GetDeployContract(abi as %String="", byteCode as %String, options as %Library.DynamicObject="") as Ethereum.DeployContract
	{
		set contract = ##class(Ethereum.DeployContract).%New($this, abi, byteCode, options)	
        if ('$IsObject(contract)) {
           throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Unable to create DeployContract object"))
        }
        return contract
	}
	
	/// Helper method
	Method GetRequest(location,data) as %Net.HttpRequest [Private ]
	{
		set request = ##class(%Net.HttpRequest).%New()
		set request.ContentType = "application/json" 
		set request.Location=$e(location,2,$l(location)) 
		do request.EntityBody.Write(data)
		quit request
	}
	
	Method SetDeferredOptions() As %Status
	{
		set data = {
		    "hostname":(..DeferredResponseHost),
		    "port":(..DeferredResponsePort),
		    "path":(..DeferredResponsePath)
		}
		set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/setDeferredOptions",data.%ToJSON()))
        return tSC
	} 
	
	Method CallWeb3Method(Output response, method As %String, params As %Library.DynamicArray) As %Status {
        set data = {
            "provider": (..Provider),
            "name": (method),
            "args":(params)
        }   
        $$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/callWeb3Method",data.%ToJSON()))
		if ($$$ISERR(tSC)) {
		    if (pHttpResponse.StatusCode="400") {
		        set err = {}.%FromJSON(pHttpResponse.Data)
		        set tSC = $$$ERROR($$$GeneralError, err.message)
		    } 
		} else {
            if ($isobject(pHttpResponse.Data)) {
                set response = pHttpResponse.Data.Read()
            } else {
                set response = pHttpResponse.Data
            }
		}
		return tSC
	}

    Method SendFunds(Output jsonResponse as %Library.DynamicObject, accountAddress as Ethereum.Address, accountKey as %String,
                        toAddress as Ethereum.Address, amount as Ethereum.Wei, 
                        gasLimit as Ethereum.Wei, gasPrice as Ethereum.Wei, deferred as %String) as %Status
    {
        set data = {
            "provider":(..Provider),
            "fromWalletAddress":(accountAddress.Address),
            "key":(accountKey),
            "toWalletAddress":(toAddress.Address),
            "amount":(amount.ToEther()),
            "responseToken":(deferred),
            "gasLimit":(gasLimit.WeiGet()),
            "gasPrice":(gasPrice.WeiGet())
        }
        $$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/sendCoinTransaction",data.%ToJSON()))
        if ($$$ISOK(tSC)) {
            set jsonResponse = {"result":(pHttpResponse.Data.Read())}
        }
        return tSC

    } 

	Method DeployContract(Output jsonResponse as %Library.DynamicObject, accountAddress as Ethereum.Address, accountKey as %String,
	                        abi as %Library.DynamicArray, byteCode as %String, gasLimit as Ethereum.Wei, gasPrice as Ethereum.Wei, deferred as %String) as %Status
	{
		set data = {
		    "provider": (..Provider),
		    "walletAddress": (accountAddress.Address),
		    "key":(accountKey),
		    "abi":(abi),
		    "byteCode":(byteCode),
		    "gasLimit":(gasLimit.WeiGet()),
		    "gasPrice":(gasPrice.WeiGet()),
		    "responseToken":(deferred)
		}
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/deployContract",data.%ToJSON()))
        if ($$$ISOK(tSC)) {
            set jsonResponse = {}.%FromJSON(pHttpResponse.Data.Read())
        }
        return tSC

	}
	
	/// accountAddress -  wallet address,
	/// accountKey - private key
	/// contractAddress - contract address 
	/// contractMethod - method name
	/// params - json array with method params
	Method CallContractSetMethod(output jsonResponse as %Library.DynamicObject, 
	                            abi as %Library.DynamicArray, contractAddress as Ethereum.Address,
	                            accountAddress as Ethereum.Address, accountKey as %String, 
								contractMethod as %String, amount as Ethereum.Wei, 
								gasLimit as Ethereum.Wei, gasPrice as Ethereum.Wei,
								params as %Library.DynamicArray,
								deferred as %String) as %Status 
	{
		set data = {
			"provider": (..Provider),
			"contractAddress": (contractAddress.Address),
            "walletAddress": (accountAddress.Address),
            "key": (accountKey),
			"name": (contractMethod),
			"gasLimit":(gasLimit.WeiGet()),
            "gasPrice":(gasPrice.WeiGet()),
			"args": (params),
			"responseToken":(deferred),
			"interface": (abi)
		}
		if ($G(amount) && amount.WeiGet()>0) {
			set data.amount = amount.WeiGet()
		}
		set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/callContractSetMethod",data.%ToJSON()))
		if ($$$ISOK(tSC)) {
			set jsonResponse = {}.%FromJSON(pHttpResponse.Data)
		} else {
		    set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
		}
		return tSC
	}
	
	/// contractAddress - contract address 
	/// contractMethod - method name
	/// params - json array with method params
	Method CallContractGetMethod(output jsonResponse as %Library.DynamicObject, abi as %Library.DynamicArray,
								contractAddress as Ethereum.Address, contractMethod as %String, params as %Library.DynamicArray) as %Status 
	{
		set data = {
			"provider": (..Provider),
			"interface": (abi),
			"name": (contractMethod),
			"contractAddress": (contractAddress.Address),
			"args": (params)
		}
		set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/callContractGetMethod",data.%ToJSON()))
		if ($$$ISOK(tSC)) {
            set jsonResponse = {}.%FromJSON(pHttpResponse.Data)
        } else {
            set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
        }
		return tSC
	}
								
}