const express = require('express');
const router = express.Router();
const https = require('https');
const { requireAuth } = require('../../middleware/auth');
const User = require('../users/user.model');

// Helper to call Groq API without dependencies
const callGroq = (messages) => {
  return new Promise((resolve, reject) => {
    if (!process.env.GROQ_API_KEY) {
      return reject(new Error('GROQ_API_KEY is not defined in .env'));
    }

    const data = JSON.stringify({
      model: 'llama-3.3-70b-versatile',
      messages: [
        {
          role: 'system',
          content: 'You are NOTO AI, a helpful journaling assistant. If the user asks to generate notes, provide structured, clear content. Keep responses concise and formatted well.',
        },
        ...messages,
      ],
      temperature: 0.7,
      max_tokens: 1024,
    });

    console.log('Sending to Groq:', data);

    const options = {
      hostname: 'api.groq.com',
      path: '/openai/v1/chat/completions',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.GROQ_API_KEY.trim()}`,
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        console.log('Groq Response Body:', body);
        try {
          const parsed = JSON.parse(body);
          if (parsed && parsed.error) {
            reject(new Error(parsed.error.message));
          } else if (parsed && parsed.choices && parsed.choices[0]) {
            resolve(parsed.choices[0].message.content);
          } else {
            console.error('Parsed Groq Error:', parsed);
            reject(new Error('Invalid response from AI service'));
          }
        } catch (e) {
          console.error('JSON Parse Error:', e, 'Body:', body);
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      console.error('HTTPS Request Error:', e);
      reject(e);
    });
    req.write(data);
    req.end();
  });
};

router.post('/chat', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user || !user.isPremium) {
      return res.status(403).json({ success: false, message: 'Premium subscription required for AI features' });
    }

    const { messages } = req.body;
    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ success: false, message: 'Messages array is required' });
    }

    const aiResponse = await callGroq(messages);
    res.json({ success: true, data: { content: aiResponse } });
  } catch (error) {
    console.error('AI Chat Error:', error);
    res.status(500).json({ success: false, message: error.message || 'AI service error' });
  }
});

module.exports = router;
