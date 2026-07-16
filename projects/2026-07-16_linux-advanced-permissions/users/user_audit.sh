#!/bin/bash

# Audit des comptes utilisateurs créés

echo "=========================================="
echo "User & Group Audit Report"
echo "=========================================="
echo ""

# Utilisateurs locaux
echo "Local Users (with /home directory):"
echo "---"
getent passwd | while IFS=: read -r name _ uid gid _ home shell; do
    if [ "$uid" -ge 1000 ] 2>/dev/null || [ "$name" = "alice" ] || [ "$name" = "bob" ] || [ "$name" = "charlie" ] || [ "$name" = "diana" ] || [ "$name" = "eve" ]; then
        printf "%-12s UID:%-5d GID:%-5d Home:%-20s Shell:%s\n" "$name" "$uid" "$gid" "$home" "$shell"
    fi
done

echo ""
echo "Local Groups:"
echo "---"
getent group | while IFS=: read -r name _ gid members; do
    if [ "$gid" -ge 1000 ] 2>/dev/null || [ "$name" = "webapp" ] || [ "$name" = "devops" ] || [ "$name" = "developer" ] || [ "$name" = "shared" ]; then
        printf "%-15s GID:%-5d Members: %s\n" "$name" "$gid" "$members"
    fi
done

echo ""
echo "Password Aging Status:"
echo "---"
for user in alice bob charlie diana eve; do
    if id "$user" &>/dev/null; then
        AGING=$(chage -l "$user" 2>/dev/null | grep -E "Maximum|Minimum|warning")
        echo "$user:"
        echo "$AGING" | sed 's/^/  /'
        echo ""
    fi
done

echo "Home Directories:"
echo "---"
for user in alice bob charlie diana eve; do
    if [ -d "/home/$user" ]; then
        SIZE=$(du -sh "/home/$user" 2>/dev/null | cut -f1)
        PERMS=$(ls -ld "/home/$user" | awk '{print $1}')
        printf "%-12s %s %s\n" "$user" "$PERMS" "$SIZE"
    fi
done

echo ""
echo "✓ Audit complete"
