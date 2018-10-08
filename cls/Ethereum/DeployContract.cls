Class Ethereum.DeployContract Extends %RegisteredObject
{
    Property ABI as %Library.DynamicArray;
    Property ByteCode as %String;
    
    Property Address as Ethereum.Address;
    
    Property FromAccount as Ethereum.Address [Private];
    Property FromPrivateKey as %String [Private];
    Property GasPrice as Ethereum.Wei [Private ];
    Property GasLimit as Ethereum.Wei [Private ];
    Property Deferred as %String [Private ];

    Property Adapter as Ethereum.NodeJS.OutboundAdapter;
    
    /// abi - %String or %Library.DynamicObject
    Method %OnNew(adapter as Ethereum.NodeJS.OutboundAdapter, abi, byteCode as %String, options as %Library.DynamicObject="") as %Status
    {
        try {
            if ( '$IsObject(adapter) || (adapter.%ClassName(1)'="Ethereum.NodeJS.OutboundAdapter") ) {
                $$$ThrowStatus($$$ERROR($$$GeneralError, "adapter argument must be an object of Ethereum.NodeJS.OutboundAdapter"))
            }
            set ..Adapter = adapter
           
            if ($IsObject(abi) && (abi.%ClassName(1)="%Library.DynamicArray")) {
                set ..ABI = abi
            } else {
                set ..ABI = [].%FromJSON(abi)
            }
            set ..ByteCode = byteCode
            if options'="" {
                w !,options,!
                w !,options.account,!
                do ..SetOptions(##class(Ethereum.Address).%New(options.account),options.key,##class(Ethereum.Wei).%New(options.gas),##class(Ethereum.Wei).%New(options.gasLimit))
            }
        } catch e {
            #dim e as %Exception.AbstractException
            return e.AsStatus()
        }
        return $$$OK
    }
    
    Method SetDeferred(deferred as %String = "") As %Status
    {
        set ..Deferred = deferred
        return $$$OK
    }
    
    Method SetOptions(account as Ethereum.Address, key as %String="", gas as Ethereum.Wei = "", gasLimit as Ethereum.Wei = "", deferred as %String = "") as %Status
    {
        if ('$data(account)) {
            return $$$ERROR($$$GeneralError, "account argument required")
        }
        if ('$IsObject(account) || (account.%ClassName(1)'="Ethereum.Address")) {
            return $$$ERROR($$$GeneralError, "account argument must be an object Ethereum.Address")
        }
        set ..FromAccount = account
        set ..FromPrivateKey = key
        set ..Deferred = deferred
        
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
        
        return $$$OK
    }
    
    Method ClearOptions() as %Status
    {
        set ..FromAccount = ""
        set ..FromPrivateKey = ""
        set ..Deferred = ""
        set ..GasPrice = ##class(Ethereum.Wei).%New(0)
        set ..GasLimit = ##class(Ethereum.Wei).%New(0)
        
        return $$$OK
    }    
    
    Method Deploy(args...) as %Library.DynamicObject
    {
        set params = []
        for i=1:1:args {
            if ('$data(args(i))) {
                throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "All arguments are required"))
            }
            do params.%Push(args(i))
        }
        $$$ThrowOnError(..Adapter.DeployContract(.jsonResponse, ..FromAccount, ..FromPrivateKey, ..ABI, ..ByteCode,..GasLimit,..GasPrice,params,..Deferred))
        return jsonResponse
    }
    
}