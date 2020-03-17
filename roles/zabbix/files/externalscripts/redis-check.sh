#!/bin/bash

METRIC="$2"
SERV="$1"
DB="$3"

PORT="6379"

if [[ -z "$1" ]]; then
    echo "Please set server"
    exit 1
fi

CACHETTL="55" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/redis-status-`echo $SERV | md5sum | cut -d" " -f1`.cache"
TIMENOW=`date '+%s'`
EXEC_TIMEOUT="2"

if [ -s "$CACHE" ]; then
    TIMECACHE=`stat -c"%Y" "$CACHE"`
else
    TIMECACHE=0
fi

DELTA_TIME=$((${TIMENOW} - ${TIMECACHE}))


if [ ${DELTA_TIME} -lt ${EXEC_TIMEOUT} ]; then
    sleep $((${EXEC_TIMEOUT} - ${DELTA_TIME}))
elif [ ${DELTA_TIME} -gt ${CACHETTL} ]; then
    echo "" >> "${CACHE}" # !!!
    (echo -en "INFO\r\n"; sleep 1;) | nc -w1 $SERV $PORT > $CACHE || exit 1
#    nc -w1 $SERV $PORT >> $CACHE
    chmod 640 "${CACHE}"
    chown zabbix:zabbix "${CACHE}"
fi

case $METRIC in
    'redis_version')
        cat $CACHE | grep "redis_version:" | cut -d':' -f2;;            
    'redis_git_sha1')
        cat $CACHE | grep "redis_git_sha1:" | cut -d':' -f2;;
    'redis_git_dirty')
        cat $CACHE | grep "redis_git_dirty:" | cut -d':' -f2;;
    'redis_mode')
        cat $CACHE | grep "redis_mode:" | cut -d':' -f2;;
    'arch_bits')
        cat $CACHE | grep "arch_bits:" | cut -d':' -f2;;
    'multiplexing_api')
        cat $CACHE | grep "multiplexing_api:" | cut -d':' -f2;;
    'gcc_version')
        cat $CACHE | grep "gcc_version:" | cut -d':' -f2;;
    'uptime_in_seconds')
        cat $CACHE | grep "uptime_in_seconds:" | cut -d':' -f2;;
    'lru_clock')
        cat $CACHE | grep "lru_clock:" | cut -d':' -f2;;            
    'connected_clients')
        cat $CACHE | grep "connected_clients:" | cut -d':' -f2;;
    'client_longest_output_list')
        cat $CACHE | grep "client_longest_output_list:" | cut -d':' -f2;;
    'client_biggest_input_buf')
        cat $CACHE | grep "client_biggest_input_buf:" | cut -d':' -f2;;
    'used_memory')
        cat $CACHE | grep "used_memory:" | cut -d':' -f2;;
    'used_memory_peak')
        cat $CACHE | grep "used_memory_peak:" | cut -d':' -f2;;        
    'mem_fragmentation_ratio')
        cat $CACHE | grep "mem_fragmentation_ratio:" | cut -d':' -f2;;
    'loading')
        cat $CACHE | grep "loading:" | cut -d':' -f2;;            
    'rdb_changes_since_last_save')
        cat $CACHE | grep "rdb_changes_since_last_save:" | cut -d':' -f2;;
    'rdb_bgsave_in_progress')
        cat $CACHE | grep "rdb_bgsave_in_progress:" | cut -d':' -f2;;
    'aof_rewrite_in_progress')
        cat $CACHE | grep "aof_rewrite_in_progress:" | cut -d':' -f2;;
    'aof_enabled')
        cat $CACHE | grep "aof_enabled:" | cut -d':' -f2;;
    'aof_rewrite_scheduled')
        cat $CACHE | grep "aof_rewrite_scheduled:" | cut -d':' -f2;;
    'total_connections_received')
        cat $CACHE | grep "total_connections_received:" | cut -d':' -f2;;            
    'total_commands_processed')
        cat $CACHE | grep "total_commands_processed:" | cut -d':' -f2;;
    'instantaneous_ops_per_sec')
        cat $CACHE | grep "instantaneous_ops_per_sec:" | cut -d':' -f2;;
    'rejected_connections')
        cat $CACHE | grep "rejected_connections:" | cut -d':' -f2;;
    'expired_keys')
        cat $CACHE | grep "expired_keys:" | cut -d':' -f2;;
    'evicted_keys')
        cat $CACHE | grep "evicted_keys:" | cut -d':' -f2;;
    'keyspace_hits')
        cat $CACHE | grep "keyspace_hits:" | cut -d':' -f2;;        
    'keyspace_misses')
        cat $CACHE | grep "keyspace_misses:" | cut -d':' -f2;;
    'pubsub_channels')
        cat $CACHE | grep "pubsub_channels:" | cut -d':' -f2;;      
    'pubsub_patterns')
        cat $CACHE | grep "pubsub_patterns:" | cut -d':' -f2;;             
    'latest_fork_usec')
        cat $CACHE | grep "latest_fork_usec:" | cut -d':' -f2;; 
    'role')
        cat $CACHE | grep "role:" | cut -d':' -f2;;
    'connected_slaves')
        cat $CACHE | grep "connected_slaves:" | cut -d':' -f2;;          
    'used_cpu_sys')
        cat $CACHE | grep "used_cpu_sys:" | cut -d':' -f2;;  
    'used_cpu_user')
        cat $CACHE | grep "used_cpu_user:" | cut -d':' -f2;;
    'used_cpu_sys_children')
        cat $CACHE | grep "used_cpu_sys_children:" | cut -d':' -f2;;             
    'used_cpu_user_children')
        cat $CACHE | grep "used_cpu_user_children:" | cut -d':' -f2;; 
    'total_net_input_bytes')
        cat $CACHE | grep "total_net_input_bytes:" | cut -d':' -f2;; 
    'total_net_output_bytes')
        cat $CACHE | grep "total_net_output_bytes:" | cut -d':' -f2;; 
    *)   
        echo "Not selected metric"
        exit 0
        ;;
esac
