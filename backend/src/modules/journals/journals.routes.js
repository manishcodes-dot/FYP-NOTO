const express = require("express");
const mongoose = require("mongoose");
const { requireAuth } = require("../../middleware/auth");
const JournalEntry = require("./journal.model");
const Friendship = require("../friends/friendship.model");

const router = express.Router();
router.use(requireAuth);

async function areFriends(a, b) {
  const f = await Friendship.findOne({
    status: "accepted",
    $or: [
      { fromUserId: a, toUserId: b },
      { fromUserId: b, toUserId: a },
    ],
  });
  return !!f;
}

router.post("/", async (req, res) => {
  const body = { ...req.body, userId: req.userId };
  if (!body.sharedWith) body.sharedWith = [];
  const entry = await JournalEntry.create(body);
  res.status(201).json({ success: true, data: entry });
});

router.get("/", async (req, res) => {
  const { search, mood, category, tags, page = 1, limit = 20, from, to } = req.query;
  const query = { userId: req.userId };
  if (search) query.$or = [{ title: new RegExp(search, "i") }, { content: new RegExp(search, "i") }];
  if (mood) query.mood = mood;
  if (category) query.category = category;
  if (tags) query.tags = { $in: String(tags).split(",").map((t) => t.trim()) };
  if (from || to) query.entryDate = { ...(from ? { $gte: new Date(from) } : {}), ...(to ? { $lte: new Date(to) } : {}) };

  const items = await JournalEntry.find(query)
    .sort({ isPinned: -1, entryDate: -1 })
    .skip((Number(page) - 1) * Number(limit))
    .limit(Number(limit));
  const total = await JournalEntry.countDocuments(query);
  res.json({ success: true, data: { items, total, page: Number(page), limit: Number(limit) } });
});

router.get("/shared-with-me", async (req, res) => {
  const items = await JournalEntry.find({
    sharedWith: req.userId,
    userId: { $ne: req.userId },
  })
    .populate("userId", "fullName email")
    .sort({ updatedAt: -1 })
    .limit(100)
    .lean();

  const shaped = items.map((doc) => ({
    ...doc,
    ownerName: doc.userId?.fullName || "Friend",
    ownerEmail: doc.userId?.email,
  }));
  res.json({ success: true, data: { items: shaped } });
});

router.get("/calendar/:date", async (req, res) => {
  const day = new Date(req.params.date);
  const nextDay = new Date(day);
  nextDay.setDate(day.getDate() + 1);
  const items = await JournalEntry.find({ userId: req.userId, entryDate: { $gte: day, $lt: nextDay } }).sort({ entryDate: -1 });
  res.json({ success: true, data: { items } });
});

router.post("/:id/share", async (req, res) => {
  const { friendUserIds } = req.body;
  if (!Array.isArray(friendUserIds)) {
    return res.status(400).json({ success: false, message: "friendUserIds must be an array" });
  }
  const entry = await JournalEntry.findOne({ _id: req.params.id, userId: req.userId });
  if (!entry) return res.status(404).json({ success: false, message: "Not found" });

  if (friendUserIds.length === 0) {
    entry.sharedWith = [];
    await entry.save();
    return res.json({ success: true, data: entry });
  }

  for (const fid of friendUserIds) {
    const ok = await areFriends(req.userId, fid);
    if (!ok) return res.status(400).json({ success: false, message: "Can only share with accepted friends" });
  }

  entry.sharedWith = friendUserIds.map((id) => new mongoose.Types.ObjectId(id));
  await entry.save();
  res.json({ success: true, data: entry });
});

router.get("/:id", async (req, res) => {
  const item = await JournalEntry.findOne({
    _id: req.params.id,
    $or: [{ userId: req.userId }, { sharedWith: req.userId }],
  }).populate("userId", "fullName email");

  if (!item) return res.status(404).json({ success: false, message: "Not found" });
  const json = item.toObject ? item.toObject() : item;
  if (json.userId && json.userId.fullName) {
    json.ownerName = json.userId.fullName;
    json.ownerEmail = json.userId.email;
  }
  res.json({ success: true, data: json });
});

router.patch("/:id", async (req, res) => {
  const item = await JournalEntry.findOneAndUpdate({ _id: req.params.id, userId: req.userId }, req.body, { new: true });
  if (!item) return res.status(404).json({ success: false, message: "Not found" });
  res.json({ success: true, data: item });
});

router.delete("/:id", async (req, res) => {
  const item = await JournalEntry.findOneAndDelete({ _id: req.params.id, userId: req.userId });
  if (!item) return res.status(404).json({ success: false, message: "Not found" });
  res.json({ success: true, message: "Deleted" });
});

module.exports = router;
