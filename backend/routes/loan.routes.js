import { Router } from "express";
import {
  createLoan,
  deleteLoan,
  getLoanById,
  getLoans,
  getLoansByBorrowerId,
  getLoansByOwnerId,
  updateLoan,
} from "../controllers/loan.controller.js";

const router = Router();

router.get("/", getLoans);
router.get("/borrower/:userId", getLoansByBorrowerId);
router.get("/owner/:userId", getLoansByOwnerId);
router.get("/:id", getLoanById);
router.post("/", createLoan);
router.put("/:id", updateLoan);
router.delete("/:id", deleteLoan);

export default router;
