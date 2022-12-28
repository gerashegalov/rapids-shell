set -ex

sudo apt -y install jq zip unzip maven rsync

sudo -u ubuntu mkdir -p /home/ubuntu/bin

cat << EOF >> /home/ubuntu/init-spark-rapids.sh
#!/bin/bash
cd /home/ubuntu

# Install coursier and bloop CLI
mkdir -p ./bin
cd ./bin
curl -fLo cs https://github.com/coursier/launchers/raw/master/coursier
chmod +x cs
./cs install bloop --only-prebuilt=true
cd -

git clone https://github.com/vlad2/hocon-config-printer
cd hocon-config-printer
./install.sh
cd -

# Add custom tags to your Databricks cluster
# git.user.name - Github handle
# git.full.name - your full name
# git.user.email - email to use for commits
#
DBCONFJSON="/home/ubuntu/bin/hocon-config-printer /databricks/common/conf/deploy.conf"
GIT_USER=\$(\$DBCONFJSON |
  jq -r '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="git.user.name") | .value'
)

GIT_USER_FULL_NAME=\$(\$DBCONFJSON |
  jq -r '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="git.full.name") | .value'
)

GIT_USER_EMAIL=\$(\$DBCONFJSON |
  jq -r '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="git.user.email") | .value'
)

git clone https://github.com/NVIDIA/spark-rapids.git
cd spark-rapids
git remote add "\$GIT_USER" "git@github.com:\${GIT_USER}/spark-rapids.git"
git config --global user.name "\$GIT_USER_FULL_NAME"
git config --global user.email "\$GIT_USER_EMAIL"
EOF

chmod +x /home/ubuntu/init-spark-rapids.sh
sudo -u ubuntu /home/ubuntu/init-spark-rapids.sh


cat << EOF >> /home/ubuntu/.bashrc
source /usr/share/bash-completion/completions/git
if [[ -f \$HOME/.ssh/.agent-env ]]; then
  source  \$HOME/.ssh/.agent-env > /dev/null
else
  ssh-agent > \$HOME/.ssh/.agent-env
fi

export SPARK_HOME=/databricks/spark
export SPARK_CONF_DIR=\$HOME

export PATH=\$PATH:\$HOME/bin:\$HOME/.local/share/coursier/bin
EOF
