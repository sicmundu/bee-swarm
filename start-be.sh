#!/bin/bash
tmux new -d -s bee
tmux send-keys -t bee.0 "sudo bee start --config bee-config.yaml" ENTER
tmux send-keys -t bee.0 "node_password" ENTER
