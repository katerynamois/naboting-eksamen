import Accessory from "../models/accessory.model.js";

export async function getAccessoriesByItemId(req, res, next) {
  try {
    const accessories = await Accessory.findByItemId(req.params.itemId);
    res.json(accessories);
  } catch (error) {
    next(error);
  }
}

export async function createAccessory(req, res, next) {
  try {
    if (!req.body.item_id || !req.body.name) {
      return res.status(400).json({ message: "Item and name are required" });
    }

    const accessory = await Accessory.create(req.body);
    res.status(201).json(accessory);
  } catch (error) {
    next(error);
  }
}

export async function deleteAccessory(req, res, next) {
  try {
    const deleted = await Accessory.remove(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "Accessory not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
