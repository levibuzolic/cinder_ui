import { readFileSync } from "node:fs";

const file = process.argv[2] ?? "netlify-deploy.json";
const deploy = JSON.parse(readFileSync(file, "utf8"));
const url =
  deploy.deploy_ssl_url ||
  deploy.deploySslUrl ||
  deploy.deploy_url ||
  deploy.deployUrl ||
  deploy.ssl_url ||
  deploy.url;

if (!url) {
  console.error(`Could not find a deployment URL in ${file}.`);
  console.error(JSON.stringify(deploy, null, 2));
  process.exit(1);
}

console.log(`url=${url}`);

if (deploy.deploy_id || deploy.id) {
  console.log(`deploy_id=${deploy.deploy_id || deploy.id}`);
}
