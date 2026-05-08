import { Router } from "express";
import {
  createAccessory,
  deleteAccessory,
  getAccessoriesByItemId,
} from "../controllers/accessory.controller.js";

const router = Router();

router.get("/item/:itemId", getAccessoriesByItemId);
router.post("/", createAccessory);
router.delete("/:id", deleteAccessory);

export default router;
