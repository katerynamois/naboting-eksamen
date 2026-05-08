import ItemImage from "../models/itemImage.model.js";

export async function getImagesByItemId(req, res, next) {
  try {
    const images = await ItemImage.findByItemId(req.params.itemId);
    res.json(images);
  } catch (error) {
    next(error);
  }
}

export async function createItemImage(req, res, next) {
  try {
    if (!req.body.item_id || !req.body.image_url) {
      return res.status(400).json({ message: "Item and image URL are required" });
    }

    const image = await ItemImage.create(req.body);
    res.status(201).json(image);
  } catch (error) {
    next(error);
  }
}

export async function deleteItemImage(req, res, next) {
  try {
    const deleted = await ItemImage.remove(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "Image not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
