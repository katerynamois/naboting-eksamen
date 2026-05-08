import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "node:path";
import { fileURLToPath } from "node:url";

import userRoutes from "./routes/user.routes.js";
import itemRoutes from "./routes/item.routes.js";
import itemImageRoutes from "./routes/itemImage.routes.js";
import accessoryRoutes from "./routes/accessory.routes.js";
import loanRoutes from "./routes/loan.routes.js";

dotenv.config();

const app = express();
const port = process.env.API_PORT || 3000;
const __dirname = path.dirname(fileURLToPath(import.meta.url));

app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.get("/api/health", (req, res) => {
  res.json({ status: "ok", service: "naboting-api" });
});

app.use("/api/users", userRoutes);
app.use("/api/items", itemRoutes);
app.use("/api/item-images", itemImageRoutes);
app.use("/api/accessories", accessoryRoutes);
app.use("/api/loans", loanRoutes);

app.use((req, res) => {
  res.status(404).json({ message: "Route not found" });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: "Server error" });
});

app.listen(port, () => {
  console.log(`Naboting API runs on http://localhost:${port}`);
});
