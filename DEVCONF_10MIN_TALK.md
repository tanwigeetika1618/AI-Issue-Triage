# ⚡ DevConf Pune - 10-Minute Lightning Talk

## AI-Powered Issue Triage: From Chaos to Clarity in Seconds

**Total Time:** 15 minutes  
**Content:** 10-11 minutes  
**Q&A:** 4-5 minutes

---

## 🎯 Golden Rule for 10-Minute Talks

> **Show, don't tell.** Start the demo EARLY. Let the AI do the talking for you.

---

## ⏱️ Tight Timeline

| Time | Section | Duration |
|------|---------|----------|
| 0:00 | Hook + Problem | 1.5 min |
| 1:30 | Solution (What it does) | 1.5 min |
| 3:00 | **LIVE DEMO** | 5 min |
| 8:00 | Future + Call to Action | 2 min |
| 10:00 | Q&A Begins | 5 min |

---

## 📊 Slides (6-7 slides MAX)

### **Slide 1: Title (10 seconds)**
```
AI-Powered Issue Triage
From Chaos to Clarity in Seconds
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tanwi Geetika | DevConf Pune 2026
```

---

### **Slide 2: The Problem (1 min)**

**What you say:**
> "Maintainers spend 40% of their time on manual triage - reading issues, searching code, finding duplicates, labeling. In Ansible alone, that's hundreds of hours monthly."

```
┌─────────────────────────────────────────┐
│     The Manual Triage Nightmare         │
├─────────────────────────────────────────┤
│  📖 Reading unclear bug reports         │
│  🔍 Searching codebase for context      │
│  🔄 Hunting for duplicates              │
│  🏷️ Labeling and categorizing           │
│                                         │
│     = 40%+ of maintainer time           │
└─────────────────────────────────────────┘
```

---

### **Slide 3: The Solution (1 min)**

**What you say:**
> "What if AI could triage like an experienced engineer? That's what we built."

```
┌─────────────────────────────────────────┐
│        🤖 AI Issue Triage               │
├─────────────────────────────────────────┤
│  ✅ Analyzes using YOUR codebase        │
│  ✅ Finds root cause + code locations   │
│  ✅ Suggests fixes with line numbers    │
│  ✅ Auto-labels: type + severity        │
│  ✅ Detects duplicates semantically     │
│  ✅ Blocks prompt injection attacks     │
├─────────────────────────────────────────┤
│  📍 GitHub Actions (Jira coming soon)   │
└─────────────────────────────────────────┘
```

---

### **Slide 4: Demo Time! (transition slide)**

```
        🎬 LIVE DEMO

    Let's see it in action...
    
    Creating a real issue RIGHT NOW
```

**What you say:**
> "Let me show you this working on a real repository."

---

### **Slide 5: How It Works (show DURING demo while waiting)**

```
   Issue Created
        │
        ▼
  ┌─────────────┐
  │  Security   │ ← Prompt injection check
  │  Check      │
  └─────────────┘
        │
        ▼
  ┌─────────────┐
  │  Duplicate  │ ← Compare with open issues
  │  Detection  │
  └─────────────┘
        │
        ▼
  ┌─────────────────────────────────┐
  │     Repomix + Gemini AI         │
  │  (your codebase as context)     │
  └─────────────────────────────────┘
        │
        ▼
  📝 Analysis + 🏷️ Labels
```

---

### **Slide 6: What's Next (1.5 min)**

```
┌─────────────────────────────────────────┐
│           🚀 Roadmap 2026               │
├─────────────────────────────────────────┤
│  🔜 Jira Integration                    │
│  🔜 GitLab Support                      │
│  🔜 Bot-as-a-Service                    │
│  🔜 Interactive mode (/reanalyze)       │
│  🔜 Multi-model support                 │
└─────────────────────────────────────────┘
```

---

### **Slide 7: Try It! (30 sec)**

```
┌─────────────────────────────────────────┐
│           Try It Today! 🎉             │
├─────────────────────────────────────────┤
│                                         │
│  🔗 github.com/tanwigeetika1618/        │
│           AI-Issue-Triage               │
│                                         │
│  Setup in 10 minutes:                   │
│  1. Copy workflow files                 │
│  2. Add Gemini API key                  │
│  3. Create an issue → Magic! ✨         │
│                                         │
├─────────────────────────────────────────┤
│         Questions? 🤔                   │
└─────────────────────────────────────────┘
```

---

## 🎬 LIVE DEMO SCRIPT (5 minutes)

### Pre-Demo Setup (do 5 min before your talk)

1. Open browser tabs:
   - **Tab 1:** New issue form (ready to paste)
   - **Tab 2:** Actions tab (to show workflow)
   - **Tab 3:** Issue list (to see result)

2. Have this issue ready to paste:

```
Title: CLI argument parsing fails with special characters

Body:
When running ansible-creator with arguments containing special characters, the parser throws an error.

**Steps:**
1. Run: `ansible-creator init --name "test" --path "/tmp/my path/"`
2. Error: ArgumentError

**Expected:** Handle spaces gracefully
**Actual:** Crashes

Environment: Python 3.11, Linux
```

---

### Demo Flow (5 minutes)

#### **0:00-1:00 - Create Issue**

**Actions:**
1. Go to Issues → New Issue
2. Paste the title
3. Paste the body
4. Add `Gemini Analyze` label
5. Click Submit

**What you say:**
> "I'm creating a real bug report right now. Watch what happens when I add the Gemini Analyze label..."

---

#### **1:00-2:30 - Show Workflow Running**

**Switch to Actions tab**

**What you say (while workflow runs):**
> "The workflow is now running. It's doing three things:
> 
> First, a security check - making sure this isn't a prompt injection attack.
> 
> Second, duplicate detection - comparing against all open issues.
> 
> Third, sending the issue PLUS our entire codebase to Gemini AI for analysis.
> 
> The key innovation here is that the AI has your actual code as context - it's not guessing."

*Show Slide 5 (architecture) during this time*

---

#### **2:30-4:30 - Show Results**

**Switch back to the issue**

**What you say:**
> "And here's the result! Let me walk you through what we got..."

**Point out:**
1. **Type & Severity badges** - "It classified this as a bug, medium severity"
2. **Root Cause** - "It identified the primary cause in our argument parsing"
3. **Code Location** - "Look - actual file paths and line numbers from our codebase"
4. **Proposed Solution** - "And here's the suggested fix"
5. **Labels** - "Notice the labels were auto-applied"

---

#### **4:30-5:00 - Quick Security Mention**

**What you say:**
> "One more thing - if someone tries to manipulate the AI with prompt injection, it blocks them automatically and adds a security warning. We've tested this extensively."

*(Don't demo this - just mention it to save time)*

---

## 🗣️ Script Summary (What to Say)

### Opening (10 sec)
> "Hi everyone! I'm Tanwi, and I'm going to show you how AI can transform issue triage from hours to seconds."

### Problem (1 min)
> "If you're a maintainer, you know the pain - 40% of your time goes to reading issues, searching code, finding duplicates. It's exhausting."

### Solution (1 min)
> "We built an AI system that does this automatically. It uses YOUR codebase as context, finds root causes, suggests fixes with actual file paths, detects duplicates, and even blocks prompt injection attacks. Let me show you."

### Demo (5 min)
> *[As scripted above]*

### Future (1 min)
> "This works on GitHub today. We're adding Jira, GitLab, and a hosted bot service. We're also working on interactive mode where you can chat with the AI about the issue."

### Close (30 sec)
> "The repo is open source - link on the slide. Setup takes 10 minutes. Try it on your project. Questions?"

---

## ⚠️ Backup Plan

If the demo fails (API error, slow network):

1. **Have a pre-recorded 90-second video** showing:
   - Issue creation
   - Workflow running
   - Result appearing

2. **Have screenshots** of:
   - A completed analysis comment
   - Labels applied
   - Security block example

**Say:** "Let me show you a recording from earlier today..."

---

## 🎯 Key Messages (Repeat These)

1. **"Uses YOUR codebase as context"** - This is the differentiator
2. **"Hours to seconds"** - The impact
3. **"Open source, 10 minutes to set up"** - Low barrier
4. **"Security built-in"** - Enterprise ready

---

## ❓ Q&A Quick Answers (5 min)

| Question | Short Answer |
|----------|--------------|
| Cost? | "Gemini free tier is generous. Pennies per issue." |
| Accuracy? | "80-85% on root cause. Custom prompts improve it." |
| Private repos? | "Yes, runs in YOUR GitHub Actions runner." |
| Hallucinations? | "We have retry logic. Active area of improvement." |
| Other AI models? | "Gemini now, Claude/GPT on roadmap." |
| Production ready? | "Yes, we use it in Ansible ecosystem." |

---

## 📋 Pre-Talk Checklist

### Day Before
- [ ] Test the full demo flow
- [ ] Record backup video
- [ ] Screenshot successful results
- [ ] Verify API key has credits

### 1 Hour Before
- [ ] Open all browser tabs
- [ ] Copy issue text to clipboard/notepad
- [ ] Test internet connection
- [ ] Increase browser font size (Cmd+)

### 5 Min Before
- [ ] Clear any test issues (fresh state)
- [ ] Position browser tabs in order
- [ ] Deep breath 😊

---

## 🎤 Presentation Tips for 10 Minutes

1. **Don't apologize** for short time - own it
2. **Start with energy** - you have 10 seconds to hook them
3. **Demo early** - let the product speak
4. **Skip details** - they can read docs later
5. **End with action** - "Try it today!"

---

## Good luck! 🚀

Remember: The demo IS your presentation. Everything else is just setup for that moment when the AI analysis appears. That's your wow moment.


