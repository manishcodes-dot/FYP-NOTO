const express = require("express");
const User = require("./user.model");
const { requireAuth } = require("../../middleware/auth");

const router = express.Router();

router.get("/me", requireAuth, async (req, res) => {
  const user = await User.findById(req.userId).select("-passwordHash");
  res.json({ success: true, data: user });
});

router.patch("/me", requireAuth, async (req, res) => {
  const updates = { fullName: req.body.fullName, avatarUrl: req.body.avatarUrl };
  const user = await User.findByIdAndUpdate(req.userId, updates, { new: true }).select("-passwordHash");
  res.json({ success: true, data: user });
});

router.get("/search", requireAuth, async (req, res) => {
  const query = req.query.q || "";
  if (query.length < 2) return res.json({ success: true, data: [] });

  const users = await User.find({
    _id: { $ne: req.userId },
    fullName: { $regex: new RegExp(query, "i") },
  })
    .select("fullName email avatarUrl")
    .limit(10);

  res.json({ success: true, data: users });
});

module.exports = router;
