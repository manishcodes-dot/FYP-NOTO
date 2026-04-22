const express = require('express');
const router = express.Router();
const { requireAuth } = require('../../middleware/auth');
const { requireAdmin } = require('../../middleware/admin');
const Feedback = require('./feedback.model');

// User submits feedback
router.post('/', requireAuth, async (req, res) => {
  try {
    const { message, rating } = req.body;
    const feedback = new Feedback({
      userId: req.userId,
      message,
      rating
    });
    await feedback.save();
    res.json({ success: true, message: 'Feedback submitted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Admin retrieves all feedback
router.get('/', requireAuth, requireAdmin, async (req, res) => {
  try {
    const feedbacks = await Feedback.find()
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 });
    res.json({ success: true, data: feedbacks });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
