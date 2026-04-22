const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const authRoutes = require("./modules/auth/auth.routes");
const userRoutes = require("./modules/users/users.routes");
const journalRoutes = require("./modules/journals/journals.routes");
const friendsRoutes = require("./modules/friends/friends.routes");
const aiRoutes = require("./modules/ai/ai.routes");
const paymentRoutes = require("./modules/payments/payment.routes");
const adminRoutes = require("./modules/admin/admin.routes");
const feedbackRoutes = require("./modules/feedback/feedback.routes");

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => res.json({ success: true, message: "ok" }));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/journals", journalRoutes);
app.use("/api/friends", friendsRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/feedback", feedbackRoutes);

app.use((err, _req, res, _next) => {
  res.status(err.status || 500).json({ success: false, message: err.message || "Server error" });
});

module.exports = app;
