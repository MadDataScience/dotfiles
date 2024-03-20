# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="amuse"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME="devcontainers"
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
#!/bin/bash

###############################################
# Runs at the start of every terminal session #
###############################################

if [[ -z "$REMOTE_CONTAINERS" ]]; then
  export TRANSCEND_DIR=${TRANSCEND_DIR:=$HOME/transcend}
fi
export GITHUB_USER=${GITHUB_USER:=$(git config user.name)}
export EDITOR="code -w -n"

#####################
# Utility Functions #
#####################

# Determines what something is.
# Usage Examples:
# wtf yarn -> gives the summary of yarn from `tldr`
# wtf gpohf -> shows what the alias stands for
# wtf wtf -> shows the function definition
# wtf tfenv -> shows the location of the binary
wtf() {
  # Check for documentation on well known packages
  (tldr "$@" > /dev/null && tldr "$@") || \
  # Check if it's a function
  (declare -f "$@" > /dev/null && echo "Found function $*:" && declare -f "$@") || \
  # Check if it's an alias
  (alias "$@" > /dev/null && echo "Found alias $*" && alias "$@") || \
  # Check if it's some other binary
  (command -v "$@" > /dev/null && echo "Found binary $*" && command -v "$@") || \
  # Fail
  echo "Could not find $*"
}

# Example usage:
# releaseAirgap 8.9.1-minhtest staging
releaseAirgap() {
  if [ $# -eq 0 ] || [ -z "$2" ]
  then
    echo "Must provide the version that we are building and the environment, i.e. releaseAirgap 7.24.8 dev"
    return 1
  fi
  if [ "$2" = "dev" ]
  then
    VAULTIFY_SUFFIX="sandbox"
    CDN_SUFFIX="dev"
  else
    VAULTIFY_SUFFIX=$2
    CDN_SUFFIX=$2
  fi
  vaultify "transcend-$VAULTIFY_SUFFIX" &&
  yarn workspace @main/airgap.js build --env prod &&
  aws s3 cp \
    consent-manager/airgap.js/build/core.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/core.js"
  aws s3 cp \
    consent-manager/airgap.js/build/ui.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/ui.js"
  aws s3 cp \
    consent-manager/airgap.js/build/cm.css \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/cm.css"
  aws s3 cp \
    consent-manager/airgap.js/build/xdi.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/xdi.js"
  aws s3 cp \
    consent-manager/airgap.js/build/explorer.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/explorer.js"
  aws s3 cp \
    consent-manager/airgap.js/build/translations \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/translations" \
    --recursive
  aws s3 cp \
    consent-manager/airgap.js/build/tcfUi.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/tcfUi.js"
  aws s3 cp \
    consent-manager/airgap.js/build/tcf.css \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/tcf.css"
  aws s3 cp \
    consent-manager/airgap.js/build/tcf/translations \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/tcf/translations" \
    --recursive
  aws s3 cp \
    consent-manager/airgap.js/build/gpp.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/gpp.js"
  aws s3 cp \
    consent-manager/airgap.js/build/bridge.js \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/bridge.js"
  aws s3 cp \
    consent-manager/airgap.js/build/bridge.html \
    "s3://cloudfront-origin-cdn-$CDN_SUFFIX-transcend-io/airgap.js/builds/$1/bridge.html"
  if [ "$2" = "dev" ]
  then
    aws cloudfront create-invalidation \
      --distribution-id "$(vault kv get --field=CLOUDFRONT_DISTRIBUTION_ID kv/cloudfront)" \
      --paths "/airgap.js/builds/$1*" \
      --no-cli-pager
    echo "Invalidated /airgap.js/builds/$1*"
  fi
}

# Example usage: airgapSizeDiff csmccarthy/new-branch (branch optional)
airgapSizeDiff() {
  if [ $# -eq 0 ]
  then
    echo Building current bundle...$'\n'
    yarn workspace @main/airgap.js build --env prod
    CURRENT_SIZE=$(stat -c %s consent-manager/airgap.js/build/core.js)
    echo $'\n'Stashing changes...$'\n'
    git stash
    CURRENT_BRANCH=$(git branch --show-current)
  else
    echo $'\n'Stashing changes...$'\n'
    git stash
    CURRENT_BRANCH=$(git branch --show-current)
    git checkout "$1"
    echo Building current bundle...$'\n'
    yarn workspace @main/airgap.js build --env prod
    CURRENT_SIZE=$(stat -c %s consent-manager/airgap.js/build/core.js)
  fi
  git switch dev
  echo $'\n'Building dev bundle...$'\n'
  yarn workspace @main/airgap.js build --env prod
  OLD_SIZE=$(stat -c %s consent-manager/airgap.js/build/core.js)
  git checkout "$CURRENT_BRANCH"
  echo $'\n'Applying stashed changes...$'\n'
  git stash apply
  echo $'\n'Bundle size diff from dev: $(( CURRENT_SIZE - OLD_SIZE )) bytes
}

#########
# Repos #
#########

if [[ -z "$REMOTE_CONTAINERS" ]]; then
  export MAIN_DIR="$TRANSCEND_DIR/main"
else
  export MAIN_DIR="$TRANSCEND_DIR"
fi
alias transcend='cd $TRANSCEND_DIR'
alias main='cd $MAIN_DIR'
alias gen='yarn workspace @main/plop plop'
alias ag='cd $MAIN_DIR/consent-manager/airgap.js'
alias bk='cd $MAIN_DIR/packages/backend'
alias in='cd $MAIN_DIR/infra'
alias ad='cd $MAIN_DIR/frontend-services/admin-dashboard'
alias pc='cd $MAIN_DIR/frontend-services/privacy-center'
alias sm='cd $MAIN_DIR/backend-services/sombra'
alias sc='cd $MAIN_DIR/scripts'

# Open a folder in the transcend repo
tr() {
  if [ $# -eq 0 ]
  then
    echo "Must provide the name of the folder i.e. 'tr main'"
  else
        if [ ! -d "$TRANSCEND_DIR/$1" ]; then
           echo "Directory does not exists: $1"
    else
     code "$TRANSCEND_DIR/$1"
          fi
  fi
}

###############
# Pre-Commits #
###############

# Skip docker base pre-commits if docker is not running
if docker info &> /dev/null;
then
  if [[ -z "$REMOTE_CONTAINERS" ]]; then
    export SKIP=""
  else
    export SKIP="dockerfile-lint,check-executables-have-shebangs"
  fi
else
  export SKIP=shellcheck-lint,dockerfile-lint,check-executables-have-shebangs,terraform-fmt
fi

#######
# AWS #
#######

export AWS_PROFILE=transcend-sandbox
export AWS_SDK_LOAD_CONFIG=true
export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=eu-west-1
alias roles="cat ~/.aws/config | grep role_arn"

# The docker registry to push and pull from
export DOCKER_REMOTE=${AWS_ECR_ACCOUNT_URL:-"812352284159.dkr.ecr.eu-west-1.amazonaws.com"}

# Turning on the docker buildkit allows us to speed up builds.
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

##########
# Pulumi #
##########

pulumify() {
  if [ $# -eq 0 ]
  then
    echo "Must provide pulumi environment"
  else
    export ENV="$1"
    pulumi login "s3://${1:-dev}-pulumi-state-transcend-io"
    pulumi whoami
  fi
}

deploy() {
  if [ $# -lt 2 ]
  then
    echo "Must provide the name of the workspace i.e. 'my-new-feature' and the env i.e. 'staging'"
  else
    workspace="$1"
    env="$2"
    stack="$(echo "$workspace" | sed 's/^@//' | sed 's/[\/]/./g').$env"

    case "${env}" in
      dev)
        vault_profile="transcend-sandbox"
        profile="transcend-sandbox"
        ;;
      staging)
        vault_profile="transcend-staging"
        profile="transcend-staging"
        ;;
      prod)
        if aws sts get-caller-identity --profile transcend-prod-admin > /dev/null 2>&1 ; then
            profile="transcend-prod-admin"
        else
            profile="transcend-prod"
        fi
        vault_profile="transcend-prod"
        ;;
      *)
        echo "Not a valid env"
        exit 1
        ;;
    esac

    case "$workspace" in
      "@main/infra-aws-plugin-silo-discovery")
        profile="transcend-aws-plugin-silo-discovery"
        ;;
      "@main/github-actions-runners-infra")
        profile="transcend-ci-runners"
        ;;
      "@main/infra-pulumi-state")
        profile="transcend-pulumi-state"
        ;;
      "@main/infra-internally-available-ecr")
        profile="transcend-commons"
        ;;
    esac

    echo "Deploying workspace $workspace to env $env via stack named $stack using profile $profile"
    AWS_PROFILE="$profile" pulumify "$env"
    vaultify "$vault_profile"
    # TODO: https://github.com/pulumi/pulumi/issues/5657 - remove `PULUMI_CONFIG_PASSPHRASE` once no longer needed
    PULUMI_CONFIG_PASSPHRASE=not-used AWS_PROFILE="$profile" yarn workspace "$workspace" exec pulumi up --stack "$stack" "${@:3}"
    # PULUMI_CONFIG_PASSPHRASE=not-used AWS_PROFILE="$profile" yarn workspace "$workspace" exec pulumi up --stack "$stack" --refresh
  fi
}

###################
# Hashicorp Vault #
###################

export VAULT_ADDR="https://vault.dev.trancsend.com"
# Assume another role in vault
vaultify() {
  if [ $# -eq 0 ]
  then
    echo "Must provide vault environment"
  else
    export AWS_PROFILE="$1"
    case "${AWS_PROFILE}" in
      transcend-sandbox)
        export VAULT_ADDR=https://vault.dev.trancsend.com
        export AWS_PROFILE=transcend-sandbox
        ;;
      transcend-staging)
        export VAULT_ADDR=https://vault.staging.transcen.dental
        export AWS_PROFILE=transcend-staging
        ;;
      transcend-prod)
        export VAULT_ADDR=https://vault.transcend.io
        export AWS_PROFILE=transcend-prod
        ;;
      *)
        echo "Not a valid profile"
        ;;
    esac

    yarn workspace @main/main script aws/vault_login --vault-role developer_role
    if [[ -z "$REMOTE_CONTAINERS" ]]; then
      vault print token | pbcopy
    else
      vault print token
    fi
  fi
  if [[ -z "$REMOTE_CONTAINERS" ]]; then
    echo "Your key is copied.  Go to $VAULT_ADDR to login"
  else
    echo "Your key is shown above.  Go to $VAULT_ADDR to login"
  fi
}

##########
# Python #
##########

export ZSH_GIT_PROMPT_PYBIN=/usr/bin/python3


##########
# Docker #
##########

alias dock:kill='docker stop $(docker ps -a -q)'
alias dock:clean="docker system prune -a"
alias dock:start="open /Applications/Docker.app/"
alias db="yarn docker:build"

######
# Go #
######

if [[ -z "$REMOTE_CONTAINERS" ]]; then
  export GOPATH="${HOME}/.go"
  GOROOT="$(brew --prefix golang)/libexec"
  export GOROOT=$GOROOT
  export GOBIN="${GOPATH}/bin"
  test -d "${GOPATH}" || mkdir "${GOPATH}"
  test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"
  export PATH=$HOME/bin:/usr/local/bin:~/.tfenv/bin:$PATH:${GOBIN}:${GOROOT}/bin
else
  export GOROOT=/usr/local/go
  export PATH="$PATH:/usr/local/go/bin"
fi

#############
# Terraform #
#############

alias tf="terragrunt"
alias ta="terragrunt apply"
alias tfa="terragrunt apply -auto-approve --terragrunt-ignore-external-dependencies --terragrunt-non-interactive"
alias tfaa="terragrunt apply-all --terragrunt-ignore-external-dependencies --terragrunt-non-interactive"
alias tfpa="terragrunt plan-all -out plan --terragrunt-non-interactive"
alias tfd="terragrunt destroy"
alias plan="terragrunt plan -out plan"
alias apply="terragrunt apply plan"
alias cache-clear='find $MAIN_DIR/infra -type d -name \".terragrunt-cache\" -prune -exec rm -rf {} \;'

################
# Run anywhere #
################

alias gm="main && yarn script goodmorning && cd -"
alias gms="main && yarn script goodmorning --say && cd -"
alias start="main && yarn node local_dev/start.js"
unalias snap &> /dev/null && echo "removing alias: snap"
# shellcheck disable=SC2164,SC2068
snap() { main && yarn jest -u $@ && cd -; }
alias ct="clear && printf '\e[3J'"

##########
# Github #
##########

# Aliases for github
unalias g 2>/dev/null && echo "removing alias: g"
g() { git "$1"; }
alias p="push"
am() { add -A && git commit -S --m "$1"; }
amn() { git add -A && git commit -S --m "$1 [skip ci]"; }
alias grc="git rebase --continue"
alias gaa="git add -A && git commit --amend --no-edit" # or using signed commits -- alias aa="add -A && git commit -S --amend --no-edit"
alias gpohf="git push origin HEAD --force-with-lease"
alias gap="gaa && gpohf"
alias gempty="git commit --allow-empty -m \"empty commit to re-run all CI jobs\" && git push"

# Rebase your branch to another branch
gfr() {
  if [ $# -eq 0 ]
  then
    echo "Must provide the name of the branch to rebase i.e. 'gfr dev'"
  else
        if git branch | grep -E -q "^[[:space:]]+$1$"
    then
      git fetch && git rebase -i "origin/$1"
    else
      echo "Branch does not exist or you are currently on that branch: $1"
    fi
  fi
}

# Merge a branch into your branch
gfm() {
  current=$(pwd)
  current_folder="$(basename "$current")"
  DEFAULT_BASE="main" && [[ "$current_folder" == "main" ]] && DEFAULT_BASE="dev"

  BASE=${1:-$DEFAULT_BASE}
  if git branch | grep -E -q "^[[:space:]]+$BASE$"
  then
    git checkout "$BASE" && (git pull || git pull) && git checkout - && git merge "$BASE" -m "merges $BASE"
  else
    echo "Branch does not exist or you are currently on that branch: $BASE"
  fi
}

# Add all files with a commit message and push to origin
gamp() {
  if [ $# -eq 0 ]
  then
    echo "No commit message supplied"
  else
        git add -A && git commit --m "$1" && git push
  fi
}

# Create a new branch off of your current branch and push to origin
nrb() {
  if [ $# -eq 0 ]
  then
    echo "Must provide the name of the branch i.e. 'my-new-feature'"
  else
    git checkout -b "${GITHUB_USER:l}/$1"
    git push -u origin "${GITHUB_USER:l}/$1"
  fi
}

# Delete the current branch you are on after it has been merged, and pull the latest base branch
dlb() {
  current=$(pwd)
  current_folder="$(basename "$current")"
  DEFAULT_BASE="main" && [[ "$current_folder" == "main" ]] && DEFAULT_BASE="dev"

  BASE=${1:-$DEFAULT_BASE}
  if git branch | grep -E -q "^[[:space:]]+$BASE$"
  then
    # shellcheck disable=SC2063
    CURRENT="$(git branch | grep \* | cut -d ' ' -f2)"
    git checkout "$BASE"
    git pull
    git branch -D "$CURRENT"
  else
    echo "Branch does not exist or you are currently on that branch: $BASE"
  fi
}

# git commit with a message and immediately publish without a dist-tag
gampub() {
  if [ $# -eq 0 ]
  then
    echo "No commit message supplied"
  else
        npm test && git add -A && git commit --m "$1" && git push && npm publish
  fi
}


# "git pick set" -- set the branch that you want to start cherry picking from
gps() {
  if [ $# -eq 0 ]
  then
    CHERRY_PICK_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    export CHERRY_PICK_BRANCH
  else
        export CHERRY_PICK_BRANCH="$1"
  fi
  echo "CHERRY_PICK_BRANCH set=$CHERRY_PICK_BRANCH"
}

unalias gp 2>/dev/null && echo "removing alias: gp"
# "git pick" - pick off file changes from another branch
gp() {
  if [ -z "$CHERRY_PICK_BRANCH" ]
  then
    echo "Missing env CHERRY_PICK_BRANCH, set with command 'gps myusername/mybranch'"
  else
    if [ $# -eq 0 ]
    then
      echo "Must provide the name of the file to pick, i.e. 'gp .editorconfig'"
    else
      git checkout "$CHERRY_PICK_BRANCH" "$1"
    fi
  fi
}

# Start a new release off the latest dev branch
release_sombra() {
  git fetch && git checkout dev && git pull
  git tag "internal-sombra-$(git rev-parse HEAD)"
  git push origin "internal-sombra-$(git rev-parse HEAD)"
}

# Start a new release off the latest dev branch to expose to customer
release_sombra_external() {
  git fetch && git checkout dev && git pull
  git tag "external-sombra-$(git rev-parse HEAD)"
  git push origin "external-sombra-$(git rev-parse HEAD)"
}

#################
# Github Search #
#################

# Search global
gha() {
        open "https://github.com/search?q=org%3Atranscend-io+archived%3Afalse+$1&archive=false"
}

# Search code
ghc() {
        open "https://github.com/search?q=org%3Atranscend-io+archived%3Afalse+$1&type=code&archive=false"
}

# Search issues
ghi() {
        open "https://github.com/search?q=org%3Atranscend-io+archived%3Afalse+$1&type=issues&archive=false"
}

##############
# Typescript #
##############

# Watch files and re-compile on change
alias tw="yarn tsc --watch"
alias bw="yarn tsc --build --watch"
alias bwc="yarn clean && bw"

########
# yarn #
########

alias cdi="main && yarn upgrade-interactive && yarn && yarn sdks"

################
# Updating zsh #
################

alias zp="code ~/.zshrc"
alias szp="source ~/.zshrc"

###########
# Cypress #
###########

alias cbd='yarn && yarn workspace @main/main cypress:bd'
alias cdev="yarn workspace @main/main cypress open --env configFile=dev"

################
# DB Tunneling #
################

# Backend DB
alias tunnel:dev="main && LOCAL_PORT=55432 AWS_PROFILE=transcend-sandbox yarn script bastion_tunnel &"
alias tunnel:staging="main && LOCAL_PORT=35432 AWS_PROFILE=transcend-staging yarn script bastion_tunnel &"
alias tunnel:prod="main && LOCAL_PORT=45432 AWS_PROFILE=transcend-prod yarn script bastion_tunnel &"

# BI Redshift
alias tunnel:bi="main && LOCAL_PORT=45433 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=bi-redshift.private:5439 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion"
alias tunnel:bi:dev="main && LOCAL_PORT=55433 AWS_PROFILE=transcend-sandbox REMOTE_DB_URI=bi-redshift.private:5439 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion"

# BI - Airbyte
alias tunnel:bi:airbyte="main && LOCAL_PORT=45434 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=airbyte.clbnbcigfchd.us-east-1.rds.amazonaws.com:5432 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion"
alias tunnel:bi:airbyte:dev="main && LOCAL_PORT=55434 AWS_PROFILE=transcend-sandbox REMOTE_DB_URI=airbyte.cjja3ov1uth8.eu-west-1.rds.amazonaws.com:5432 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion"

# BI - Lightdash
alias tunnel:bi:lightdash="main && LOCAL_PORT=45435 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=lightdash.clbnbcigfchd.us-east-1.rds.amazonaws.com:5432 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion"

# BI - Other services
alias tunnel:transcend-bot="main && LOCAL_PORT=45439 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=transcend-bot.clbnbcigfchd.us-east-1.rds.amazonaws.com:5432 yarn script bastion_tunnel"
alias tunnel:bi:airplane="LOCAL_PORT=45530 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=airplanemcairplaneface.clbnbcigfchd.us-east-1.rds.amazonaws.com:5432 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion"

# Sandbox Redshift (not BI)
alias tunnel:dev:redshift="main && LOCAL_PORT=56432 REMOTE_DB_URI=sandbox-redshift-cluster.ciqrjisjzs3u.eu-west-1.redshift.amazonaws.com:5439 yarn script bastion_tunnel &"

#########################
# Business Intelligence #
#########################

alias cdbi='cd $MAIN_DIR/business-intelligence'
alias cdbip='cd $MAIN_DIR/business-intelligence/python'
alias cdbit='cd $MAIN_DIR/business-intelligence/transform'

# Set up the virtual environment for BI
function bi_venv() {
  cd "$MAIN_DIR" || { echo "Failed to cd to 'main' directory. Is \$MAIN_DIR defined?"; return; }
  python3 -m venv .venv
  # shellcheck source=/dev/null
  source .venv/bin/activate
  python3 -m pip install -r "$MAIN_DIR/business-intelligence/python/requirements.txt"

  # Set up dbt
  dbt deps

  # cd into the BI directory
  cdbi
}

# Set up the tunnel to Redshift (you may re-run this now and then)
function bi() {
  vaultify transcend-prod

  # Place REDSHIFT into the environment variables for dbt
  REDSHIFT_PASSWORD_TRANSCEND_ADMIN=$(vault kv get -field=password_transcend_admin kv/redshift)
  export REDSHIFT_PASSWORD_TRANSCEND_ADMIN="$REDSHIFT_PASSWORD_TRANSCEND_ADMIN"

  # Tunnel to BI Redshift
  cd "$MAIN_DIR" || { echo "Failed to cd to 'main' directory. Is \$MAIN_DIR defined?"; return; }
  LOCAL_PORT=45433 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=bi-redshift.private:5439 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion

  # cd into the BI directory
  cdbi
}

# Run this when you want to start working on BI
alias gmbi="yarn goodmorning && bi_venv && bi"

# Qdrant
function tunnel_qdrant() {
  # shellcheck disable=SC2155
  readonly ARNS=$(aws ecs list-tasks --cluster qdrant-db --service-name qdrant-db --profile transcend-prod --region us-east-1 --output text --query 'taskArns')
  # shellcheck disable=SC2155
  readonly TASK_ARN=$(echo "$ARNS" | command tr ' ' '\n' | shuf -n 1)
  # shellcheck disable=SC2155
  readonly TASK_DETAILS=$(aws ecs describe-tasks --cluster qdrant-db --tasks "$TASK_ARN" --query 'tasks[0].attachments[0].details' --profile transcend-prod --region us-east-1)
  # shellcheck disable=SC2155
  readonly PRIVATE_IP=$(echo "$TASK_DETAILS" | jq -r '.[] | select(.name=="privateIPv4Address") | .value')
  main && LOCAL_PORT=45438 AWS_PROFILE=transcend-prod AWS_REGION=us-east-1 REMOTE_DB_URI=${PRIVATE_IP}:6333 yarn script bastion_tunnel --name=bi-redshift-ssm-bastion
}

############
# Postgres #
############
alias pg:start="pg_ctl -D /usr/local/var/postgres start"
alias pg:stop="pg_ctl -D /usr/local/var/postgres stop"

pg:ahhhhhh() {
  if [[ -z "$REMOTE_CONTAINERS" ]]; then
    pg:stop || echo "already stopped"
    rm -rf /usr/local/var/postgres
    main
    WIPE=false ./scripts/fresh_local_db.sh
    WIPE=false ./scripts/fresh_local_db.sh test
    WIPE=false ./scripts/fresh_local_db.sh transcend-bot
    WIPE=false ./scripts/fresh_local_db.sh odbc
  else
    ./scripts/fresh_local_db.sh
  fi
  echo "AHHHHHHH"
}

###########
# VS Code #
###########

PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

##########
# Pulumi #
##########

PATH="$PATH:/root/.pulumi/bin"
export PATH

########
# ODBC #
########

export AMAZONREDSHIFTODBC=/etc/amazon.redshiftodbc.ini

#######
# dbt #
#######
export DBT_PROFILES_DIR="$MAIN_DIR/business-intelligence/transform"
export DBT_PROJECT_DIR="$MAIN_DIR/business-intelligence/transform"
export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history

