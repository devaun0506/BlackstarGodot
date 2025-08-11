# Blackstar Game Design Document

## Core Game Loop

### Main Flow
1. **Shift Start** (3-5 seconds)
   - Brief shift intro showing time/date
   - Quick story snippet if relevant
   - Display shift goals (accuracy target, special conditions)

2. **Patient Arrival** (2-3 seconds)
   - Chart slides onto desk with paper sound effect
   - Visual/audio urgency cues (red for critical, alarms for emergent)
   - Auto-highlight priority information

3. **Assessment Phase** (25-45 seconds based on difficulty)
   - Read patient vignette (NBME format, 8-15 sentences)
   - Review vital signs and labs
   - Toggle between full chart and summary (spacebar)
   - Timer visible but non-intrusive

4. **Decision Phase** (included in timer)
   - Question appears: "What is the next best step?" / "Most likely diagnosis?"
   - 5 answer choices appear
   - Quick select: Number keys 1-5 or click
   - Submit with Enter or click Submit

5. **Immediate Feedback** (5-8 seconds)
   - Correct/Incorrect indication
   - Brief explanation why
   - Patient outcome animation
   - Points/accuracy update

6. **Between Patients** (2-3 seconds)
   - Quick breather
   - Coffee cup fills slightly (momentum meter)
   - Next chart already sliding in

### Session Structure
- **Shift Length**: 15-25 patients per shift (10-15 minutes gameplay)
- **Break Points**: Natural pauses every 5 patients for story moments
- **End of Shift**: Performance summary, unlocks, story progression

## Data Structures

### Question Object
```json
{
  "id": "unique_id",
  "specialty": "Internal Medicine",
  "topic": "Myocardial Infarction",
  "difficulty": 1-5,
  "vignette": {
    "demographics": "A 67-year-old man",
    "presentation": "comes to the emergency department because of...",
    "history": "...",
    "physicalExam": "Examination shows...",
    "vitals": {
      "BP": "142/89 mm Hg",
      "HR": "98/min",
      "RR": "18/min",
      "Temp": "37.2°C (99°F)",
      "O2Sat": "94% on room air"
    },
    "labs": {
      "formatted": "Lab table as NBME presents"
    }
  },
  "question": "Which of the following is the most appropriate next step?",
  "choices": [
    {"id": "A", "text": "Aspirin and heparin", "correct": true},
    {"id": "B", "text": "Chest x-ray", "correct": false},
    {"id": "C", "text": "D-dimer", "correct": false},
    {"id": "D", "text": "Troponin level", "correct": false},
    {"id": "E", "text": "CT angiography", "correct": false}
  ],
  "explanation": {
    "correct": "Why this is right...",
    "concepts": "Key teaching points...",
    "distractors": {
      "B": "Why chest x-ray is wrong...",
      "C": "Why D-dimer is wrong..."
    }
  },
  "metadata": {
    "high_yield": true,
    "tested_frequency": "very_high",
    "story_connection": "shift_3_patient_7"
  }
}
```

### Player Progress
```json
{
  "overall_stats": {
    "questions_seen": 1247,
    "accuracy": 0.76,
    "streak": 12,
    "shifts_completed": 8
  },
  "specialty_performance": {
    "Internal Medicine": {
      "accuracy": 0.82,
      "questions_seen": 423,
      "weak_topics": ["Endocrine", "Nephrology"]
    }
  },
  "adaptive_weights": {
    "topic_weights": {},
    "last_seen": {},
    "error_frequency": {}
  },
  "story_progress": {
    "current_shift": 9,
    "discoveries": ["pattern_noticed", "sarah_suspicious"],
    "relationships": {
      "senior_resident": 65,
      "night_nurse": 45,
      "attending": 30
    }
  }
}
```

## UI/UX Layout

### Screen Zones
```
+------------------+------------------+
|     Timer/Shift  |   Story/Coffee   |
+------------------+------------------+
|                                     |
|          Patient Chart              |
|         (Main Focus Area)           |
|                                     |
+-------------------------------------+
|            Question Text            |
+-------------------------------------+
| [A] Choice 1                        |
| [B] Choice 2                        |
| [C] Choice 3                        |
| [D] Choice 4                        |
| [E] Choice 5                        |
+-------------------------------------+
|  Streak: 12  |  Accuracy: 76%       |
+-------------------------------------+
```

### Visual Hierarchy
1. **Primary Focus**: Patient chart (largest, center)
2. **Secondary**: Question and choices (bottom third)
3. **Peripheral**: Stats, timer, story elements (edges)

### Mobile Adaptation
- Portrait orientation primary
- Chart scrollable with momentum scrolling
- Bottom sheet for questions slides up
- Swipe gestures for quick review
- Haptic feedback on selection

## Progression System

### Difficulty Scaling
1. **Timer Progression**
   - Level 1: 45 seconds per case
   - Level 2: 35 seconds per case
   - Level 3: 25 seconds per case

2. **Complexity Progression**
   - Level 1: Clear diagnoses, standard presentations
   - Level 2: Some atypical presentations, comorbidities
   - Level 3: Zebras, multiple valid approaches, time pressure

3. **Unlock Gates**
   - Complete 5 shifts to unlock next difficulty
   - Maintain >70% accuracy to progress
   - Story beats unlock at specific shifts

### Adaptive Algorithm
```
Priority Score = Base Priority 
  × (1 + Error Frequency) 
  × (1 / Days Since Last Seen) 
  × Specialty Weakness Multiplier
  × High Yield Bonus
```

## Feedback System

### Immediate Feedback
- **Visual**: Green/red flash, patient sprite reaction
- **Audio**: Success/failure sound (subtle)
- **Text**: One-line reason displayed instantly

### Detailed Review
- **Post-Question**: Expandable explanation (optional)
- **End of Shift**: Review all missed questions
- **Study Mode**: Untimed practice with full explanations

## Story Integration

### Delivery Mechanisms
1. **Between Patients**: Quick dialogue snippets
2. **Break Points**: Longer story moments every 5 patients
3. **Patient Connections**: Some cases relate to main plot
4. **Environmental**: Background details change (messier desk, more coffee cups)

### Player Agency
- **Dialogue Choices**: Occasional responses affect relationships
- **Chart Decisions**: Some cases affect story (report unusual pattern?)
- **Ending Variations**: Based on choices and performance

## Technical Architecture

### Scene Structure (Godot)
```
Main/
├── MenuScene
├── GameScene/
│   ├── ShiftManager
│   ├── PatientLoader
│   ├── QuestionController
│   ├── TimerSystem
│   ├── FeedbackUI
│   └── StoryManager
├── ResultsScene
└── SettingsScene
```

### File Organization
```
blackstar/
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── data/
│   ├── questions/
│   │   ├── internal_medicine.json
│   │   ├── surgery.json
│   │   └── ...
│   └── story/
│       ├── dialogue.json
│       └── events.json
├── scripts/
│   ├── core/
│   ├── ui/
│   └── systems/
└── scenes/
```

## Save System

### Save Data
- **Autosave**: After each shift
- **Cloud Sync**: Optional for progress across devices
- **Local Storage**: Primary save method
- **Multiple Profiles**: Support different users

### Progress Tracking
- Questions seen (no repeats for 50 questions)
- Performance metrics by topic
- Story decisions and consequences
- Unlocked content and achievements

## Mobile Optimization

### Performance
- **Asset Loading**: Progressive loading during gameplay
- **Memory Management**: Unload previous shift data
- **Battery Optimization**: Reduce effects on low battery

### Touch Controls
- **Large Touch Targets**: Minimum 44px
- **Gesture Support**: Swipe to review, pinch to zoom
- **Haptic Feedback**: Subtle vibration on selection
- **Accessibility**: Font size options, colorblind modes

---

## Next Steps Priority

1. **Create question database structure**
2. **Build core game loop prototype**
3. **Implement timer and scoring system**
4. **Design and test mobile UI**
5. **Integrate first batch of questions**
6. **Add story elements progressively**
7. **Implement adaptive algorithm**
8. **Beta test with medical students**