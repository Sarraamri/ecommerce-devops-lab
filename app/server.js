const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URL = process.env.MONGO_URL || "mongodb://mongo:27017";
const DB_NAME = process.env.DB_NAME || "ecommerce";

// Default catalogue, also seeded into MongoDB on first connect.
const DEFAULT_PRODUCTS = [
  { name: "Laptop", price: 1200 },
  { name: "Phone", price: 800 },
];

let db = null;

async function connectMongo() {
  try {
    const client = new MongoClient(MONGO_URL, { serverSelectionTimeoutMS: 3000 });
    await client.connect();
    db = client.db(DB_NAME);

    const products = db.collection("products");
    if ((await products.countDocuments()) === 0) {
      await products.insertMany(DEFAULT_PRODUCTS);
      console.log("Seeded default products into MongoDB.");
    }
    console.log("Connected to MongoDB at", MONGO_URL);
  } catch (err) {
    // The app still serves the default catalogue if Mongo is unavailable,
    // so the lab demo never shows a blank page.
    console.error("MongoDB connection failed, using in-memory catalogue:", err.message);
  }
}

async function getProducts() {
  if (db) {
    try {
      return await db.collection("products").find().toArray();
    } catch (_) {
      /* fall through to default */
    }
  }
  return DEFAULT_PRODUCTS;
}

// JSON API
app.get("/api/products", async (_req, res) => {
  res.json(await getProducts());
});

// Health endpoint for the ALB target group
app.get("/health", (_req, res) => res.status(200).send("ok"));

// Storefront HTML
app.get("/", async (_req, res) => {
  const products = await getProducts();
  const items = products
    .map((p) => `      <li class="item"><span>${p.name}</span><span>$${p.price}</span></li>`)
    .join("\n");

  res.send(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>E-Commerce Store</title>
  <style>
    body { font-family: system-ui, sans-serif; background:#0f172a; color:#e2e8f0; margin:0; }
    .wrap { max-width:520px; margin:8vh auto; padding:2rem; }
    h1 { font-size:2rem; margin:0 0 1.5rem; }
    ul { list-style:none; padding:0; }
    .item { display:flex; justify-content:space-between; padding:1rem 1.25rem; margin-bottom:.75rem;
            background:#1e293b; border-radius:12px; font-size:1.1rem; }
    .item span:last-child { color:#38bdf8; font-weight:600; }
    footer { margin-top:2rem; font-size:.8rem; color:#64748b; }
  </style>
</head>
<body>
  <div class="wrap">
    <h1>E-Commerce Store</h1>
    <ul>
${items}
    </ul>
    <footer>Served by ${process.env.HOSTNAME || "node"} &middot; IaaS DevOps Lab</footer>
  </div>
</body>
</html>`);
});

app.listen(PORT, () => console.log(`E-commerce app listening on :${PORT}`));
connectMongo();
