import User from "../models/user.model.js";

export async function getUsers(req, res, next) {
  try {
    const users = await User.findAll();
    res.json(users);
  } catch (error) {
    next(error);
  }
}

export async function getUserById(req, res, next) {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(user);
  } catch (error) {
    next(error);
  }
}

export async function createUser(req, res, next) {
  try {
    if (!req.body.email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (error) {
    next(error);
  }
}

export async function updateUser(req, res, next) {
  try {
    const existingUser = await User.findById(req.params.id);

    if (!existingUser) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = await User.update(req.params.id, req.body);
    res.json(user);
  } catch (error) {
    next(error);
  }
}

export async function deleteUser(req, res, next) {
  try {
    const deleted = await User.remove(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
}
