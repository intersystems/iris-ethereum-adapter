Class Ethereum.Wei Extends %RegisteredObject
{
Property Wei As %Integer [ Private ];

Method %OnNew(amount As %String) As %Status
{
    return ..WeiSet(amount)
}

Method ToEther() As %Decimal
{
    return ..Wei/1000000000000000000
}

Method WeiGet() As %Integer
{
    return i%Wei
}
 
Method ToHex() As %String
{
    return "0x"_##class(%SYSTEM.Util).DecimalToHex(..Wei)
}

Method WeiSet(amount As %String) As %Status
{
    if ("0x"=$extract(amount,1,2)) {
    	set i%Wei = ##class(%SYSTEM.Util).HexToDecimal($extract(amount,3,*))
    } else {
    	set i%Wei = amount
    }
    return $$$OK
}

ClassMethod WeiFromEther(etherAmount As %Decimal)
{
    return ..%New(etherAmount * 1000000000000000000)
}

Method WeiSetFromEther(etherAmount As %Decimal) as %Integer
{
    set ..Wei = etherAmount * 1000000000000000000
    return ..Wei
}
}