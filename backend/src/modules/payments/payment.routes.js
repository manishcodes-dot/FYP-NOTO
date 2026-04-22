const express = require('express');
const router = express.Router();
const { requireAuth } = require('../../middleware/auth');
const User = require('../users/user.model');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Create Payment Intent
router.post('/create-payment-intent', requireAuth, async (req, res) => {
  try {
    const { plan } = req.body;
    let amount = 0;
    
    if (plan === 'monthly') amount = 300; // $3.00
    else if (plan === 'yearly') amount = 3000; // $30.00
    else return res.status(400).json({ success: false, message: 'Invalid plan' });

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'usd',
      automatic_payment_methods: { enabled: true },
      metadata: { userId: req.userId, plan }
    });

    res.json({
      success: true,
      clientSecret: paymentIntent.client_secret
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Mock subscription - in real life you'd use Stripe/Razorpay
router.post('/subscribe', requireAuth, async (req, res) => {
  try {
    const { plan } = req.body;
    if (!['monthly', 'yearly'].includes(plan)) {
      return res.status(400).json({ success: false, message: 'Invalid plan' });
    }

    const expiry = new Date();
    if (plan === 'monthly') expiry.setMonth(expiry.getMonth() + 1);
    if (plan === 'yearly') expiry.setFullYear(expiry.getFullYear() + 1);

    const user = await User.findByIdAndUpdate(
      req.userId,
      {
        isPremium: true,
        subscriptionPlan: plan,
        subscriptionExpiry: expiry,
      },
      { new: true }
    );

    res.json({
      success: true,
      message: `Successfully subscribed to ${plan} plan`,
      data: {
        isPremium: user.isPremium,
        subscriptionPlan: user.subscriptionPlan,
        subscriptionExpiry: user.subscriptionExpiry,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
