USERNAME="rasal"
# export password first
if [ -z "${PASSWORD}" ]; then
  echo "password is not set or empty"
  exit
fi
NOPASSWD_SUDO=true  # Set to "false" to require sudo password

# Check if run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root"
  exit 1
fi

# Create user
if id "$USERNAME" &>/dev/null; then
  echo "✅ User '$USERNAME' already exists"
else
  echo "➕ Creating user: $USERNAME"
  useradd -m -s /bin/bash "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd
fi

# Add to sudo group (Debian/Ubuntu)
usermod -aG sudo "$USERNAME"
echo "✅ Added '$USERNAME' to sudo group"

# Optionally add passwordless sudo
if [ "$NOPASSWD_SUDO" = true ]; then
  SUDOERS_FILE="/etc/sudoers.d/$USERNAME"
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
  chmod 440 "$SUDOERS_FILE"
  echo "⚠️ Passwordless sudo enabled for '$USERNAME'"
else
  echo "🔐 Sudo will require a password"
fi

echo "🎉 User '$USERNAME' is ready"
