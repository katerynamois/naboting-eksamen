import Loan from "../models/loan.model.js";

export async function getLoans(req, res, next) {
  try {
    const loans = await Loan.findAll();
    res.json(loans);
  } catch (error) {
    next(error);
  }
}

export async function getLoanById(req, res, next) {
  try {
    const loan = await Loan.findById(req.params.id);

    if (!loan) {
      return res.status(404).json({ message: "Loan not found" });
    }

    res.json(loan);
  } catch (error) {
    next(error);
  }
}

export async function getLoansByBorrowerId(req, res, next) {
  try {
    const loans = await Loan.findByBorrowerId(req.params.userId);
    res.json(loans);
  } catch (error) {
    next(error);
  }
}

export async function createLoan(req, res, next) {
  try {
    if (!req.body.item_id || !req.body.borrower_id) {
      return res.status(400).json({ message: "Item and borrower are required" });
    }

    const loan = await Loan.create(req.body);
    res.status(201).json(loan);
  } catch (error) {
    next(error);
  }
}

export async function updateLoan(req, res, next) {
  try {
    const existingLoan = await Loan.findById(req.params.id);

    if (!existingLoan) {
      return res.status(404).json({ message: "Loan not found" });
    }

    const loan = await Loan.update(req.params.id, req.body);
    res.json(loan);
  } catch (error) {
    next(error);
  }
}

export async function deleteLoan(req, res, next) {
  try {
    const deleted = await Loan.remove(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "Loan not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
