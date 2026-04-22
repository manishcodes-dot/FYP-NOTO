const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../users/user.model");

const router = express.Router();

const sign = (user) => jwt.sign({ sub: user._id.toString() }, process.env.JWT_SECRET, { expiresIn: "7d" });

router.post("/register", async (req, res) => {
  const { fullName, email, password } = req.body;
  if (!fullName || !email || !password) return res.status(400).json({ success: false, message: "Missing fields" });
  const exists = await User.findOne({ email });
  if (exists) return res.status(409).json({ success: false, message: "Email already in use" });

  const user = await User.create({
    fullName,
    email,
    passwordHash: await bcrypt.hash(password, 10),
  });
  const token = sign(user);
  res.status(201).json({ success: true, data: { token, user } });
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(401).json({ success: false, message: "Invalid credentials" });
  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) return res.status(401).json({ success: false, message: "Invalid credentials" });
  const token = sign(user);
  res.json({ success: true, data: { token, user } });
});

module.exports = router;
