import { pool } from "../db.config.js";

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
    "SELECT * FROM loans WHERE borrower_id = ? ORDER BY loan_id DESC",
    [userId],
  );
  return rows;
}

async function create(loan) {
  const [result] = await pool.execute(
    `INSERT INTO loans (item_id, borrower_id, start_date, end_date, status)
     VALUES (?, ?, ?, ?, ?)`,
    [
      loan.item_id,
      loan.borrower_id,
      loan.start_date || null,
      loan.end_date || null,
      loan.status || "active",
    ],
  );

  return findById(result.insertId);
}

async function update(id, loan) {
  await pool.execute(
    `UPDATE loans
     SET item_id = ?, borrower_id = ?, start_date = ?, end_date = ?, status = ?
     WHERE loan_id = ?`,
    [
      loan.item_id,
      loan.borrower_id,
      loan.start_date || null,
      loan.end_date || null,
      loan.status || "active",
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
  create,
  update,
  remove,
};

