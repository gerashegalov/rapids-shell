set -x

sudo apt -y install jq zip unzip maven rsync
sudo "$(which pip)" install pytest sre_yield requests pandas pyarrow findspark pytest-xdist pytest-order

(
  cd /home/ubuntu

  sudo -u ubuntu git clone https://github.com/vlad2/hocon-config-printer
  cd hocon-config-printer
  sudo -u ubuntu ./install.sh
  cd -

  # TODO transiton to tags to encode git config
  # hocon-config-printer /databricks/common/conf/deploy.conf  | jq '."all-projects".spark.databricks.clusterUsageTags.clusterAllTags | fromjson | .[] | select(.key=="Creator")'
  GIT_USER="johndoe"
  GIT_USER_FULL_NAME="John Doe"
  GIT_USER_EMAIL="noreply@spark-rapids-non-exisitng.org"

  sudo -u ubuntu git clone https://github.com/NVIDIA/spark-rapids.git
  cd spark-rapids
  sudo -u ubuntu git remote add "$GIT_USER" "git@github.com:${GIT_USER}/spark-rapids.git"
  sudo -u ubuntu git config --global user.name "$GIT_USER_FULL_NAME"
  sudo -u ubuntu git config --global user.email "$GIT_USER_EMAIL"
)

cat << EOF >> /home/ubuntu/.bashrc
source /usr/share/bash-completion/completions/git
if [[ -f /home/ubuntu/.ssh/.agent-env ]]; then
  source  /home/ubuntu/.ssh/.agent-env
else
  ssh-agent > /home/ubuntu/.ssh/.agent-env
fi

export SPARK_HOME=/databricks/spark
export SPARK_CONF_DIR=$HOME

export PATH=$PATH:$HOME/bin
EOF
