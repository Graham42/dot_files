# This block is added to ~/.bashrc automatically by the init script
if [ -f ~/.bashrc_extend.sh ]; then
    source ~/.bashrc_extend.sh
else
    echo "Warning: ~/.bashrc_extend.sh expected but not found. Please ensure it exists."
fi
