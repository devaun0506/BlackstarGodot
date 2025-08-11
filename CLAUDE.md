# Blackstar
*A high-pressure medical decision-making game for Step 2 CK preparation*

## Overview
Blackstar transforms emergency medicine training into an engaging game where you play as an Emergency Department Attending during a chaotic night shift. Make rapid, critical decisions as patient charts slide across your desk, each requiring immediate triage and treatment decisions that could mean life or death.

## Core Gameplay
**25-45 second decision loops** that simulate real Step 2 CK vignettes:
- **Quick Chart Review**: Patient information auto-highlights by priority (vitals in red, chief complaint in yellow)
- **Rapid Assessment**: Toggle between full charts and at-a-glance summaries with spacebar
- **Authentic Question Format**: Each case presents 5 unique answer choices exactly like Step 2 CK:
  - Questions vary: "What is the next best step?" / "Most likely diagnosis?" / "Most appropriate treatment?"
  - Answer choices specific to each clinical scenario
  - Quick-select with number keys (1-5) or click for speed
  - Pattern recognition develops naturally through repetition

## Educational Features
### Adaptive Learning System
- **Performance tracking** by medical specialty and specific conditions
- **Personalized case delivery** based on your weak areas
- **Spaced repetition** of missed cases for optimal retention
- **High-yield prioritization** matching Step 2 CK exam focus

### Comprehensive Feedback
Every decision comes with:
- Detailed explanations of correct management
- Common pitfalls and why other choices were wrong
- Clinical pearls and mnemonics
- Interactive chart review highlighting critical findings

## Progression System
### Level 1: Intern Coverage (Weeks 1-2)
- Simple, clear-cut presentations
- Single specialty focus per shift
- 45-second timer
- 20% error tolerance

### Level 2: Resident Shift (Weeks 3-4)
- Mixed complexity cases
- Multiple specialties per shift
- 35-second timer
- >85% accuracy required

### Level 3: Attending Overnight (Weeks 5+)
- Complex differentials
- Full Step 2 CK spectrum
- 25-second timer
- >90% accuracy required

### Specialty Rotations (Core Step 2 CK Content)
Progress through actual Step 2 CK specialties:
- **Internal Medicine** - Most heavily tested
- **Surgery** - General surgery and subspecialties
- **Pediatrics** - Newborn through adolescent
- **Obstetrics/Gynecology** - Pregnancy and women's health
- **Psychiatry** - Mental health and behavioral emergencies
- **Family Medicine** - Comprehensive primary care
- **Emergency Medicine** - Acute presentations across all ages

## Visual Design Philosophy
Developing a distinct visual identity that balances clinical precision with human warmth:

- **Medical Color Palette**: Carefully curated hospital palette using medical greens, sterile blues, and urgent reds to create authentic atmosphere while maintaining visual hierarchy
- **Environmental Storytelling**: Rich environmental detail that tells the story of a real working ED: cluttered desks, flickering fluorescents, coffee rings on paperwork, worn but functional medical equipment
- **Medical Typography**: Typography system optimized for medical documentation - ensuring chart readability and quick information scanning within pixel art constraints
- **Character Expression**: Expressive character portraits utilizing limited pixel space to convey patient acuity, emotional states, and clinical urgency through micro-animations
- **Layered Depth**: Multi-plane environments creating a sense of the broader hospital ecosystem beyond the immediate workspace
- **Visual Language**: Cohesive visual language that respects both the gravity of medical decision-making and the humanity of patient care

## Technical Stack
- **Engine**: Godot 4.x
- **Art Pipeline**: Aseprite → Godot importer
- **Platform**: Desktop (Windows/Mac/Linux) + Mobile (iOS/Android)
- **Offline Mode**: Download case packs for study on-the-go

## Development Status

### Step 2 Question Generation
Creating unique, medically accurate NBME-style questions:

#### Question Engineering
- **NBME Format Adherence**: Exact vignette length (8-15 sentences), not shortened
- **Precise Language**: NBME wording patterns ("comes to the emergency department because of..." not casual language)
- **Standardized Vitals**: Proper format with both Celsius and Fahrenheit
- **Clinical Presentation**: "Examination shows..." phrasing with systematic organization
- **Lab Formatting**: Tables exactly as NBME presents them

#### Maximum Uniqueness Protocol
- **Memorable Patient Stories**: Every question features unique details (homeless veteran with diabetes and TB, pregnant teen with sickle cell in a heatwave, elderly pianist with Parkinson's worried about career)
- **Storyline Integration**: Questions connect to Blackstar mystery when possible - patients linked to plot, colleagues' family members as cases
- **Diverse Demographics**: Varied cultural backgrounds, occupations, and social situations for memorable, distinct vignettes
- **Creative Contexts**: Natural disasters, airplanes, music festivals - real medical knowledge in unique settings

#### Medical Accuracy Standards
- **Clinical Soundness**: Real diseases, real drugs, accurate pathophysiology
- **Current Guidelines**: All questions validated against 2024-2025 clinical standards
- **Realistic Values**: Lab values and vital signs within realistic ranges or clearly abnormal with clinical correlation
- **Authentic Interventions**: All treatment options are real procedures and medications

#### High-Yield Reinforcement Through Variation
Same concept appears 5+ times with different angles:
1. **Classic presentation** - Standard textbook case
2. **Atypical demographic** - Unexpected age/gender/background
3. **With complications** - Secondary issues and comorbidities
4. **Post-treatment issues** - Management complications
5. **Diagnostic dilemmas** - Challenging differentials

#### Originality Guarantee
- All questions written from scratch
- Novel patient combinations and scenarios
- Testing same concepts through different clinical stories
- No copying or close paraphrasing of existing questions
- Perfect balance of familiar NBME format with completely original content

### Storyline Development
A grounded ED drama across 15-17 shifts:

#### The Setting
**Blackstar General's ED** - underfunded, understaffed, serving a forgotten part of the city. Every shift is already a battle before anything strange begins.

#### Core Cast
- **Senior Resident**: Grinding through her final year. Sharp, exhausted, carries the weight of too many losses. Her edges soften only when teaching.
- **Night Nurse**: Has seen everything twice. Doesn't talk about his past. Knows which vending machine has the good coffee and which docs to trust.
- **Your Attending**: Brilliant when sober. Going through a divorce. Still the best emergency physician you know when it counts.
- **Medical Student**: On their emergency rotation. Eager, terrified, asks the questions everyone else stopped asking years ago.

#### The Shifts
- **Early shifts (1-5)**: Learn the rhythm. Gunshot wounds. Overdoses. Kids with nowhere else to go. The senior resident teaches you which battles to fight. The night nurse shows you the unwritten rules.
- **Mid shifts (6-10)**: Something's off. Similar symptoms in unrelated patients. The attending's drinking gets worse. The senior resident starts documenting everything. "Just in case," she says.
- **Late shifts (11-14)**: The pattern becomes undeniable. A bad batch of something? Environmental? When administrators start asking questions about your charts, you realize someone doesn't want this noticed.
- **Final shifts (15-17)**: It's about the water supply near the housing projects. The cover-up goes higher than you thought. Do you blow the whistle and risk your career, or keep your head down and survive residency?

#### Narrative Philosophy
Not everyone needs to be saved. Sometimes the victory is just making it through the shift. The mystery unfolds through the everyday chaos of emergency medicine - between codes, during coffee breaks, in the exhausted moments at 4 AM when truth slips out.

### Current Progress
- [x] Pixel art assets created
- [x] Game design document complete
- [x] Storyline development
- [ ] Pixel animations
- [ ] Step 2 question generation
- [ ] Core game loop implementation
- [ ] Adaptive difficulty algorithm
- [ ] Mobile UI optimization
- [ ] Beta testing with med students

## Vision
Blackstar aims to revolutionize medical education by combining addictive gameplay with comprehensive Step 2 CK preparation. Through immersive scenarios and adaptive learning, Blackstar makes studying both effective and genuinely engaging.

## Contributing & Feedback
**We need your input!** Blackstar is being built FOR medical students BY medical students. Your feedback on gameplay, case accuracy, and learning effectiveness is crucial.

**📧 Contact: devaun0506@gmail.com**

Please share:
- What features would help you study better?
- Which specialties need more focus?
- How can we make the time pressure feel realistic but fair?
- Any bugs or confusing mechanics

**The game will feature a prominent "FEEDBACK" button on the main menu** - one click to share your thoughts directly.

Medical professionals and educators interested in content validation or beta testing are especially welcome to reach out.

## License
[License information to be determined]

---
*Blackstar - Where every second counts, and every decision matters.*