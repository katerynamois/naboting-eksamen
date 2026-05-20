import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, ".env") });

const userRoutes = (await import("./routes/user.routes.js")).default;
const itemRoutes = (await import("./routes/item.routes.js")).default;
const itemImageRoutes = (await import("./routes/itemImage.routes.js")).default;
const accessoryRoutes = (await import("./routes/accessory.routes.js")).default;
const loanRoutes = (await import("./routes/loan.routes.js")).default;

const app = express();
const port = process.env.API_PORT || 3001;

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
