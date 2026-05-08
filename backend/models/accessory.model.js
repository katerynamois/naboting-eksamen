import { pool } from "../db.config.js";

async function findByItemId(itemId) {
  const [rows] = await pool.execute(
    "SELECT * FROM accessories WHERE item_id = ? ORDER BY accessory_id ASC",
    [itemId],
  );
  return rows;
}

async function create(accessory) {
  const [result] = await pool.execute(
    "INSERT INTO accessories (item_id, name) VALUES (?, ?)",
    [accessory.item_id, accessory.name],
  );

  const [rows] = await pool.execute("SELECT * FROM accessories WHERE accessory_id = ?", [result.insertId]);
  return rows[0];
}

async function remove(id) {
  const [result] = await pool.execute("DELETE FROM accessories WHERE accessory_id = ?", [id]);
  return result.affectedRows > 0;
}

export default {
  findByItemId,
  create,
  remove,
};

