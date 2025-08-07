# 📋 Code Review Standards

### Pull Request Requirements

#### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Cross-Repository Impact
- [ ] No other repositories affected
- [ ] Updates required in: [list repositories]
- [ ] Integration tests updated

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Documentation
- [ ] Code comments updated
- [ ] API documentation updated
- [ ] Integration guides updated
- [ ] Claude Code instructions updated

## Security
- [ ] No sensitive data exposed
- [ ] Authentication/authorization properly implemented
- [ ] Input validation added
- [ ] Security tests pass
```

#### Review Checklist

**Code Quality**:
- [ ] Code follows established style guidelines
- [ ] No code duplication
- [ ] Proper error handling
- [ ] Appropriate logging levels
- [ ] Performance considerations addressed

**Security**:
- [ ] Input validation implemented
- [ ] Authentication/authorization checked
- [ ] No sensitive data in logs
- [ ] SQL injection prevention
- [ ] XSS prevention measures

**Integration**:
- [ ] API contracts maintained
- [ ] Backward compatibility preserved
- [ ] Database migrations reviewed
- [ ] Cross-repository dependencies documented

**Documentation**:
- [ ] README updated if needed
- [ ] API documentation current
- [ ] Integration guides accurate
- [ ] Comments explain complex logic