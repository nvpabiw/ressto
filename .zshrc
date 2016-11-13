
function ressto_prompt () {
    REPLY=${RESSTO+(${RESSTO:t}) }
}

grml_theme_add_token ressto -f ressto_prompt '%F{red}' '%f'

zstyle ':prompt:grml:left:setup' items rc ressto change-root user at host path vcs percent
