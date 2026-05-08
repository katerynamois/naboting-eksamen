import { Router } from "express";
import {
  createItemImage,
  deleteItemImage,
  getImagesByItemId,
} from "../controllers/itemImage.controller.js";

const router = Router();

router.get("/item/:itemId", getImagesByItemId);
router.post("/", createItemImage);
router.delete("/:id", deleteItemImage);

export default router;
