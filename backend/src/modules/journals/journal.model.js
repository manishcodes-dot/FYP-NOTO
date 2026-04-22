const mongoose = require("mongoose");

const moods = ["Happy", "Calm", "Neutral", "Sad", "Stressed"];
const categories = ["Personal", "Study", "Work", "Family", "Ideas", "Goals"];

const journalSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    title: { type: String, required: true, trim: true },
    content: { type: String, required: true },
    mood: { type: String, enum: moods, required: true },
    category: { type: String, enum: categories, required: true },
    tags: [{ type: String }],
    isFavorite: { type: Boolean, default: false },
    isPinned: { type: Boolean, default: false },
    entryDate: { type: Date, required: true, index: true },
    sharedWith: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  },
  { timestamps: true }
);

module.exports = mongoose.model("JournalEntry", journalSchema);
