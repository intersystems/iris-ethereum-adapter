Class Ethereum.NodeJS.OutboundAdapter extends EnsLib.HTTP.OutboundAdapter
{

    Parameter CHARSET = "UTF-8"; 

    Parameter SETTINGS = "Provider:Ethereum,DeferredResponseHost:Ethereum,DeferredResponsePort:Ethereum,DeferredResponsePath:Ethereum,LoggerLevel:Ethereum,LoggerFolder:Ethereum";
    
    /// Enter full path to http provider you use to connect to Ethereum network<br><br>
    /// https://*network*.infura.io/*your-api-key*<br>
    /// get *your-api-key* at https://infura.io/<br>
    /// and choose *network* here https://infura.io/docs/gettingStarted/chooseaNetwork
    Property Provider;  
    
    /// Deferred Response Host (e.g. localhost), IRIS web-server host, where IRIS is ready to receive requests
    Property DeferredResponseHost [InitialExpression = "" ];
    
    /// Deferred Response Port (e.g. 57772), IRIS web-server port
    Property DeferredResponsePort [InitialExpression = "" ];
    
    /// Deferred Response Path (e.g. /eth/deferred), full path, including IRIS web-app (/eth) and routing path (/deferred)
    Property DeferredResponsePath [InitialExpression = "" ];
    
    /// Set Nodejs module error logger level
    /// E - errors in errors.log, 
    /// A - all requests in access.log,
    /// EA - both
    Property LoggerLevel; 
    
    /// path to folder for Nodejs module logs
    Property LoggerFolder [InitialExpression = "log" ];
    
    
     
    Property Eth As Ethereum.Eth;
    
    Method OnInit() As %Status
    {
        set ..Eth = ##class(Ethereum.Eth).%New($this)
        return:('$isObject(..Eth)) $$$ERROR($$$GeneralError, "Unable to create Eth object") 
        do ..SetDeferredOptions()
        do ..SetLoggerOptions()
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
	
	Method SetLoggerOptions() As %Status
	{
	    set (tSCi,tSCe) = 1
	    if (..LoggerLevel["E") {
	        set data = {
	            "level":"error",
                "pathToFile":(..LoggerFolder_"/errors.log")
            }
            set tSCe = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/setLogger",data.%ToJSON()))
            $$$TRACE(data.%ToJSON())
        }
        if (..LoggerLevel["A") {
            set data = {
                "level":"access",
                "pathToFile":(..LoggerFolder_"/access.log")
            }
            set tSCi = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/setLogger",data.%ToJSON()))
            $$$TRACE(data.%ToJSON())
        }
        return $$$ADDSC(tSCi,tSCe)
		
	}
	
	Method SetDeferredOptions() As %Status
	{
		set data = {
		    "hostname":(..DeferredResponseHost),
		    "port":(..DeferredResponsePort),
		    "path":(..DeferredResponsePath)
		}
		set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/setDeferredOptions",data.%ToJSON()))
		$$$TRACE(data.%ToJSON())
        return tSC
	} 
	
	Method CallWeb3Method(Output response As %Library.DynamicArray, method As %String, params As %Library.DynamicArray) As %Status 
	{
	    set response = {}
        set data = {
            "provider": (..Provider),
            "name": (method),
            "args":(params)
        }   
        $$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/callWeb3Method",data.%ToJSON()))
		if ($$$ISERR(tSC)) {
		    if ( $isobject(pHttpResponse)&&(pHttpResponse.StatusCode="400")) {
		        set err = {}.%FromJSON(pHttpResponse.Data)
		        set tSC = $$$ERROR($$$GeneralError, err.error)
		    } 
		    set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
            throw exCustom
		} else {
		    set response = {}.%FromJSON(pHttpResponse.Data)
		}
		$$$TRACE("adapter"_response.%ToJSON())
		return tSC
	}

    Method SendFunds(Output jsonResponse as %Library.DynamicObject, accountAddress as Ethereum.Address, accountKey as %String,
                        toAddress as Ethereum.Address, amount as Ethereum.Wei, 
                        gasLimit as Ethereum.Wei, gasPrice as Ethereum.Wei, deferred as %String) as %Status
    {
        set jsonResponse = {}
        set data = {
            "provider":(..Provider),
            "fromWalletAddress":(accountAddress.Address),
            "key":(accountKey),
            "toWalletAddress":(toAddress.Address),
            "amount":(amount.WeiGet()),
            "responseToken":(deferred),
            "gasLimit":(gasLimit.WeiGet()),
            "gasPrice":(gasPrice.WeiGet())
        }
        $$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/sendCoinTransaction",data.%ToJSON()))
        if ($$$ISOK(tSC)) {
            set res = {}.%FromJSON(pHttpResponse.Data)
            $$$TRACE(res.%ToJSON())
            if (res.status'=1) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_res.error))
            }
            set jsonResponse = res.data
        } else {
            set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
        }
        return tSC

    } 

	Method DeployContract(Output jsonResponse as %Library.DynamicObject, accountAddress as Ethereum.Address, accountKey as %String,
	                        abi as %Library.DynamicArray, byteCode as %String, gasLimit as Ethereum.Wei, gasPrice as Ethereum.Wei, 
	                        params as %Library.DynamicArray,
	                        deferred as %String) as %Status
	{
	    set jsonResponse = {}
		set data = {
		    "provider": (..Provider),
		    "walletAddress": (accountAddress.Address),
		    "key":(accountKey),
            "gasLimit":(gasLimit.WeiGet()),
            "gasPrice":(gasPrice.WeiGet()),
            "args": (params),
            "responseToken":(deferred),		    
		    "abi":(abi),
		    "byteCode":(byteCode)
		}
		$$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/deployContract",data.%ToJSON()))
        if ($$$ISOK(tSC)) {
            set res = {}.%FromJSON(pHttpResponse.Data)
            $$$TRACE(res.%ToJSON())
            if (res.status'=1) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_res.error))
            }
            set jsonResponse = res.data
        } else {
            set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
        }
        return tSC
	}
	
    Method EstimateGasDeployContract(Output jsonResponse as %Library.DynamicObject,
                                        accountAddress as Ethereum.Address,
                                        abi as %Library.DynamicArray, 
                                        byteCode as %String,
                                        params as %Library.DynamicArray)
    {
        set jsonResponse = {}
        set data = {
           "provider": (..Provider),
           "walletAddress": (accountAddress.Address),
           "abi":(abi),
           "byteCode":(byteCode),
           "args":(params)
        }
        $$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/estimateGasDeployContract",data.%ToJSON()))
        if ($$$ISOK(tSC)) {
            set res = {}.%FromJSON(pHttpResponse.Data)
            $$$TRACE(res.%ToJSON())
            if (res.status'=1) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_res.error))
            }
            set jsonResponse = res.data
        } else {
            set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
        }
        return tSC
    }
    
    Method EstimateGasSetMethod(Output jsonResponse as %Library.DynamicObject,
                                        abi as %Library.DynamicArray, 
                                        contractAddress As Ethereum.Address,
                                        accountAddress as Ethereum.Address,                                        
                                        contractMethod as %String,
                                        amount as Ethereum.Wei,
                                        params as %Library.DynamicArray)
    {
        set jsonResponse = {}
        set data = {
           "provider": (..Provider),
           "contractAddress":(contractAddress.Address),
           "walletAddress": (accountAddress.Address),
           "name":(contractMethod),
           "args":(params),
           "abi":(abi)
        }
        if ($G(amount) && amount.WeiGet()>0) {
            set data.amount = amount.WeiGet()
        }      
        $$$TRACE(data.%ToJSON())
        set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/estimateGasSetMethod",data.%ToJSON()))
        
        if ($$$ISOK(tSC)) {
            set res = {}.%FromJSON(pHttpResponse.Data)
            $$$TRACE(res.%ToJSON())
            if (res.status'=1) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_res.error))
            }
            set jsonResponse = res.data
        } else {
            set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
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
	    set jsonResponse = {}
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
		$$$TRACE(data.%ToJSON())
		set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/callContractSetMethod",data.%ToJSON()))
		if ($$$ISOK(tSC)) {
			set res = {}.%FromJSON(pHttpResponse.Data)
			$$$TRACE(res.%ToJSON())
			if (res.status'=1) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_res.error))
            }
            set jsonResponse = res.data
		} else {
		    set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
            throw exCustom
		}
		return tSC
	}
	
	/// contractAddress - contract address 
	/// contractMethod - method name
	/// params - json array with method params
	Method CallContractGetMethod(output jsonResponse as %Library.DynamicObject, abi as %Library.DynamicArray,
								contractAddress as Ethereum.Address, contractMethod as %String, params as %Library.DynamicArray) as %Status 
	{
	    set jsonResponse = {}
		set data = {
			"provider": (..Provider),
			"interface": (abi),
			"name": (contractMethod),
			"contractAddress": (contractAddress.Address),
			"args": (params)
		}
		$$$TRACE(data.%ToJSON())
		set tSC = ..SendFormDataArray(.pHttpResponse, "POST", ..GetRequest(..URL_"/callContractGetMethod",data.%ToJSON()))
		if ($$$ISOK(tSC)) {
            set res = {}.%FromJSON(pHttpResponse.Data)

            $$$TRACE(res.%ToJSON())

            if (res.status'=1) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_res.error))
            }
            set jsonResponse = res.data
        } else {
            set exCustom = ##class(%Exception.StatusException).CreateFromStatus(tSC)
            do exCustom.Log()
            throw exCustom
        }
		return tSC
	}
								
}