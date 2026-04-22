const express = require("express");
const { requireAuth } = require("../../middleware/auth");
const Friendship = require("./friendship.model");
const User = require("../users/user.model");

const router = express.Router();
router.use(requireAuth);

function friendUserFromDoc(f, meId) {
  const from = f.fromUserId;
  const to = f.toUserId;
  const fromId = from._id ? from._id.toString() : from.toString();
  const friend = fromId === meId ? to : from;
  return {
    id: friend._id.toString(),
    fullName: friend.fullName,
    email: friend.email,
  };
}

router.post("/request", async (req, res) => {
  const email = (req.body.email || "").trim().toLowerCase();
  const targetUserId = req.body.targetUserId;

  let target;
  if (targetUserId) {
    target = await User.findById(targetUserId);
  } else if (email) {
    target = await User.findOne({ email });
  }

  if (!target) return res.status(404).json({ success: false, message: "User not found" });
  if (target._id.toString() === req.userId) return res.status(400).json({ success: false, message: "Cannot add yourself" });

  const existing = await Friendship.findOne({
    $or: [
      { fromUserId: req.userId, toUserId: target._id },
      { fromUserId: target._id, toUserId: req.userId },
    ],
  });

  if (existing) {
    if (existing.status === "accepted") return res.status(409).json({ success: false, message: "Already friends" });
    if (existing.status === "pending") return res.status(409).json({ success: false, message: "Request already pending" });
    if (existing.status === "rejected") {
      existing.status = "pending";
      existing.fromUserId = req.userId;
      existing.toUserId = target._id;
      await existing.save();
      return res.status(201).json({ success: true, data: existing });
    }
  }

  const created = await Friendship.create({
    fromUserId: req.userId,
    toUserId: target._id,
    status: "pending",
  });
  res.status(201).json({ success: true, data: created });
});

router.get("/incoming", async (req, res) => {
  const list = await Friendship.find({ toUserId: req.userId, status: "pending" })
    .populate("fromUserId", "fullName email")
    .sort({ createdAt: -1 })
    .lean();
  const items = list.map((f) => ({
    id: f._id.toString(),
    from: {
      id: f.fromUserId._id.toString(),
      fullName: f.fromUserId.fullName,
      email: f.fromUserId.email,
    },
    createdAt: f.createdAt,
  }));
  res.json({ success: true, data: { items } });
});

router.post("/accept/:friendshipId", async (req, res) => {
  const f = await Friendship.findOne({
    _id: req.params.friendshipId,
    toUserId: req.userId,
    status: "pending",
  });
  if (!f) return res.status(404).json({ success: false, message: "Request not found" });
  f.status = "accepted";
  await f.save();
  res.json({ success: true, data: f });
});

router.post("/reject/:friendshipId", async (req, res) => {
  const f = await Friendship.findOne({
    _id: req.params.friendshipId,
    toUserId: req.userId,
    status: "pending",
  });
  if (!f) return res.status(404).json({ success: false, message: "Request not found" });
  f.status = "rejected";
  await f.save();
  res.json({ success: true, message: "Rejected" });
});

router.get("/", async (req, res) => {
  const me = req.userId;
  const list = await Friendship.find({ status: "accepted", $or: [{ fromUserId: me }, { toUserId: me }] })
    .populate("fromUserId", "fullName email")
    .populate("toUserId", "fullName email")
    .lean();

  const friends = list.map((f) => friendUserFromDoc(f, me));
  res.json({ success: true, data: { items: friends } });
});

router.delete("/:friendUserId", async (req, res) => {
  const other = req.params.friendUserId;
  const deleted = await Friendship.findOneAndDelete({
    status: "accepted",
    $or: [
      { fromUserId: req.userId, toUserId: other },
      { fromUserId: other, toUserId: req.userId },
    ],
  });
  if (!deleted) return res.status(404).json({ success: false, message: "Friendship not found" });
  res.json({ success: true, message: "Removed" });
});

module.exports = router;
