#
# Vagrant
#
# Vagrant is a tool for building and managing virtual machine environments in a single workflow.
# Link: https://www.vagrantup.com

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_VAGRANT_SHOW="${SPACESHIP_VAGRANT_SHOW=true}"
SPACESHIP_VAGRANT_PREFIX="${SPACESHIP_VAGRANT_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_VAGRANT_SUFFIX="${SPACESHIP_VAGRANT_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_VAGRANT_SYMBOL="${SPACESHIP_VAGRANT_SYMBOL="📦 "}"
SPACESHIP_VAGRANT_COLOR="${SPACESHIP_VAGRANT_COLOR="39"}"

SPACESHIP_VAGRANT_DISPLAY_SHORT="${SPACESHIP_VAGRANT_DISPLAY_SHORT=false}"
SPACESHIP_VAGRANT_RUNNING="${SPACESHIP_VAGRANT_RUNNING="%{$fg_no_bold[green]%}●"}"
SPACESHIP_VAGRANT_POWEROFF="${SPACESHIP_VAGRANT_POWEROFF="%{$fg_no_bold[red]%}●"}"
SPACESHIP_VAGRANT_SUSPENDED="${SPACESHIP_VAGRANT_SUSPENDED="%{$fg_no_bold[yellow]%}●"}"
SPACESHIP_VAGRANT_NOT_CREATED="${SPACESHIP_VAGRANT_NOT_CREATED="%{$fg_no_bold[white]%}○"}"
SPACESHIP_VAGRANT_ABORTED="${SPACESHIP_VAGRANT_ABORTED="%{$fg_no_bold[red]%}○"}"
# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show vagrant status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_vagrant() {
  # If SPACESHIP_VAGRANT_SHOW is false, don't show vagrant section
  [[ $SPACESHIP_VAGRANT_SHOW == false ]] && return

  # Check if vagrant command is available for execution
  spaceship::exists vagrant || return

  # Show vagrant section only when there are vagrant-specific files in current
  # working direcotory.
  # Here glob qualifiers are used to check if files with specific extention are
  # present in directory. Read more about them here:
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html
  [[ -f Vagrantfile || -n *.vagrant ]] || return

  # Use quotes around unassigned local variables to prevent
  # getting replaced by global aliases
  # http://zsh.sourceforge.net/Doc/Release/Shell-Grammar.html#Aliasing
  local 'vagrant_status'

  vagrant_prompt_info() {
  test -d .vagrant && test -f Vagrantfile
  if [[ "$?" == "0" ]]; then
    local 'statuses'
    statuses=$(vagrant status 2> /dev/null | grep -P "\w+\s+[\w\s]+\s\(\w+\)")
    statuses=("${(f)statuses}")
    for vm_details in $statuses; do
      vm_state=$(echo $vm_details | grep -o -E "saved|poweroff|not created|running|aborted")
      if [[ "$vm_state" == "running" ]]; then
        printf '%s' $SPACESHIP_VAGRANT_RUNNING
      elif [[ "$vm_state" == "saved" ]]; then
        printf '%s' $SPACESHIP_VAGRANT_SUSPENDED
      elif [[ "$vm_state" == "not created" ]]; then
        printf '%s' $SPACESHIP_VAGRANT_NOT_CREATED
      elif [[ "$vm_state" == "poweroff" ]]; then
        printf '%s' $SPACESHIP_VAGRANT_POWEROFF
      elif [[ "$vm_state" == "aborted" ]]; then
        printf '%s' $SPACESHIP_VAGRANT_ABORTED
      fi
    done
  fi
}

  vagrant_status=$(vagrant_prompt_info)

  [[ -n ${vagrant_status} ]] || return
  # Display vagrant section
  spaceship::section \
    "$SPACESHIP_VAGRANT_COLOR" \
    "$SPACESHIP_VAGRANT_PREFIX" \
    "$SPACESHIP_VAGRANT_SYMBOL$vagrant_status" \
    "$SPACESHIP_VAGRANT_SUFFIX"
}
