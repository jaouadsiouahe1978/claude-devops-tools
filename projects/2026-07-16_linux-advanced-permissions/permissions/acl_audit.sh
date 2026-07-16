#!/bin/bash

# Audit des ACLs appliquées

echo "=========================================="
echo "ACL Audit Report"
echo "=========================================="
echo ""

DIRS=(
    "/opt/test_permissions/shared"
    "/opt/test_permissions/webapp"
    "/opt/test_permissions/devops"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        continue
    fi

    echo "Directory: $dir"
    echo "---"
    echo "Default ACLs (inherited by new files):"
    if getfacl "$dir" 2>/dev/null | grep -q "^default:"; then
        getfacl "$dir" 2>/dev/null | grep "^default:" | sed 's/^/  /'
    else
        echo "  (none)"
    fi

    echo ""
    echo "Files and their ACLs:"
    find "$dir" -type f -maxdepth 1 | while read -r file; do
        filename=$(basename "$file")
        echo "  $filename:"
        getfacl "$file" 2>/dev/null | grep -E "^(user|group):" | sed 's/^/    /'
    done
    echo ""
done

echo "=========================================="
echo "ACL Permissions Reference"
echo "=========================================="
echo ""
echo "Permission symbols:"
echo "  r = read (4)"
echo "  w = write (2)"
echo "  x = execute (1)"
echo ""
echo "ACL entry format:"
echo "  [d:]type:name:perms"
echo "  d: = default (inherited)"
echo "  type: u (user), g (group), o (other), m (mask)"
echo "  name: username or groupname"
echo "  perms: rwx permissions"
echo ""
echo "Examples:"
echo "  u:alice:rw     = user alice has read+write"
echo "  g:devops:rx    = group devops has read+execute"
echo "  d:u:bob:r      = default: new files readable by bob"
echo ""
echo "✓ Audit complete"
