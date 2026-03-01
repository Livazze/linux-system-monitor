-- 1. OS Lifecycle Status (Bölüm 10)
CREATE TABLE IF NOT EXISTS os_lifecycle_status (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    sample_time TIMESTAMP,
    os_name TEXT,
    os_version TEXT,
    kernel_version TEXT,
    lifecycle_status TEXT,
    os_status TEXT,
    description TEXT
);

-- 2. User Inventory (Bölüm 11)
CREATE TABLE IF NOT EXISTS user_inventory (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    username TEXT,
    is_sudo INTEGER,
    last_login TEXT,
    created_at TEXT,
    collected_at TIMESTAMP
);

-- 3. NTP Status
CREATE TABLE IF NOT EXISTS ntp_status (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    sample_time TIMESTAMP,
    source TEXT,
    ntp_stratum INTEGER,
    ntp_status TEXT,
    raw_output TEXT
);

-- 4. Server Metrics (CPU, RAM, Disk, Queue)
CREATE TABLE IF NOT EXISTS server_metrics (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    sample_time TIMESTAMP,
    cpu_usage FLOAT,
    ram_usage FLOAT,
    disk_usage INTEGER,
    disk_queue FLOAT
);

-- 5. Service Status
CREATE TABLE IF NOT EXISTS service_status (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    service_name TEXT,
    is_active BOOLEAN,
    sample_time TIMESTAMP
);

-- 6. Log Summary
CREATE TABLE IF NOT EXISTS log_summary (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    checked_at TIMESTAMP,
    error_count INTEGER,
    crit_count INTEGER,
    warn_count INTEGER
);

-- 7. Top Events (Hata Kayýtlarý)
CREATE TABLE IF NOT EXISTS top_events (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    collected_at TIMESTAMP,
    event_message TEXT
);

-- 8. Top Processes
CREATE TABLE IF NOT EXISTS top_processes (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    collected_at TIMESTAMP,
    process_name TEXT,
    cpu_pct FLOAT,
    ram_pct FLOAT
);

-- 9. Filesystem Status
CREATE TABLE IF NOT EXISTS filesystem_status (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    sample_time TIMESTAMP,
    filesystem TEXT,
    mountpoint TEXT,
    size TEXT,
    used_percent INTEGER
);

-- 10. System Security Status (UFW, NTP)
CREATE TABLE IF NOT EXISTS system_security_status (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    sample_time TIMESTAMP,
    ufw_status TEXT,
    apt_updates INTEGER DEFAULT 0,
    ntp_status TEXT,
    ntp_stratum INTEGER
);

-- 11. Open Ports (Basit Liste)
CREATE TABLE IF NOT EXISTS open_ports (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    collected_at TIMESTAMP,
    local_address TEXT,
    protocol TEXT
);

-- 12. Open Ports Netstat (Detaylý - PID/PNAME)
-- NOT: Scriptte yaþadýðýn 'null' hatalarýný önlemek için sütunlarý esnek tuttum.
CREATE TABLE IF NOT EXISTS open_ports_netstat (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    collected_at TIMESTAMP,
    protocol TEXT,
    local_address TEXT,
    port INTEGER,
    state TEXT,
    pid INTEGER NULL,
    process_name TEXT NULL
);

-- 13. Disk History (Kapasite Tahminleme Ýçin - Yeni Ýstek)
CREATE TABLE IF NOT EXISTS disk_history (
    id SERIAL PRIMARY KEY,
    hostname TEXT,
    mountpoint TEXT,
    total_size_gb FLOAT,
    used_size_gb FLOAT,
    record_date DATE DEFAULT CURRENT_DATE,
    UNIQUE(hostname, mountpoint, record_date)
);