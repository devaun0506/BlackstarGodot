# Assistant Rules for Blackstar Project

## Code Style Rules
- Use tabs for indentation in GDScript files
- Always add type hints to function parameters and return types
- Maximum line length: 100 characters
- Use descriptive variable names (no single letters except in loops)

## Git Workflow
- Always create descriptive commit messages with:
  - First line: Brief summary (50 chars max)
  - Second line: Blank
  - Third line onwards: Detailed explanation if needed
- Never push directly to main without asking
- Always run tests before committing (when tests exist)

## Godot Specific
- Prefer signals over direct node references when possible
- Always free() nodes that are created dynamically
- Use @onready for node references
- Organize scripts into proper folders (core/, ui/, systems/)

## Project Specific
- Medical accuracy is paramount - verify all medical information
- Keep NBME question format exactly as specified
- Maintain the 32-color palette limit for pixel art
- Story elements should never interrupt core gameplay
- Performance target: 60 FPS on mid-range hardware

## Communication Style
- Be concise but thorough
- Always explain medical/technical decisions
- Warn before making breaking changes
- Ask for clarification if requirements are ambiguous

## File Management
- Never delete files without confirmation
- Always backup before major refactoring
- Keep documentation up to date with code changes
- Update CLAUDE.md when adding major features

## Testing Requirements
- Test all patient case JSON files load correctly
- Verify timer system works at all difficulty levels
- Check scene transitions don't cause memory leaks
- Ensure mobile controls work if implementing mobile features

## Do NOT:
- Add unnecessary comments to code
- Create files without explicit need
- Use placeholder data in production code
- Commit sensitive information (API keys, passwords)
- Change core game mechanics without discussion

## Mandatory Subagent Creation:
- CodeReviewAgent: For every code change
- PerformanceAgent: For optimization tasks
- MedicalAccuracyAgent: For medical content
- ArchitectureAgent: For system design
- TestingAgent: For functionality verification
- GraphicsUIAgent: For visual improvements

## Always:
- Validate JSON data before using
- Handle errors gracefully with fallbacks
- Maintain backwards compatibility with save files
- Follow medical ethics in content creation
- Optimize for readability over cleverness
- Create specialized subagents for quality assurance
- Continuously improve graphics and UI flow