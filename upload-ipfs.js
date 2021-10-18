const { create } = require("ipfs-http-client");

// connect to a different API
const client = create("https://ipfs.infura.io:5001/api/v0");

const main = async () => {
  // call Core API methods
  const { path } = await client.add("Hello world! test");
  console.log(`https://ipfs.infura.io/ipfs/${path}`);
};

main().catch(console.log);
