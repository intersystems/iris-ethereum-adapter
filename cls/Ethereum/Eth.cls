include Ensemble

Class Ethereum.Eth Extends %RegisteredObject
{
    Property Adapter As Ethereum.NodeJS.OutboundAdapter;
    
    Method %OnNew(adapter As Ethereum.NodeJS.OutboundAdapter = 0) As %Status
    {
        return:('$isobject(adapter)) 0
        set ..Adapter = adapter
        return $$$OK
    }

    /// Returns the number of the most recent block.
    Method GetBlockNumber() As %Integer
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getBlockNumber",[]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }

    /// Returns the current balance in wei for the given address at a given block. 
    Method GetBalance(address As Ethereum.Address, blockNumber As %String = "latest") As Ethereum.Wei
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getBalance",[(address.Address),(blockNumber)]))
        if (response.status=1) {
            return ##class(Ethereum.Wei).%New(response.data) 
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }

    /// Returns a block matching the block number or block hash.
    /// blockHashOrBlockNumber is the block number or block hash. Or the string "genesis", "latest" or "pending".
    /// If returnTransactionObjects is true, the returned block will contain all transactions as objects, 
    /// if false it will only contains the transaction hashes
    Method GetBlock(blockHashOrBlockNumber = "latest", returnTransactionObjects As %Boolean = 0) As %Library.DynamicObject
    {
        set params = [(blockHashOrBlockNumber)]
        do params.%Push(returnTransactionObjects,"boolean")
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getBlock",params))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }        
    }
    
    /// Returns the number of transaction in a given block.
    /// blockHashOrBlockNumber - the block number or hash. Or the string "genesis", "latest" or "pending" 
    Method GetBlockTransactionCount(blockHashOrBlockNumber = "latest") As %Integer
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getBlockTransactionCount",[(blockHashOrBlockNumber)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }        
    }
    
    /// Returns the current gas price. The gas price is determined by the last few blocks median gas price
    Method GetGasPrice() As Ethereum.Wei
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getGasPrice",[]))
        if (response.status=1) {
            return ##class(Ethereum.Wei).%New(response.data)
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }          
    }
    
    Method GetStorageAt(address As Ethereum.Address, position As %Integer=0, blockNumber As %String = "latest") As %String
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getStorageAt",[(address.Address),(position),(blockNumber)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }
    
    Method GetCode(address As Ethereum.Address,blockNumber As %String = "latest") As %String
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getCode",[(address.Address),(blockNumber)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }
    
    /// Returns a transaction matching the given transaction hash
    Method GetTransaction(transactionHash As %String) As %Library.DynamicObject
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getTransaction",[(transactionHash)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }
    
    /// Returns a transaction based on a block hash or number and the transactions index position.
    /// blockHashOrNumber - a block number or hash. Or the string "genesis", "latest" or "pending".
    /// index - the transactions index position. 
    Method GetTransactionFromBlock(blockHashOrNumber As %String = "latest", index As %Integer = 0) As %Library.DynamicObject
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getTransactionFromBlock",[(blockHashOrNumber),(index)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }
    
    /// Returns the receipt of a transaction by transaction hash
    Method GetTransactionReceipt(hash As %String) As %Library.DynamicObject
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getTransactionReceipt",[(hash)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }
    }
    
    /// Returns the number of transactions sent from the given address.
    /// address - the address to get the numbers of transactions from.
    /// blockNumber - the block number or hash. Or the string "genesis", "latest" or "pending".
    Method GetTransactionCount(address As Ethereum.Address,blockNumber As %String = "latest") As %Integer
    {
        $$$ThrowOnError(..Adapter.CallWeb3Method(.response,"getTransactionCount",[(address.Address),(blockNumber)]))
        if (response.status=1) {
            return response.data
        } else {
            $$$ThrowStatus($$$ERROR($$$GeneralError, "Error: "_response.error))
        }        
    }
}