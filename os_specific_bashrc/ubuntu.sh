# OS check:
# cat /etc/*-release 2>/dev/null | grep 'Ubuntu' -q
#####
# Ubuntu specific things

do_update() {
  (
    cd ~/dot_files && \\
    bash ~/dot_files/bootstrap/ubuntu.sh && \\
    bash ~/dot_files/bootstrap/ubuntu-config.sh && \\
    bash ~/dot_files/init_all.sh
  )
}