Class Ethereum.DeployContract Extends %RegisteredObject
{
    Property ABI as %Library.DynamicArray;
    Property ByteCode as %String;
    
    Property Address as Ethereum.Address;
    
    Property FromAccount as Ethereum.Address [Private];
    Property FromPrivateKey as %String [Private];
    Property GasPrice as Ethereum.Wei [Private ];
    Property GasLimit as Ethereum.Wei [Private ];

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
    
    Method SetOptions(account as Ethereum.Address, key as %String="", gas as Ethereum.Wei = "", gasLimit as Ethereum.Wei = "") as %Status
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
        
        return $$$OK
    }
    
    Method Deploy(deferred as %String ="") as %Library.DynamicObject
    {
        $$$ThrowOnError(..Adapter.DeployContract(.jsonResponse, ..FromAccount, ..FromPrivateKey, ..ABI, ..ByteCode,..GasLimit,..GasPrice,deferred))
        return jsonResponse
    }
    
}