const { create } = require("ipfs-http-client");

// connect to a different API
const client = create("https://ipfs.infura.io:5001/api/v0");

const stats = [
  {
    attack: 500,
    defense: 800,
    speed: 200,
    stamina: 300,
    range: 450,
  },
  {
    attack: 800,
    defense: 1100,
    speed: 500,
    stamina: 600,
    range: 750,
  },
  {
    attack: 1300,
    defense: 1600,
    speed: 1000,
    stamina: 1100,
    range: 1250,
  },
  {
    attack: 1900,
    defense: 2200,
    speed: 1600,
    stamina: 1700,
    range: 1850,
  },
  {
    attack: 2900,
    defense: 3200,
    speed: 2600,
    stamina: 2700,
    range: 2850,
  },
];

const main = async () => {
  // call Core API methods
  const paths = await Promise.all(
    stats.map((stat) => client.add(JSON.stringify(stat)))
  );
  console.log(paths);
  // console.log(`https://ipfs.infura.io/ipfs/${path}`);
};

main().catch(console.log);
