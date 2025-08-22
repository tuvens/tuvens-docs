# MCP Documentation Server - External Documentation Access for AI Agents

**Repository**: https://github.com/andrea9293/mcp-documentation-server  
**Purpose**: Enable Claude and other AI agents to read and search external documentation directly  
**Category**: Development Tools & Utilities  

## Overview

The MCP Documentation Server is a TypeScript-based tool that bridges the AI knowledge gap by providing semantic document management and intelligent search capabilities. It enables AI systems like Claude to access, search, and retrieve information from external documentation sources using AI embeddings and semantic search.

### Key Benefits for Agentic Development

🔍 **Semantic Search**: Find relevant documentation using natural language queries  
📄 **Multi-Format Support**: Works with .txt, .md, and .pdf files  
🧠 **Context-Aware**: Retrieves surrounding context around relevant sections  
🌐 **Local Storage**: Keeps your documentation secure and accessible offline  
🚀 **Easy Integration**: Simple setup with NPX or global installation  

## How It Works

The MCP Documentation Server uses AI embeddings to create searchable representations of your documentation:

1. **Document Ingestion**: Upload documents in supported formats
2. **Intelligent Chunking**: Automatically breaks documents into meaningful segments
3. **Embedding Generation**: Creates AI embeddings using transformer models
4. **Semantic Search**: Enables natural language queries to find relevant information
5. **Context Retrieval**: Returns relevant sections with surrounding context

### Technical Architecture

- **Embedding Model**: Default uses "Xenova/all-MiniLM-L6-v2" transformer
- **Storage**: Local file system for documents and embeddings
- **Search**: Vector similarity search for semantic matching
- **Languages**: Multilingual support for international documentation

## Installation & Setup

### Quick Start with NPX (Recommended)

```bash
npx @andrea9293/mcp-documentation-server
```

### Global Installation

```bash
npm install -g @andrea9293/mcp-documentation-server
mcp-documentation-server
```

### From Source

```bash
git clone https://github.com/andrea9293/mcp-documentation-server
cd mcp-documentation-server
npm install
npm start
```

## Usage Examples

### Adding Documents

Use the MCP tool to add documents to your knowledge base:

```json
{
  "tool": "add_document",
  "arguments": {
    "title": "Python Basics Guide",
    "content": "Python is a high-level programming language...",
    "metadata": {
      "category": "programming",
      "tags": ["python", "tutorial", "beginner"]
    }
  }
}
```

### Searching Documentation

Query your documentation using natural language:

```json
{
  "tool": "search_documents",
  "arguments": {
    "query": "How to handle exceptions in Python",
    "limit": 5,
    "context_window": 2
  }
}
```

### Managing Documents

List, update, or remove documents from your knowledge base:

```json
{
  "tool": "list_documents",
  "arguments": {
    "category": "programming"
  }
}
```

## Integration with Tuvens Agents

### For Claude Desktop Users

1. **Install the Server**: Use NPX for quick setup
2. **Configure Claude Desktop**: Add MCP server to your configuration
3. **Upload Documentation**: Add your project documentation files
4. **Query Naturally**: Ask questions about your documentation directly in Claude

### For Development Agents

The MCP Documentation Server is particularly valuable for:

- **vibe-coder**: Accessing architectural documentation and design decisions
- **react-dev**: Referencing React component libraries and best practices
- **laravel-dev**: Querying Laravel framework documentation and patterns
- **devops**: Accessing deployment guides and infrastructure documentation

### Configuration Options

#### Custom Embedding Models

```json
{
  "embedding_model": "sentence-transformers/all-mpnet-base-v2",
  "max_chunk_size": 1000,
  "overlap_size": 200
}
```

#### Storage Configuration

```json
{
  "storage_path": "./docs-storage",
  "index_path": "./embeddings-index",
  "backup_enabled": true
}
```

#### Search Parameters

```json
{
  "default_limit": 10,
  "context_window": 3,
  "similarity_threshold": 0.7
}
```

## Best Practices

### Document Organization

📁 **Categorize Content**: Use metadata categories for better organization  
🏷️ **Tag Documents**: Add relevant tags for improved discoverability  
📝 **Clear Titles**: Use descriptive titles that reflect document content  
🔄 **Regular Updates**: Keep documentation current with your codebase  

### Search Optimization

🎯 **Specific Queries**: Use specific, descriptive search terms  
📊 **Context Windows**: Adjust context window size for optimal results  
🔍 **Multiple Searches**: Try different phrasings for comprehensive results  
📈 **Relevance Tuning**: Adjust similarity thresholds based on needs  

### Maintenance

🧹 **Regular Cleanup**: Remove outdated or duplicate documents  
⚡ **Performance Monitoring**: Monitor search performance and response times  
🔄 **Index Rebuilding**: Rebuild embeddings index when making major changes  
💾 **Backup Strategy**: Maintain backups of your document store  

## Troubleshooting

### Common Issues

**Server Won't Start**
- Check Node.js version (requires 16+)
- Verify all dependencies installed correctly
- Check port availability (default: 3000)

**Search Results Poor**
- Try different search terms or phrases
- Adjust similarity threshold settings
- Verify document quality and completeness
- Consider rebuilding embeddings index

**Memory Usage High**
- Reduce batch size for document processing
- Implement document archiving for old content
- Consider using smaller embedding models

### Performance Optimization

- Use appropriate chunk sizes for your content type
- Implement pagination for large result sets
- Cache frequently accessed documents
- Regular maintenance of embedding indices

## Advanced Features

### Custom Embeddings

The server supports custom embedding models for specialized domains:

```javascript
const customModel = {
  model: "your-custom-model",
  tokenizer: "your-tokenizer",
  max_length: 512
};
```

### Batch Processing

For large documentation sets:

```bash
mcp-documentation-server --batch-upload ./docs-folder
```

### API Integration

Direct API access for programmatic usage:

```javascript
const mcpServer = new MCPDocumentationServer({
  port: 3000,
  apiKey: 'your-api-key'
});
```

## Security Considerations

🔒 **Local Processing**: All documents processed locally for privacy  
🛡️ **Access Control**: Implement appropriate access controls for sensitive docs  
🔐 **API Security**: Use API keys for programmatic access  
📱 **Network Security**: Configure firewall rules for server access  

## Integration Examples

### With Claude Desktop

1. Add to `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "documentation": {
      "command": "npx",
      "args": ["@andrea9293/mcp-documentation-server"],
      "env": {}
    }
  }
}
```

2. Restart Claude Desktop
3. Upload your documentation files
4. Start querying your documents directly in chat

### With Development Workflows

Integrate with your development workflow:

```bash
# Auto-upload documentation on commit
git hook: npx mcp-documentation-server --upload ./docs
```

## Future Enhancements

🚀 **Planned Features**:
- Real-time document synchronization
- Advanced filtering and faceted search
- Integration with popular documentation platforms
- Multi-language translation support
- Version control integration

## Support & Community

- **Issues**: https://github.com/andrea9293/mcp-documentation-server/issues
- **Documentation**: Repository README and Wiki
- **Community**: GitHub Discussions

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `npx @andrea9293/mcp-documentation-server` | Quick start |
| `add_document` | Upload new document |
| `search_documents` | Query documentation |
| `list_documents` | View document inventory |
| `update_document` | Modify existing document |
| `delete_document` | Remove document |

**Last Updated**: 2025-08-22  
**Maintained By**: vibe-coder  
**Version**: 1.0 - Initial documentation  

*This tool significantly enhances AI agent capabilities by providing direct access to external documentation, making development workflows more efficient and context-aware.*