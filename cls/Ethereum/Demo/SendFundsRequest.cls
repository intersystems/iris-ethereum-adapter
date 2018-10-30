Class Ethereum.Demo.SendFundsRequest Extends Ens.Request
{
/// Recipient ethereum contract
Property ToAddress As %String;

/// Amount in ETH
Property Amount As %Numeric;

Storage Default
{
<Data name="SendFundsRequestDefaultData">
<Subscript>"SendFundsRequest"</Subscript>
<Value name="1">
<Value>ToAddress</Value>
</Value>
<Value name="2">
<Value>Amount</Value>
</Value>
</Data>
<DefaultData>SendFundsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}