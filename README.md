# web-infrastructure

Simple WordPress web server infrastructure for Azure.
This [Terraform][] infrastructure hosts the [AwakeningSV/wordpress][wp] stack.

## Quick start

Blue-green deployments are handled with Terraform workspaces.

For plan or apply, you will need to supply a `label` variable which will be used in Azure DNS FQDNs.

```shell
brew install terraform azure-cli
az login
cd app
terraform init
terraform workspace list
terraform workspace select SOME_VERSION_FROM_THE_LIST
terraform apply -var label=a-clever-name
```

### Outputs

- `staging_fqdn`
- `production_fqdn`

## Creating a new deployment iteration

For a new version `NUMBER`:

```shell
cd app
terraform workspace new vNUMBER
terraform apply
```

## Removing an old iteration

When removing `PREVIOUS` in favor of an already deployed `NEXT`:

```shell
terraform workspace select vPREVIOUS
terraform destroy
terraform workspace select vNEXT
terraform workspace delete vPREVIOUS
```

## Further reading

- [Blue-green deployments with Terraform](https://wrzasq.pl/blog/blue-green-deployments-with-terraform.html)

## License

MIT, see LICENSE.

[Terraform]: https://www.terraform.io
[wp]: https://github.com/AwakeningSV/wordpress