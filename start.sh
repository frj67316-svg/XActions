#!/bin/sh
# ═══════════════════════════════════════════════════════════════════════════════
# XActions — Start Script
# Supports both API mode and MCP mode (Grok-compatible)
# ═══════════════════════════════════════════════════════════════════════════════

# Detect mode: if MCP_TRANSPORT is set, run as MCP server
if [ "$MCP_TRANSPORT" = "http" ] || [ "$MCP_TRANSPORT" = "sse" ]; then
  echo "🚀 Starting XActions MCP Server..."
  echo "📡 Transport: $MCP_TRANSPORT"
  echo "🔌 Port: ${PORT:-3000}"

  if [ -z "$XACTIONS_SESSION_COOKIE" ]; then
    echo "⚠️  WARNING: XACTIONS_SESSION_COOKIE not set."
    echo "   MCP tools like posting tweets will not work."
    echo "   Set it in Render dashboard → Environment."
  fi

  if [ -n "$OPENROUTER_API_KEY" ]; then
    echo "🤖 AI tools enabled (OpenRouter)"
  fi

  # Start MCP server with HTTP transport
  exec node src/mcp/server.js
fi

# Otherwise, run as regular API server
echo "🚀 Starting XActions API Server..."

# Run database migrations only if DATABASE_URL is available
if [ -n "$DATABASE_URL" ]; then
  echo "🔄 Running database migrations..."
  npx prisma migrate deploy || {
    echo "⚠️  Tables exist without migration history - marking baseline as applied..."
    npx prisma migrate resolve --applied "0_init" && npx prisma migrate deploy
  } || echo "⚠️  Migration warning (non-fatal), continuing..."
else
  echo "⚠️ DATABASE_URL not set, skipping migrations"
fi

exec node api/server.js
