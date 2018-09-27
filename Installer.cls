Class Etherium.Installer
{

XData setup [ XMLNamespace = INSTALLER ]
{
<Manifest>
  <Var Name="NAMESPACE" Value ="ETHERIUM"/>
  <Var Name="RESTAPP" Value="/eth"/>
  <Var Name="CSPDIR" Value="${INSTALLDIR}/csp/etherium"/>
  <Default Name="SRCDIR" Value="/opt/etherium/src/"/>
  <Default Name="HTTPServer" Value="localhost"/>
  <Default Name="HTTPPort" Value="3000"/>

  <Namespace Name="${NAMESPACE}" Create="yes" Code="${NAMESPACE}" Data="${NAMESPACE}">
    <Configuration>
      <Resource Name="%DB_DEMO"
        Permission="RW"
        Description="Use the DEMO database"/>
      <Database  Name="${NAMESPACE}"
        Create="yes"
        Dir="${INSTALLDIR}/mgr/${NAMESPACE}"
        Resource="%DB_DEMO"
        PublicPermissions="RW"/>
    </Configuration>
    <Import File="${SRCDIR}" Recurse="1" IgnoreErrors="1"/>

    <Production Name="Ethereum.Demo.Production" AutoStart="1">
      <Setting Item="Ethereum.Demo.EthereumOperation"
        Target="Adapter"
        Setting="HTTPServer"
        Value="${HTTPServer}"/>
      <Setting Item="Ethereum.Demo.EthereumOperation"
        Target="Adapter"
        Setting="HTTPPort"
        Value="${HTTPPort}"/>
    </Production>

    <CSPApplication
      Directory="${CSPDIR}"
      Description="Etherium REST API"
      name="${RESTAPP}"
      Url="${RESTAPP}"
      AutoCompile="0"
      Recurse="1"
      Resource=""/>

  </Namespace>

  <Namespace Name="${CURRENTNAMESPACE}">
    <Invoke Class="Etherium.Installer" Method="SetDispatchClass" CheckStatus="1">
      <Arg Value="${RESTAPP}"/>
      <Arg Value="Ethereum.Demo.REST"/>
    </Invoke>
  </Namespace>
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method.
  do %code.WriteLine($char(9)_"Set pVars(""CURRENTNAMESPACE"")=$namespace")
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod SetDispatchClass(pApp As %String = "", pClass As %String = "")
{
  new $Namespace
  set $namespace = "%SYS"
  set app = ##class(Security.Applications).%OpenId(pApp)
  set app.DispatchClass = pClass
  return app.%Save()
}

}
