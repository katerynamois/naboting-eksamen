import { pool } from "../db.config.js";

async function findByItemId(itemId) {
  const [rows] = await pool.execute(
    "SELECT * FROM item_images WHERE item_id = ? ORDER BY is_primary DESC, image_id ASC",
    [itemId],
  );
  return rows;
}

async function create(image) {
  const [result] = await pool.execute(
    "INSERT INTO item_images (item_id, image_url, is_primary) VALUES (?, ?, ?)",
    [image.item_id, image.image_url, image.is_primary ? 1 : 0],
  );

  const [rows] = await pool.execute("SELECT * FROM item_images WHERE image_id = ?", [result.insertId]);
  return rows[0];
}

async function remove(id) {
  const [result] = await pool.execute("DELETE FROM item_images WHERE image_id = ?", [id]);
  return result.affectedRows > 0;
}

export default {
  findByItemId,
  create,
  remove,
};

