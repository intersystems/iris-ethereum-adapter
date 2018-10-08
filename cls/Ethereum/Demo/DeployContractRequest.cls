Class Ethereum.Demo.DeployContractRequest Extends Ens.Request
{

Property PathToContract As %String (MAXLEN=1000);

Storage Default
{
<Data name="DeployContractRequestDefaultData">
<Subscript>"DeployContractRequest"</Subscript>
<Value name="1">
<Value>PathToContract</Value>
</Value>
</Data>
<DefaultData>DeployContractRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
