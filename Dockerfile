FROM daimor/intersystems-iris:2018.1

WORKDIR /opt/etherium

COPY Installer.cls .

COPY ./cls/ ./src/

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly \
 && /bin/echo -e \
      "do \$system.OBJ.Load(\"$(pwd)/Installer.cls\", \"ck\")\n" \
      "Set vars(\"HTTPServer\")=\"nodejs\"\n" \
      "Set vars(\"HTTPPort\")=\"3000\"\n" \
      "if '##class(Etherium.Installer).setup(.vars) do \$zu(4, \$job, 1)\n" \
      "halt" \
  | iris session $ISC_PACKAGE_INSTANCENAME \
 && iris stop $ISC_PACKAGE_INSTANCENAME quietly