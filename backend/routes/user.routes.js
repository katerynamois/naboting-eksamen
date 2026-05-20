import { Router } from "express";
import {
  createUser,
  deleteUser,
  getUserById,
  getUsers,
  loginUser,
  updateUser,
} from "../controllers/user.controller.js";

const router = Router();

router.post("/login", loginUser);
router.get("/", getUsers);
router.get("/:id", getUserById);
router.post("/", createUser);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

export default router;
