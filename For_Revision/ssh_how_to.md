# Creatign ssh connection

ssh-keygen -t rsa -b 4096 -C "github_rsa_s_Dev_2025"
ls -l ~/.ssh/id_rsa_github_s_dev*
cat ~/.ssh/id_rsa_github_s_dev.pub                     # Paste into account on GitHub
nano ~/.ssh/config                                    # Adding config (can be find on intenet)
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa_github_s_dev
ssh -T git@github.commit                            # Test connection