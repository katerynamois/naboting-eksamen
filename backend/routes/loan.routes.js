import { Router } from "express";
import {
  createLoan,
  deleteLoan,
  getLoanById,
  getLoans,
  getLoansByBorrowerId,
  updateLoan,
} from "../controllers/loan.controller.js";

const router = Router();

router.get("/", getLoans);
router.get("/borrower/:userId", getLoansByBorrowerId);
router.get("/:id", getLoanById);
router.post("/", createLoan);
router.put("/:id", updateLoan);
router.delete("/:id", deleteLoan);

export default router;
