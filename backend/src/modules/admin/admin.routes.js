const express = require('express');
const router = express.Router();
const { requireAuth } = require('../../middleware/auth');
const { requireAdmin } = require('../../middleware/admin');
const User = require('../users/user.model');
const Journal = require('../journals/journal.model');
const Feedback = require('../feedback/feedback.model');

// Get overview stats
router.get('/stats', requireAuth, requireAdmin, async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const premiumUsers = await User.countDocuments({ isPremium: true });
    const totalNotes = await Journal.countDocuments();
    const totalFeedback = await Feedback.countDocuments();
    
    res.json({
      success: true,
      data: {
        totalUsers,
        premiumUsers,
        totalNotes,
        totalFeedback,
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// List and search users
router.get('/users', requireAuth, requireAdmin, async (req, res) => {
  try {
    const { search } = req.query;
    let query = {};
    if (search) {
      query = { 
        $or: [
          { fullName: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } }
        ]
      };
    }
    const users = await User.find(query).sort({ createdAt: -1 });
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Toggle user status (Block/Unblock)
router.post('/users/:id/toggle-status', requireAuth, requireAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    
    user.isActive = !user.isActive;
    await user.save();
    
    res.json({ success: true, message: `User ${user.isActive ? 'unblocked' : 'blocked'} successfully` });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Toggle premium status manually
router.post('/users/:id/toggle-premium', requireAuth, requireAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    
    user.isPremium = !user.isPremium;
    user.subscriptionPlan = user.isPremium ? 'admin_granted' : 'free';
    await user.save();
    
    res.json({ success: true, message: `Premium status updated for ${user.fullName}` });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
