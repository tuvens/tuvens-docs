# Instructions for Updating current-state.md

## ⚠️ CRITICAL: NEVER SKIP THESE INSTRUCTIONS ⚠️

**EVERY Claude session MUST:**
1. Load this instruction file BEFORE editing current-state.md
2. Keep the instruction reference comment at the top of current-state.md
3. Follow the exact format specified below
4. NOT introduce new sections or formatting

## 🛑 Pre-Update Checklist

Before editing current-state.md, verify:
- [ ] You have loaded THIS instruction file
- [ ] The reference comment is present at the top
- [ ] You understand the existing structure
- [ ] You know the current UTC date and time

## 📝 Required Format Structure

### 1. Header Section (NEVER CHANGE FORMAT)
```markdown
# Eventdigest.ai - Current State

**Last Updated**: [Month DD, YYYY, HH:MM AM/PM UTC]
**Previous Update**: [Previous timestamp]

<!-- IMPORTANT: When updating this file, you MUST follow the instructions in docs/project/instructions/current-state.md -->
<!-- DO NOT REMOVE THIS COMMENT - It ensures consistent formatting across all Claude sessions -->
```

### 2. Update the Timestamp
- **Format**: `July 22, 2025, 11:45 AM UTC`
- Use FULL month name (not abbreviated)
- Include both date and time
- Use 12-hour format with AM/PM
- Always use UTC timezone
- Move current "Last Updated" to "Previous Update"

### 3. Section Order (DO NOT CHANGE)
1. 🚦 Overall Status
2. ✅ Implemented Features
3. 🚧 In Progress
4. 📋 Pending Tasks
5. 🛠️ Technical Decisions
6. 🔄 Recent Changes
7. 📊 Stats
8. 🚨 Known Issues
9. 💡 Notes for Next Session

### 4. Update Sections

#### ✅ Implemented Features
- Move completed items here from "In Progress"
- Keep the checkmark format
- Group related items together
- DO NOT delete old completed items

#### 🚧 In Progress
- Items actively being worked on
- Use 📋 for planned but not started
- Use ⏳ for waiting/blocked items

#### 🔄 Recent Changes
- Add new date section for current session
- Format: `### July 22, 2025 (Afternoon - 3:00 PM UTC)`
- Be specific about what changed
- List files created/modified
- Note decisions made
- NEVER delete previous date entries

### 5. Formatting Rules

**ALWAYS:**
- Use ✅ for completed items
- Use 📋 for planned items
- Use ⏳ for blocked items
- Use 🚧 for section headers where appropriate
- Keep bullet point indentation consistent
- Preserve existing emojis

**NEVER:**
- Change section headers
- Remove the instruction comment
- Delete historical information
- Change the overall structure
- Mix auto-generated and manual content

### 6. After Updating

1. Verify the instruction comment is still present
2. Check that all sections are in correct order
3. Ensure timestamp is updated correctly
4. Save the file
5. Include in git commit

### 7. Example Update Entry

```markdown
### July 22, 2025 (Afternoon - 3:00 PM UTC)
- ✅ Created navigation component with responsive design
- ✅ Implemented TDD testing with 85% coverage
- ✅ Added accessibility features (ARIA labels, keyboard navigation)
- 🚧 Started hero section enhancement
- 📋 Planned footer component development
- 🎯 Decision: Use hamburger menu for mobile navigation
```

### 8. Common Mistakes to Avoid

1. **Forgetting the instruction comment** - It must stay at the top
2. **Wrong date format** - Use full month names and UTC timezone
3. **Deleting history** - Keep all previous updates
4. **Changing section order** - Keep the exact structure
5. **Missing progress notes** - Document what was accomplished

## 🚨 FINAL REMINDER

**This document defines the ONLY acceptable format for current-state.md**

If you're unsure about any formatting, refer back to these instructions rather than making assumptions. Consistency across Claude sessions is critical for project continuity.

---

**Note**: This instruction file should be loaded EVERY time before updating current-state.md. The comment in current-state.md serves as a reminder to load this file.