Class Ethereum.Demo.BalanceRequest Extends Ens.Request
{

Property Account As %String;

Storage Default
{
<Data name="BalanceRequestDefaultData">
<Subscript>"BalanceRequest"</Subscript>
<Value name="1">
<Value>Account</Value>
</Value>
</Data>
<DefaultData>BalanceRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
