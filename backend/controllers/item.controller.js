import Item from "../models/item.model.js";

export async function getItems(req, res, next) {
  try {
    const items = await Item.findAll();
    res.json(items);
  } catch (error) {
    next(error);
  }
}

export async function getItemById(req, res, next) {
  try {
    const item = await Item.findById(req.params.id);

    if (!item) {
      return res.status(404).json({ message: "Item not found" });
    }

    res.json(item);
  } catch (error) {
    next(error);
  }
}

export async function createItem(req, res, next) {
  try {
    if (!req.body.owner_id || !req.body.title) {
      return res.status(400).json({ message: "Owner and title are required" });
    }

    const item = await Item.create(req.body);
    res.status(201).json(item);
  } catch (error) {
    next(error);
  }
}

export async function updateItem(req, res, next) {
  try {
    const existingItem = await Item.findById(req.params.id);

    if (!existingItem) {
      return res.status(404).json({ message: "Item not found" });
    }

    const item = await Item.update(req.params.id, req.body);
    res.json(item);
  } catch (error) {
    next(error);
  }
}

export async function deleteItem(req, res, next) {
  try {
    const deleted = await Item.remove(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "Item not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
