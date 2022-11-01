#!/bin/bash

set +o history
#
# Script to launch tmux in tiled mode with the most common log files being tailed
# for a Flux node https://runonflux.io
#
# Adapte from mapio See original gist below
# https://github.com/mapio/tmux-tail-f/blob/master/tmux-tail-f
#

TMUX=$(type -p tmux) || { echo "This script requires tmux"; exit 1; }

SESSION="FLUX-$$"

NOKILL=0
LAYOUT=tiled

declare -A FILES
if [ ! -d "$HOME/.flux/testnet" ]
then
	FILES+=(
		[2 FluxD]="$HOME/.flux/debug.log"
		[3 BenchMark]="$HOME/.fluxbenchmark/debug.log"
		[1 FluxNode]="$HOME/zelflux/debug.log"
	)
else
	FILES+=(
		[2 FluxD]="$HOME/.flux/testnet/debug.log"
		[3 BenchMark]="$HOME/.fluxbenchmark/testnet/debug.log"
		[1 FluxNode]="$HOME/zelflux/debug.log"
	)
fi

function at_exit() {
    $TMUX kill-session -t "$SESSION" >/dev/null 2>&1
}
[[ "$NOKILL" == "1" ]] || trap at_exit EXIT

$TMUX -q new-session -d -s "$SESSION"

$TMUX set-option -t "$SESSION" -q mouse on

for key in "${!FILES[@]}"; do
    $TMUX -q split-window -t "$SESSION" "printf '\033]2;%s\033\\' '${key}' ; tail -F '${FILES[${key}]}'"
    $TMUX -q select-layout -t "$SESSION" tiled
done

$TMUX -q kill-pane -t "${SESSION}.0"
$TMUX -q select-pane -t "${SESSION}.0"
$TMUX -q select-layout -t "$SESSION" "$LAYOUT"

$TMUX set-option -t "$SESSION" -g status-style bg=colour235,fg=yellow,dim
$TMUX set-window-option -t "$SESSION" -g window-status-style fg=brightblue,bg=colour236,dim
$TMUX set-window-option -t "$SESSION" -g window-status-current-style fg=brightred,bg=colour236,bright

$TMUX -q set-window-option -t "$SESSION" synchronize-panes on
$TMUX set-option -t "$SESSION" -w pane-border-status bottom
$TMUX -q attach -t "$SESSION" >/dev/null 2>&1
