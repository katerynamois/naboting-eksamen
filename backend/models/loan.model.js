import { pool } from "../db.config.js";

function toDateString(val) {
  if (!val) return null;
  return new Date(val).toISOString().slice(0, 10);
}

async function findAll() {
  const [rows] = await pool.query("SELECT * FROM loans ORDER BY loan_id DESC");
  return rows;
}

async function findById(id) {
  const [rows] = await pool.execute("SELECT * FROM loans WHERE loan_id = ?", [id]);
  return rows[0] || null;
}

async function findByBorrowerId(userId) {
  const [rows] = await pool.execute(
    `SELECT loans.*, items.title AS item_title,
            users.first_name AS owner_first_name,
            users.last_name AS owner_last_name
     FROM loans
     JOIN items ON loans.item_id = items.item_id
     JOIN users ON items.owner_id = users.user_id
     WHERE loans.borrower_id = ?
     ORDER BY loans.loan_id DESC`,
    [userId],
  );
  return rows;
}

async function findByOwnerId(userId) {
  const [rows] = await pool.execute(
    `SELECT loans.*, items.title AS item_title,
            users.first_name AS borrower_first_name,
            users.last_name AS borrower_last_name
     FROM loans
     JOIN items ON loans.item_id = items.item_id
     JOIN users ON loans.borrower_id = users.user_id
     WHERE items.owner_id = ?
     ORDER BY loans.loan_id DESC`,
    [userId],
  );
  return rows;
}

async function create(loan) {
  const [rows] = await pool.execute(
    "CALL CreateLoan(?, ?, ?, ?, ?)",
    [
      loan.item_id,
      loan.borrower_id,
      toDateString(loan.start_date),
      toDateString(loan.end_date),
      loan.message || null,
    ],
  );

  const loanId = rows[0][0].loan_id;
  return findById(loanId);
}

async function update(id, loan) {
  await pool.execute(
    `UPDATE loans
     SET item_id = ?, borrower_id = ?, start_date = ?, end_date = ?, message = ?, status = ?
     WHERE loan_id = ?`,
    [
      loan.item_id,
      loan.borrower_id,
      toDateString(loan.start_date),
      toDateString(loan.end_date),
      loan.message || null,
      loan.status || "pending",
      id,
    ],
  );

  return findById(id);
}

async function remove(id) {
  const [result] = await pool.execute("DELETE FROM loans WHERE loan_id = ?", [id]);
  return result.affectedRows > 0;
}

export default {
  findAll,
  findById,
  findByBorrowerId,
  findByOwnerId,
  create,
  update,
  remove,
};

