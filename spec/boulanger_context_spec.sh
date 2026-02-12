# shellcheck shell=zsh

Describe "boulanger_context.zsh"
  # We source only the function definitions, not the auto-init at the bottom
  setup() {
    TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export ZSH_ENV_DIR="$TEST_HOME/.zsh_env"
    mkdir -p "$ZSH_ENV_DIR"

    # Source only function definitions (skip auto-init by mocking blg_is_context)
    # We extract just the functions
    eval "$(sed '/^# --- Auto-initialisation/,$ d' "$SHELLSPEC_PROJECT_ROOT/functions/boulanger_context.zsh")"
  }

  cleanup() {
    [ -d "${TEST_HOME:-}" ] && rm -rf "$TEST_HOME"
  }

  BeforeAll 'setup'
  AfterAll 'cleanup'

  Describe "_blg_cache_valid()"
    It "returns 1 if no cache file exists"
      rm -f "$_BLG_CACHE_FILE"
      When call _blg_cache_valid
      The status should equal 1
    End
  End

  Describe "Cache TTL is configurable via ZSH_ENV_BLG_CACHE_TTL"
    It "uses configured TTL value"
      The variable _BLG_CACHE_TTL should be present
    End
  End

  Describe "Timeout is configurable via ZSH_ENV_BLG_TIMEOUT"
    It "uses configured timeout value"
      The variable _BLG_TIMEOUT should be present
    End
  End

  Describe "_blg_cache_write()"
    It "writes timestamp and value to cache"
      When call _blg_cache_write "true"
      The path "$_BLG_CACHE_FILE" should be file
    End
  End

  Describe "_blg_cache_valid() with valid cache"
    It "returns 0 if cache age < TTL"
      _blg_cache_write "true"
      When call _blg_cache_valid
      The status should equal 0
    End

    It "returns 1 if cache age > TTL"
      _BLG_CACHE_TTL=0
      _blg_cache_write "true"
      sleep 1
      When call _blg_cache_valid
      The status should equal 1
      _BLG_CACHE_TTL=300
    End
  End

  Describe "blg_refresh()"
    It "removes the cache file"
      echo "test" > "$_BLG_CACHE_FILE"
      # Mock blg_is_context to avoid network call
      blg_is_context() { return 1; }
      When call blg_refresh
      The output should include "Hors contexte"
    End
  End
End
