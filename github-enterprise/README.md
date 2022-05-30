# GitHub Enterprise
Once you have selected a file according to your requirements, replace the variables with your tokens and rename to `docker-compose.yaml`.

Ensure to copy `githubent-accept.json` into a folder specified in the `docker-compose.yaml` file and rename it to `accept.json`.

Then, run `docker-compose up` and get the broker up and running.

## Configuration
To use the Broker client with a GitHub Enterprise deployment, run `docker pull snyk/broker:github-enterprise` tag. The following environment variables are mandatory to configure the Broker client:

- `BROKER_TOKEN` - the Snyk Broker token, obtained from your Snyk Org settings view (app.snyk.io).
- `GITHUB_TOKEN` - a personal access token with full `repo`, `read:org` and `admin:repo_hook` scopes.
- `GITHUB` - the hostname of your GitHub Enterprise deployment, such as `your.ghe.domain.com`.
- `GITHUB_API` - the API endpoint of your GitHub Enterprise deployment. Should be `your.ghe.domain.com/api/v3`.
- `GITHUB_GRAPHQL` - the graphql endpoint of your GitHub Enterprise deployment. Should be `your.ghe.domain.com/api`.
- `PORT` - the local port at which the Broker client accepts connections. Default is 7341.
- `BROKER_CLIENT_URL` - the full URL of the Broker client as it will be accessible by your GitHub Enterprise deployment webhooks, such as `http://my.broker.client:7341`

#### Command-line arguments

You can run the docker container by providing the relevant configuration:

```console
docker run --restart=always \
           -p 8000:8000 \
           -e BROKER_TOKEN=secret-broker-token \
           -e GITHUB_TOKEN=secret-github-token \
           -e GITHUB=your.ghe.domain.com \
           -e GITHUB_API=your.ghe.domain.com/api/v3 \
           -e GITHUB_GRAPHQL=your.ghe.domain.com/api \
           -e PORT=8000 \
           -e BROKER_CLIENT_URL=http://my.broker.client:8000 \
       snyk/broker:github-enterprise
```

#### Derived docker image

Another option is to build your own docker image and override relevant environment variables:

```dockerfile
FROM snyk/broker:github-enterprise

ENV BROKER_TOKEN      secret-broker-token
ENV GITHUB_TOKEN      secret-github-token
ENV GITHUB            your.ghe.domain.com
ENV GITHUB_API        your.ghe.domain.com/api/v3
ENV GITHUB_GRAPHQL    your.ghe.domain.com/api
ENV PORT              8000
ENV BROKER_CLIENT_URL http://my.broker.client:8000
```
### Advanced Configuration

#### HTTPS

The Broker client runs an HTTP server by default. It can be configured to run an HTTPS server for local connections. This requires an SSL certificate and a private key to be provided to the docker container at runtime.

For example, if your certificate files are found locally at `./private/broker.crt` and `./private/broker.key`, provide these files to the docker container by mounting the folder and using the `HTTPS_CERT` and `HTTPS_KEY` environment variables:

```console
docker run --restart=always \
           -p 8000:8000 \
           -e BROKER_TOKEN=secret-broker-token \
           -e GITHUB_TOKEN=secret-github-token \
           -e PORT=8000 \
           -e HTTPS_CERT=/private/broker.crt \
           -e HTTPS_KEY=/private/broker.key \
           -e BROKER_CLIENT_URL=https://my.broker.client:8000 \
           -v /local/path/to/private:/private \
       snyk/broker:github-com
```

Note that `BROKER_CLIENT_URL` now has the HTTPS scheme.

#### Git with an internal certificate

By default, the Broker client establishes HTTPS connections to the Git. If your Git is serving an internal certificate (signed by your own CA), you can provide the CA certificate to the Broker client.

For example, if your CA certificate is at `./private/ca.cert.pem`, provide it to the docker container by mounting the folder and using the `CA_CERT` environment variable:

```console
docker run --restart=always \
           -p 8000:8000 \
           -e BROKER_TOKEN=secret-broker-token \
           -e BITBUCKET_USERNAME=username \
           -e BITBUCKET_PASSWORD=password \
           -e BITBUCKET=your.bitbucket-server.domain.com \
           -e BITBUCKET_API=your.bitbucket-server.domain.com/rest/api/1.0 \
           -e PORT=8000 \
           -e CA_CERT=/private/ca.cert.pem \
           -v /local/path/to/private:/private \
       snyk/broker:bitbucket-server
```

### Custom approved-listing filter

The default approved-listing filter supports the bare minimum to operate on all repositories supported by Snyk. In order to customize the approved-listing filter, create the default one locally by installing `snyk-broker` and running `broker init [Git type]`. The created `accept.json` is the default filter for the chosen Git. Place the file in a separate folder such as `./private/accept.json`, and provide it to the docker container by mounting the folder and using the `ACCEPT` environment variable:

```console
docker run --restart=always \
           -p 8000:8000 \
           -e BROKER_TOKEN=secret-broker-token \
           -e GITHUB_TOKEN=secret-github-token \
           -e PORT=8000 \
           -e BROKER_CLIENT_URL=https://my.broker.client:8000 \
           -e ACCEPT=/private/accept.json
           -v /local/path/to/private:/private \
       snyk/broker:github-com
```

#### Types of Filtering

##### By Header

Add a validation block with the following key/values:

| Key | Value | Value Type | Example |
|-|-|-|-|
| header | The name of the header you wish to filter on. If this is defined then the named header must explicitly exist on the request otherwise it will be blocked | String | `accept` |
| values | The header value must match one of the defined strings | Array\<String\> | `["application/vnd.github.v4.sha"]` |

For example, to only allow the SHA Media Type accept header for requests to the GitHub Commits API you would add the following:

```json
{
    "method": "GET",
    "path": "/repos/:name/:repo/commits/:ref",
    "origin": "https://${GITHUB_TOKEN}@${GITHUB_API}",
    "valid": [
        {
            "header": "accept",
            "values": ["application/vnd.github.v4.sha"]
        }
    ]
}
```
