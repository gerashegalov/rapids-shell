set -x

sudo apt -y install jq zip unzip maven rsync
(
  ORIG_DIR=$PWD
  cd /home/ubuntu

  # Install coursier and bloop CLI
  sudo -u ubuntu mkdir -p ./bin
  cd ./bin
  sudo -u ubuntu bash -c "curl -fLo cs https://github.com/coursier/launchers/raw/master/coursier && chmod +x cs && ./cs install bloop --only-prebuilt=true"
  cd -

  sudo -u ubuntu git clone https://github.com/vlad2/hocon-config-printer
  cd hocon-config-printer
  sudo -u ubuntu ./install.sh
  cd -

  # Add custom tags to your Databricks cluster
  # git.user.name - Github handle
  # git.full.name - your full name
  # git.user.email - email to use for commits
  #
  DBCONFJSON="/home/ubuntu/bin/hocon-config-printer /databricks/common/conf/deploy.conf"
  GIT_USER=$($DBCONFJSON |
    jq -r '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="git.user.name") | .value'
  )

  GIT_USER_FULL_NAME=$($DBCONFJSON |
    jq -r '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="git.full.name") | .value'
  )

  GIT_USER_EMAIL=$($DBCONFJSON |
    jq -r '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="git.user.email") | .value'
  )

  sudo -u ubuntu git clone https://github.com/NVIDIA/spark-rapids.git
  cd spark-rapids
  sudo -u ubuntu git remote add "$GIT_USER" "git@github.com:${GIT_USER}/spark-rapids.git"
  sudo -u ubuntu git config --global user.name "$GIT_USER_FULL_NAME"
  sudo -u ubuntu git config --global user.email "$GIT_USER_EMAIL"
)

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
