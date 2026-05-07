// Page load tracking
const pageLoadStart = performance.now();

// Get API base URL (adapt based on deployment)
function getApiUrl() {
    // In production, this would be the Ingress URL or API service
    const baseUrl = window.location.origin;
    // If running locally with port-forward: http://localhost:5000
    // If running in Kubernetes with Ingress: http://myapp.local/api
    return baseUrl.includes('localhost') ? 'http://localhost:5000' : baseUrl + '/api';
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    updateStatus();
    updateTime();
    setInterval(updateTime, 1000);

    const pageLoadEnd = performance.now();
    document.getElementById('load-time').textContent = Math.round(pageLoadEnd - pageLoadStart) + 'ms';
});

// Fetch and display API status
async function updateStatus() {
    try {
        const response = await fetch(getApiUrl() + '/status');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const data = await response.json();
        const statusEl = document.getElementById('status');
        statusEl.innerHTML = `
            <p><strong>Status:</strong> <span style="color: green;">✓ ${data.status}</span></p>
            <p><strong>Environment:</strong> ${data.environment}</p>
            <p><strong>API Response Time:</strong> ${new Date().toISOString()}</p>
        `;
    } catch (error) {
        document.getElementById('status').innerHTML = `
            <p><strong>Status:</strong> <span style="color: red;">✗ Error</span></p>
            <p>Error: ${error.message}</p>
        `;
    }
}

// Fetch data from API
async function fetchData() {
    try {
        const button = event.target;
        button.disabled = true;
        button.textContent = 'Loading...';

        const response = await fetch(getApiUrl() + '/data');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const data = await response.json();
        const dataEl = document.getElementById('data');

        let html = '<table style="width:100%; border-collapse: collapse;">';
        html += '<tr style="background:#f0f0f0;"><th style="padding:8px; text-align:left;">ID</th><th style="padding:8px; text-align:left;">Name</th><th style="padding:8px; text-align:left;">Value</th></tr>';

        data.data.forEach(item => {
            html += `<tr style="border-bottom:1px solid #ddd;"><td style="padding:8px;">${item.id}</td><td style="padding:8px;">${item.name}</td><td style="padding:8px;">${item.value}</td></tr>`;
        });

        html += '</table>';
        html += `<p style="margin-top: 10px; color: #666; font-size: 0.9em;">Timestamp: ${data.timestamp}</p>`;

        dataEl.innerHTML = html;
        button.disabled = false;
        button.textContent = 'Load Data from API';
    } catch (error) {
        document.getElementById('data').innerHTML = `<p style="color: red;">Error fetching data: ${error.message}</p>`;
        event.target.disabled = false;
        event.target.textContent = 'Load Data from API';
    }
}

// Fetch metrics
async function fetchMetrics() {
    try {
        const response = await fetch(getApiUrl() + '/metrics');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);

        const data = await response.json();
        const metricsEl = document.getElementById('metrics');

        const metricsText = `
Requests: ${data.requests}
Errors: ${data.errors}
Uptime: ${data.uptime_seconds}s

Last Updated: ${new Date().toISOString()}
        `.trim();

        metricsEl.textContent = metricsText;
    } catch (error) {
        document.getElementById('metrics').textContent = `Error fetching metrics: ${error.message}`;
    }
}

// Update time display
function updateTime() {
    const now = new Date();
    document.getElementById('time').textContent = now.toLocaleTimeString();
}

// Get hostname from API
fetch(getApiUrl() + '/info')
    .then(r => r.json())
    .then(data => {
        document.getElementById('hostname').textContent = data.hostname || 'Unknown';
    })
    .catch(() => {
        document.getElementById('hostname').textContent = 'Unable to fetch';
    });
