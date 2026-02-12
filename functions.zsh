# Fichiers a charger en lazy (au premier appel)
_ZSH_ENV_LAZY_FILES=(ai_context.zsh ai_tokens.zsh)

# Dynamically loading all functions in the "functions" folder
for file in "$ZSH_ENV_DIR/functions"/*; do
    if [[ -f "$file" ]]; then
        local basename="${file:t}"
        # Skip les fichiers lazy-loaded
        if (( ${_ZSH_ENV_LAZY_FILES[(Ie)$basename]} )); then
            continue
        fi
        source "$file"
    fi
done

# Lazy loading stubs pour les fichiers AI (charges au premier appel)
_zsh_env_lazy_load_ai_context() {
    unfunction ai-context ai_context_detect ai_context_init ai_context_generate ai_context_templates ai_context_help 2>/dev/null
    source "$ZSH_ENV_DIR/functions/ai_context.zsh"
    "$@"
}

_zsh_env_lazy_load_ai_tokens() {
    unfunction ai-tokens ai_tokens_estimate ai_tokens_analyze ai_tokens_compress ai_tokens_select ai_tokens_export ai_tokens_help 2>/dev/null
    source "$ZSH_ENV_DIR/functions/ai_tokens.zsh"
    "$@"
}

# Stubs ai-context
ai-context()           { _zsh_env_lazy_load_ai_context ai-context "$@" }
ai_context_detect()    { _zsh_env_lazy_load_ai_context ai_context_detect "$@" }
ai_context_init()      { _zsh_env_lazy_load_ai_context ai_context_init "$@" }
ai_context_generate()  { _zsh_env_lazy_load_ai_context ai_context_generate "$@" }
ai_context_templates() { _zsh_env_lazy_load_ai_context ai_context_templates "$@" }
ai_context_help()      { _zsh_env_lazy_load_ai_context ai_context_help "$@" }

# Stubs ai-tokens
ai-tokens()            { _zsh_env_lazy_load_ai_tokens ai-tokens "$@" }
ai_tokens_estimate()   { _zsh_env_lazy_load_ai_tokens ai_tokens_estimate "$@" }
ai_tokens_analyze()    { _zsh_env_lazy_load_ai_tokens ai_tokens_analyze "$@" }
ai_tokens_compress()   { _zsh_env_lazy_load_ai_tokens ai_tokens_compress "$@" }
ai_tokens_select()     { _zsh_env_lazy_load_ai_tokens ai_tokens_select "$@" }
ai_tokens_export()     { _zsh_env_lazy_load_ai_tokens ai_tokens_export "$@" }
ai_tokens_help()       { _zsh_env_lazy_load_ai_tokens ai_tokens_help "$@" }
