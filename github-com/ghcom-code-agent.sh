docker run -d --restart=always\
   -p 8000:8000 \
   -e BROKER_TOKEN=<xxxxxxx-xxxx-xxxx-xxxx-xxxxxxx> \
   -e GITHUB_TOKEN=secret-github-token \
   -e BROKER_CLIENT_URL=localhost:8000
   -e PORT=8000 \
   -e GIT_CLIENT_URL=http://code-agent:3000 \
   --network mySnykBrokerNetwork \
   -e ACCEPT=/private/accept.json \
   -v /private:/private \
   snyk/broker:github-com

docker run -d --restart=always --name code-agent \
     -p 3000:3000 \
     -e PORT=3000 \
     -e SNYK_TOKEN=<Snyk API token> \
     --network mySnykBrokerNetwork \
     snyk/code-agent:latest