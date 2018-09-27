Class Ethereum.Demo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Ethereum.Demo.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Ethereum.Demo.EthereumOperation" Category="" ClassName="Ethereum.Demo.EthereumOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">3000</Setting>
    <Setting Target="Adapter" Name="HTTPServer">localhost</Setting>
    <Setting Target="Adapter" Name="Provider"></Setting>
    <Setting Target="Host" Name="Credentials"></Setting>
    <Setting Target="Host" Name="ContractAddress"></Setting>
    <Setting Target="Adapter" Name="DeferredResponseHost"></Setting>
    <Setting Target="Adapter" Name="DeferredResponsePath"></Setting>
    <Setting Target="Adapter" Name="DeferredResponsePort"></Setting>
  </Item>
  <Item Name="Ethereum.Demo.CallBackRESTService" Category="" ClassName="Ethereum.Demo.CallBackRESTService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
