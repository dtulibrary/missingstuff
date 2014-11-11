# MissingStuff (aka. Findit Local)

## TL;DR.
```
bundle install
rake db:migrate
rake spec
```

## OAI Harvest

The OAI-PMH provider is available at /oai

For example,
http://localhost:3000/oai?verb=ListRecords&metadataPrefix=mxd
http://localhost:3000/oai?verb=ListIdentifiers

Note: The provider defaults to using oai_dc as the metadataPrefix.  This will return oai:dc xml, but it will not be as complete ast the MXD.