#!/bin/bash
# =======================================================
# LINUX → POSTGRE MONITORING (FINAL STABLE VERSION)
# =======================================================

### --- Postgre Ayarları ---
PGHOST="127.0.0.1"
PGPORT="5432"
PGDATABASE="monitoring"
PGUSER="monitor_user"
PGPASSWORD="1234"
export PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD

### --- Genel Ayarlar ---
INTERVAL_SECONDS=30
HOSTNAME=$(hostname)
START_TIME=$(date +%s)
END_TIME=$((START_TIME + 86400))
NOW_ONCE=$(date "+%Y-%m-%d %H:%M:%S")

# =======================================================
# BÖLÜM A: SABİT VERİLER (GÜNDE 1 KEZ)
# =======================================================

# 1) OS LIFECYCLE
OS_NAME=$(lsb_release -is 2>/dev/null); OS_VERSION=$(lsb_release -rs 2>/dev/null); KERNEL_VERSION=$(uname -r)
psql -c "INSERT INTO os_lifecycle_status (hostname, sample_time, os_name, os_version, kernel_version, lifecycle_status, os_status, description) VALUES ('$HOSTNAME', '$NOW_ONCE', '${OS_NAME:-Linux}', '${OS_VERSION:-Unknown}', '$KERNEL_VERSION', 'OK', '0', 'Standard');"

# 2) USER INVENTORY (CREATED_AT: Müşteri Talebi)
getent passwd | awk -F: '$3 >= 1000 && $7 ~ /(bash|sh)$/ {print $1}' | while read -r USERNAME; do
    psql -c "INSERT INTO user_inventory (hostname, username, is_sudo, last_login, created_at, collected_at) VALUES ('$HOSTNAME', '$USERNAME', 0, 'Never', 'System', '$NOW_ONCE');"
done

# 3) NTP & DISK HISTORY (Gelecek Tahminleme)
NTP_RAW=$(ntpq -pn 2>/dev/null); [[ "$NTP_RAW" == ""* ]] && SYNC_STATUS="active" || SYNC_STATUS="not aplicated"
psql -c "INSERT INTO ntp_status (hostname, sample_time, ntp_status) VALUES ('$HOSTNAME', '$NOW_ONCE', '$SYNC_STATUS');"

DISK_INFO=$(df -BG / | tail -1)
TOTAL_GB=$(echo $DISK_INFO | awk '{print $2}' | tr -d 'G')
USED_GB=$(echo $DISK_INFO | awk '{print $3}' | tr -d 'G')
psql -c "INSERT INTO disk_history (hostname, mountpoint, total_size_gb, used_size_gb, record_date) VALUES ('$HOSTNAME', '/', ${TOTAL_GB:-0}, ${USED_GB:-0}, CURRENT_DATE) ON CONFLICT DO NOTHING;"

# =======================================================
# BÖLÜM B: ANA DÖNGÜ (ANLIK VERİLER)
# =======================================================
while [ $(date +%s) -lt $END_TIME ]; do
    NOW=$(date "+%Y-%m-%d %H:%M:%S")

    # 1) METRICS (CPU, RAM, DISK)
DISK_QUEUE=$(iostat -dx 1 2 | awk '$1 ~ /^(sd|vd|nvme)/ {print $9; exit}')
    psql -c "INSERT INTO server_metrics (hostname, sample_time, cpu_usage, ram_usage, disk_usage, disk_queue) VALUES ('$HOSTNAME', '$NOW', $(mpstat 1 1 | awk '/Average:/ {print 100 - $NF}'), $(free | awk '/Mem:/ {print $3/$2 * 100.0}'), $(df / | awk 'NR==2 {print $5}' | tr -d '%'), ${DISK_QUEUE:-0});"

    # 2) NETSTAT (HATA GİDERİLDİ: PORT VE STATE ASLA BOŞ GİTMEYECEK)
    sudo netstat -ntlp 2>/dev/null | awk 'NR>2 && $6=="LISTEN" {
        addr=$4; pidprog=$7;
        n=split(addr, a, ":"); port_val=a[n];
        split(pidprog, p, "/");
        if (port_val == "") port_val="0";
        print $1 "|" addr "|" port_val "|" $6 "|" p[1] "|" p[2]
    }' | while IFS="|" read -r PROTO ADDR PORT STATE PID PNAME; do
        SAFE_PNAME=$(echo "$PNAME" | sed "s/'/''/g")
        psql -c "INSERT INTO open_ports_netstat (hostname, collected_at, protocol, local_address, port, state, pid, process_name) VALUES ('$HOSTNAME', '$NOW', '$PROTO', '$ADDR', ${PORT:-0}, '${STATE:-LISTEN}', ${PID:-0}, '${SAFE_PNAME:-System}');"
    done

    # 3) TOP EVENTS (HATA GİDERİLDİ: TIRNAKLAR TEMİZLENDİ)
    journalctl -p err -n 5 -o short | while read -r line; do
        SAFE_EVENT=$(echo "$line" | sed "s/'/''/g")
        psql -c "INSERT INTO top_events (hostname, collected_at, event_message) VALUES ('$HOSTNAME', '$NOW', '$SAFE_EVENT');"
    done

    # 4) SECURITY & LOGS
    psql -c "INSERT INTO system_security_status (hostname, sample_time, ufw_status, ntp_status) VALUES ('$HOSTNAME', '$NOW', 'disactive', '$SYNC_STATUS');"
    
    # LOG SUMMARY
    ERR_COUNT=$(journalctl --since "10 minutes ago" -p err -q | wc -l)
    psql -c "INSERT INTO log_summary (hostname, checked_at, error_count, crit_count, warn_count) VALUES ('$HOSTNAME', '$NOW', $ERR_COUNT, 0, 0);"

    sleep "$INTERVAL_SECONDS"
done