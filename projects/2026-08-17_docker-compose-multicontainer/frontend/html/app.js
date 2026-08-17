/**
 * Frontend Application JavaScript
 * Handles API interactions and UI updates
 */

const API_BASE_URL = '/api';
const REFRESH_INTERVAL = 5000; // 5 seconds

// Initialize app on page load
document.addEventListener('DOMContentLoaded', () => {
    console.log('App initialized');
    checkServiceStatus();
    loadItems();
    loadStats();

    // Setup event listeners
    document.getElementById('create-form').addEventListener('submit', createItem);

    // Auto-refresh data
    setInterval(() => {
        checkServiceStatus();
        loadStats();
    }, REFRESH_INTERVAL);
});

/**
 * Check service status (Backend API & Database)
 */
async function checkServiceStatus() {
    try {
        // Check Backend Health
        const healthResponse = await fetch(`${API_BASE_URL}/health`);
        const backendStatus = document.getElementById('backend-status');
        if (healthResponse.ok) {
            backendStatus.textContent = '✅ Online';
            backendStatus.className = 'status-badge online';
        } else {
            backendStatus.textContent = '❌ Offline';
            backendStatus.className = 'status-badge offline';
        }

        // Check Database Readiness
        const readyResponse = await fetch(`${API_BASE_URL}/ready`);
        const dbStatus = document.getElementById('db-status');
        if (readyResponse.ok) {
            dbStatus.textContent = '✅ Connected';
            dbStatus.className = 'status-badge online';
        } else {
            dbStatus.textContent = '❌ Disconnected';
            dbStatus.className = 'status-badge offline';
        }
    } catch (error) {
        console.error('Status check error:', error);
        document.getElementById('backend-status').textContent = '❌ Error';
        document.getElementById('backend-status').className = 'status-badge offline';
        document.getElementById('db-status').textContent = '❌ Error';
        document.getElementById('db-status').className = 'status-badge offline';
    }
}

/**
 * Load all items from API
 */
async function loadItems() {
    try {
        const response = await fetch(`${API_BASE_URL}/items`);
        if (!response.ok) throw new Error('Failed to load items');

        const data = await response.json();
        const items = data.data || [];

        const container = document.getElementById('items-container');
        if (items.length === 0) {
            container.innerHTML = '<p class="loading">No items yet. Create one to get started!</p>';
            return;
        }

        container.innerHTML = items.map(item => createItemElement(item)).join('');
    } catch (error) {
        console.error('Error loading items:', error);
        document.getElementById('items-container').innerHTML =
            `<p class="loading">Error loading items: ${error.message}</p>`;
    }
}

/**
 * Create item HTML element
 */
function createItemElement(item) {
    const date = new Date(item.created_at).toLocaleString();
    return `
        <div class="item-card">
            <div class="item-header">
                <h3 class="item-title">${escapeHtml(item.title)}</h3>
                <span class="item-status ${item.status}">${capitalize(item.status)}</span>
            </div>
            ${item.description ? `<p class="item-description">${escapeHtml(item.description)}</p>` : ''}
            <div class="item-meta">
                <span>ID: #${item.id}</span>
                <span>Created: ${date}</span>
            </div>
            <div class="item-actions">
                <button class="btn btn-success" onclick="updateItemStatus(${item.id}, '${getNextStatus(item.status)}')">
                    Next Status
                </button>
                <button class="btn btn-danger" onclick="deleteItem(${item.id})">
                    Delete
                </button>
            </div>
        </div>
    `;
}

/**
 * Get next status in workflow
 */
function getNextStatus(currentStatus) {
    const workflow = {
        'pending': 'in-progress',
        'in-progress': 'completed',
        'completed': 'pending'
    };
    return workflow[currentStatus] || 'pending';
}

/**
 * Create new item
 */
async function createItem(e) {
    e.preventDefault();

    const title = document.getElementById('title').value.trim();
    const description = document.getElementById('description').value.trim();
    const status = document.getElementById('status').value;

    if (!title) {
        alert('Please enter a title');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/items`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title, description, status })
        });

        if (!response.ok) throw new Error('Failed to create item');

        // Reset form
        document.getElementById('create-form').reset();

        // Reload items
        loadItems();
        loadStats();
        alert('Item created successfully!');
    } catch (error) {
        console.error('Error creating item:', error);
        alert(`Error: ${error.message}`);
    }
}

/**
 * Update item status
 */
async function updateItemStatus(id, newStatus) {
    try {
        const response = await fetch(`${API_BASE_URL}/items/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: newStatus })
        });

        if (!response.ok) throw new Error('Failed to update item');

        loadItems();
        loadStats();
    } catch (error) {
        console.error('Error updating item:', error);
        alert(`Error: ${error.message}`);
    }
}

/**
 * Delete item
 */
async function deleteItem(id) {
    if (!confirm('Are you sure you want to delete this item?')) {
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/items/${id}`, {
            method: 'DELETE'
        });

        if (!response.ok) throw new Error('Failed to delete item');

        loadItems();
        loadStats();
    } catch (error) {
        console.error('Error deleting item:', error);
        alert(`Error: ${error.message}`);
    }
}

/**
 * Load statistics
 */
async function loadStats() {
    try {
        const response = await fetch(`${API_BASE_URL}/stats`);
        if (!response.ok) throw new Error('Failed to load stats');

        const data = await response.json();
        const stats = data.data;

        // Update stat boxes
        const statBoxes = document.querySelectorAll('.stat-box');
        const values = [
            stats.total_items || 0,
            stats.by_status?.['pending'] || 0,
            stats.by_status?.['in-progress'] || 0,
            stats.by_status?.['completed'] || 0
        ];

        statBoxes.forEach((box, index) => {
            if (box.querySelector('.stat-value')) {
                box.querySelector('.stat-value').textContent = values[index];
            }
        });
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

/**
 * Utility: Escape HTML special characters
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Utility: Capitalize string
 */
function capitalize(str) {
    return str.split('-').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
}

console.log('App scripts loaded');
