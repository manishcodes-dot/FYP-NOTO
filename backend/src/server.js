const dotenv = require("dotenv");
dotenv.config();

const app = require("./app");
const mongoose = require("mongoose");

const port = process.env.PORT || 5000;

async function start() {
  await mongoose.connect(process.env.MONGO_URI);
  app.listen(port, () => {
    console.log(`NOTO backend running on ${port}`);
  });
}

start().catch((err) => {
  console.error(err);
  process.exit(1);
});
