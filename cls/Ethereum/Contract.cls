include Ensemble

Class Ethereum.Contract Extends %RegisteredObject
{
	Property Address as Ethereum.Address;
	
	Property ABI as %Library.DynamicArray;
	
	Property Methods [ Multidimensional, Private ];
	
	Property FromAccount as Ethereum.Address [Private];
	
	Property FromPrivateKey as %String [Private];
	
	Property GasPrice as Ethereum.Wei [Private ];
	
	Property GasLimit as Ethereum.Wei [Private ];
    
    Property Amount as Ethereum.Wei [Private ];
	
	Property Adapter as Ethereum.NodeJS.OutboundAdapter;
	
	Property Deferred as %String;
	
	Method SetOptions(account as Ethereum.Address, key as %String="", gas as Ethereum.Wei = "", 
	                    gasLimit as Ethereum.Wei = "", amount as Ethereum.Wei = "", deferred as %String = "") as %Status
	{
	    if ('$data(account)) {
	        return $$$ERROR($$$GeneralError, "account argument required")
	    }
	    if ('$IsObject(account) || (account.%ClassName(1)'="Ethereum.Address")) {
	        return $$$ERROR($$$GeneralError, "account argument must be an object Ethereum.Address")
	    }
	    set ..FromAccount = account
	    set ..FromPrivateKey = key
	    
	    if (gas="") {
            set ..GasPrice = ##class(Ethereum.Wei).%New(0)
        } else {
            set ..GasPrice = gas
        }
        
        if (gasLimit="") {
            set ..GasLimit = ##class(Ethereum.Wei).%New(0)
        } else {
            set ..GasLimit = gasLimit
        }        
	    
	    if (amount="") {
	        set ..Amount = ##class(Ethereum.Wei).%New(0)
	    } else {
	        set ..Amount = amount
	    }
	    set ..Deferred = deferred
	    return $$$OK
	}
	
    Method SetDeferred(deferred as %String = "") As %Status
    {
        set ..Deferred = deferred
        return $$$OK
    }	
	
	Method ClearOptions() as %Status
	{
	    set ..FromAccount = ""
        set ..FromPrivateKey = ""
        set ..GasPrice = ##class(Ethereum.Wei).%New(0)
        set ..GasLimit = ##class(Ethereum.Wei).%New(0)
        set ..Amount = ##class(Ethereum.Wei).%New(0)
        set ..Deferred = ""
        return $$$OK
	}
	
	// address - %String or Ethereum.Address object
	// abi  - %String or %Library.DynamicObject
	Method %OnNew(adapter as Ethereum.NodeJS.OutboundAdapter, address as Ethereum.Address="", abi as %String= "", options as %Library.DynamicObject="") as %Status
	{
		try {
		    set ..Adapter = adapter
		
			if ( (address="") || (abi="") ) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "address and abi are required"))
			}
			if ($IsObject(address) && (address.%ClassName(1)="Ethereum.Address")) {
			    set ..Address = address
			} else {
			    set ..Address = ##class(Ethereum.Address).%New(address)
			    if ('$IsObject(..Address)) {
			        $$$ThrowStatus($$$ERROR($$$GeneralError, "address is invalid"))
			    }    
			}
            if ($IsObject(abi) && ( (abi.%ClassName(1)="%Library.DynamicObject") || (abi.%ClassName(1)="%Library.DynamicArray") ) ) {
                set ..ABI = abi
            } else {
                set ..ABI = {}.%FromJSON(abi)
            }
			
			do ..ParseABI()
			
			if (options'="") {
			    do ..SetOptions(options.account, 
			                    options.key,
			                    ##class(Ethereum.Wei).%New(options.gas),
			                    ##class(Ethereum.Wei).%New(options.gasLimit),
			                    ##class(Ethereum.Wei).%New(options.amount),
			                    options.deferred)
			}
		} catch e {
		    #dim e as %Exception.AbstractException
		    $$$TRACE(e.DisplayString())
			return e.AsStatus()
		}
		return $$$OK
	}
	
	Method ParseABI() [Private ]
	{
	    set iter = ..ABI.%GetIterator()
	    while iter.%GetNext(.key , .value ) {
	        write key," ",value,!
	        set methodName = value.%Get("name")
	        if (value.%Get("constant")) {
	            set methodType = "get"
	        } else {
	            set methodType = "set"
	        }
	        if (methodName'="") {
	            set ..Methods(methodName) = methodType
	            set ..Methods(methodName,"args") = value.inputs.%Size()
	        }
	    }
	}
	
	Method %DispatchMethod(method As %String, args...) as %Library.DynamicObject
	{
        if ('$data(args)) { set args = 0 }
	    if $data(..Methods(method)) {
	        if (args'=..Methods(method,"args")) {
                throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Wrong number of arguments for get method "_method))
            }
            set params = []
            for i=1:1:args {
                if ('$data(args(i))) {
                    throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "All arguments are required. Method "_method))
                }
                do params.%Push(args(i))
            }
		    if (..Methods(method)="get") {
		        $$$ThrowOnError(..Adapter.CallContractGetMethod(.jsonResponse, ..ABI, ..Address, method, params))
		        return jsonResponse
		    } elseif (..Methods(method)="set") {
                if (..FromAccount="") {
                    throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "FromAccount required for "_..Methods(method)_". Use SetOptions method"))
                }
                $$$ThrowOnError(..Adapter.CallContractSetMethod(.jsonResponse, ..ABI, ..Address, ..FromAccount, ..FromPrivateKey, method,..Amount,..GasLimit,..GasPrice,params,..Deferred))
                return jsonResponse
		    } else {
		        throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Unknown method type "_..Methods(method)))
		    }
		} else {
		    throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Method "_method_" is not defined in ABI"))
		}
	}
}