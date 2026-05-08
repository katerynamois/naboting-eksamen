import { pool } from "../db.config.js";

const table = "users";

async function findAll() {
  const [rows] = await pool.query(`SELECT * FROM ${table} ORDER BY user_id DESC`);
  return rows;
}

async function findById(id) {
  const [rows] = await pool.execute(`SELECT * FROM ${table} WHERE user_id = ?`, [id]);
  return rows[0] || null;
}

async function create(user) {
  const [result] = await pool.execute(
    `INSERT INTO ${table}
      (email, phone, password_hash, user_type, first_name, last_name, postal_code)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      user.email,
      user.phone || null,
      user.password_hash || user.password || "",
      user.user_type || "private",
      user.first_name || null,
      user.last_name || null,
      user.postal_code || null,
    ],
  );

  return findById(result.insertId);
}

async function update(id, user) {
  await pool.execute(
    `UPDATE ${table}
     SET email = ?, phone = ?, user_type = ?, first_name = ?, last_name = ?, postal_code = ?
     WHERE user_id = ?`,
    [
      user.email,
      user.phone || null,
      user.user_type || "private",
      user.first_name || null,
      user.last_name || null,
      user.postal_code || null,
      id,
    ],
  );

  return findById(id);
}

async function remove(id) {
  const [result] = await pool.execute(`DELETE FROM ${table} WHERE user_id = ?`, [id]);
  return result.affectedRows > 0;
}

export default {
  findAll,
  findById,
  create,
  update,
  remove,
};

