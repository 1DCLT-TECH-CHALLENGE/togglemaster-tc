# Fase 2 - BLOCO 17.5 - Diagnóstico de serviços ausentes

Data: Fri May 22 12:14:16 PM -03 2026

## Objetivo
Diagnosticar por que auth-service e evaluation-service não aparecem como Up após o BLOCO 16.

NAME                          IMAGE                         COMMAND                  SERVICE              CREATED         STATUS                    PORTS
docker-analytics-service-1    docker-analytics-service      "gunicorn --bind 0.0…"   analytics-service    2 minutes ago   Up 2 minutes              0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-flag-service-1         docker-flag-service           "gunicorn --bind 0.0…"   flag-service         2 minutes ago   Up 2 minutes              0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-localstack-1           localstack/localstack:3.8.1   "docker-entrypoint.sh"   localstack           15 hours ago    Up 11 minutes (healthy)   4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp
docker-postgres-auth-1        postgres:13                   "docker-entrypoint.s…"   postgres-auth        2 minutes ago   Up 2 minutes              0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-postgres-flags-1       postgres:13                   "docker-entrypoint.s…"   postgres-flags       2 minutes ago   Up 2 minutes              0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-targeting-1   postgres:13                   "docker-entrypoint.s…"   postgres-targeting   2 minutes ago   Up 2 minutes              0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-redis-1                redis:7-alpine                "docker-entrypoint.s…"   redis                2 minutes ago   Up 2 minutes              0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-targeting-service-1    docker-targeting-service      "gunicorn --bind 0.0…"   targeting-service    2 minutes ago   Up 2 minutes              0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp
NAME                          IMAGE                         COMMAND                  SERVICE              CREATED         STATUS                          PORTS
docker-analytics-service-1    docker-analytics-service      "gunicorn --bind 0.0…"   analytics-service    2 minutes ago   Up 2 minutes                    0.0.0.0:8005->8000/tcp, [::]:8005->8000/tcp
docker-auth-service-1         docker-auth-service           "/app/service"           auth-service         2 minutes ago   Exited (1) 2 minutes ago        
docker-evaluation-service-1   docker-evaluation-service     "/app/service"           evaluation-service   2 minutes ago   Exited (1) 2 minutes ago        
docker-flag-service-1         docker-flag-service           "gunicorn --bind 0.0…"   flag-service         2 minutes ago   Up 2 minutes                    0.0.0.0:8002->8000/tcp, [::]:8002->8000/tcp
docker-localstack-1           localstack/localstack:3.8.1   "docker-entrypoint.sh"   localstack           15 hours ago    Up 11 minutes (healthy)         4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp, [::]:4566->4566/tcp
docker-localstack-init-1      amazon/aws-cli:2.15.7         "/bin/sh -c ' sleep …"   localstack-init      2 minutes ago   Exited (0) About a minute ago   
docker-postgres-auth-1        postgres:13                   "docker-entrypoint.s…"   postgres-auth        2 minutes ago   Up 2 minutes                    0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp
docker-postgres-flags-1       postgres:13                   "docker-entrypoint.s…"   postgres-flags       2 minutes ago   Up 2 minutes                    0.0.0.0:5434->5432/tcp, [::]:5434->5432/tcp
docker-postgres-targeting-1   postgres:13                   "docker-entrypoint.s…"   postgres-targeting   2 minutes ago   Up 2 minutes                    0.0.0.0:5435->5432/tcp, [::]:5435->5432/tcp
docker-redis-1                redis:7-alpine                "docker-entrypoint.s…"   redis                2 minutes ago   Up 2 minutes                    0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
docker-targeting-service-1    docker-targeting-service      "gunicorn --bind 0.0…"   targeting-service    2 minutes ago   Up 2 minutes                    0.0.0.0:8003->8000/tcp, [::]:8003->8000/tcp
auth-service-1  | 2026/05/22 15:12:12 Não foi possível conectar ao banco de dados: failed to connect to `host=postgres-auth user=auth_user database=auth_db`: dial error (dial tcp 172.18.0.7:5432: connect: connection refused)
evaluation-service-1  | 2026/05/22 15:12:13 Não foi possível conectar ao Redis: dial tcp [::1]:6379: connect: connection refused
postgres-auth-1  | The files belonging to this database system will be owned by user "postgres".
postgres-auth-1  | This user must also own the server process.
postgres-auth-1  | 
postgres-auth-1  | The database cluster will be initialized with locale "en_US.utf8".
postgres-auth-1  | The default database encoding has accordingly been set to "UTF8".
postgres-auth-1  | The default text search configuration will be set to "english".
postgres-auth-1  | 
postgres-auth-1  | Data page checksums are disabled.
postgres-auth-1  | 
postgres-auth-1  | fixing permissions on existing directory /var/lib/postgresql/data ... ok
postgres-auth-1  | creating subdirectories ... ok
postgres-auth-1  | selecting dynamic shared memory implementation ... posix
postgres-auth-1  | selecting default max_connections ... 100
postgres-auth-1  | selecting default shared_buffers ... 128MB
postgres-auth-1  | selecting default time zone ... Etc/UTC
postgres-auth-1  | creating configuration files ... ok
postgres-auth-1  | running bootstrap script ... ok
postgres-auth-1  | performing post-bootstrap initialization ... ok
postgres-auth-1  | syncing data to disk ... ok
postgres-auth-1  | 
postgres-auth-1  | 
postgres-auth-1  | Success. You can now start the database server using:
postgres-auth-1  | 
postgres-auth-1  |     pg_ctl -D /var/lib/postgresql/data -l logfile start
postgres-auth-1  | 
postgres-auth-1  | initdb: warning: enabling "trust" authentication for local connections
postgres-auth-1  | You can change this by editing pg_hba.conf or using the option -A, or
postgres-auth-1  | --auth-local and --auth-host, the next time you run initdb.
postgres-auth-1  | waiting for server to start....2026-05-22 15:12:14.437 UTC [48] LOG:  starting PostgreSQL 13.23 (Debian 13.23-1.pgdg13+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
postgres-auth-1  | 2026-05-22 15:12:14.438 UTC [48] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgres-auth-1  | 2026-05-22 15:12:14.441 UTC [49] LOG:  database system was shut down at 2026-05-22 15:12:14 UTC
postgres-auth-1  | 2026-05-22 15:12:14.450 UTC [48] LOG:  database system is ready to accept connections
postgres-auth-1  |  done
postgres-auth-1  | server started
postgres-auth-1  | CREATE DATABASE
postgres-auth-1  | 
postgres-auth-1  | 
postgres-auth-1  | /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql
postgres-auth-1  | CREATE TABLE
postgres-auth-1  | 
postgres-auth-1  | 
postgres-auth-1  | 2026-05-22 15:12:14.871 UTC [48] LOG:  received fast shutdown request
postgres-auth-1  | waiting for server to shut down....2026-05-22 15:12:14.871 UTC [48] LOG:  aborting any active transactions
postgres-auth-1  | 2026-05-22 15:12:14.883 UTC [48] LOG:  background worker "logical replication launcher" (PID 55) exited with exit code 1
postgres-auth-1  | 2026-05-22 15:12:14.883 UTC [50] LOG:  shutting down
postgres-auth-1  | 2026-05-22 15:12:14.898 UTC [48] LOG:  database system is shut down
postgres-auth-1  |  done
postgres-auth-1  | server stopped
postgres-auth-1  | 
postgres-auth-1  | PostgreSQL init process complete; ready for start up.
postgres-auth-1  | 
postgres-auth-1  | 2026-05-22 15:12:15.039 UTC [1] LOG:  starting PostgreSQL 13.23 (Debian 13.23-1.pgdg13+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
postgres-auth-1  | 2026-05-22 15:12:15.039 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
postgres-auth-1  | 2026-05-22 15:12:15.039 UTC [1] LOG:  listening on IPv6 address "::", port 5432
postgres-auth-1  | 2026-05-22 15:12:15.040 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgres-auth-1  | 2026-05-22 15:12:15.041 UTC [65] LOG:  database system was shut down at 2026-05-22 15:12:14 UTC
postgres-auth-1  | 2026-05-22 15:12:15.055 UTC [1] LOG:  database system is ready to accept connections
redis-1          | 1:C 22 May 2026 15:12:12.458 # WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. Being disabled, it can also cause failures without low memory condition, see https://github.com/jemalloc/jemalloc/issues/1328. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
redis-1          | 1:C 22 May 2026 15:12:12.458 * oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
redis-1          | 1:C 22 May 2026 15:12:12.458 * Redis version=7.4.9, bits=64, commit=00000000, modified=0, pid=1, just started
redis-1          | 1:C 22 May 2026 15:12:12.458 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
redis-1          | 1:M 22 May 2026 15:12:12.458 * Increased maximum number of open files to 10032 (it was originally set to 1024).
redis-1          | 1:M 22 May 2026 15:12:12.458 * monotonic clock: POSIX clock_gettime
redis-1          | 1:M 22 May 2026 15:12:12.459 * Running mode=standalone, port=6379.
redis-1          | 1:M 22 May 2026 15:12:12.460 * Server initialized
redis-1          | 1:M 22 May 2026 15:12:12.460 * Ready to accept connections tcp

### docker-auth-service-1 ###
Name=/docker-auth-service-1 Status=exited ExitCode=1 Error= StartedAt=2026-05-22T15:12:12.50400355Z FinishedAt=2026-05-22T15:12:12.832370022Z

### docker-evaluation-service-1 ###
Name=/docker-evaluation-service-1 Status=exited ExitCode=1 Error= StartedAt=2026-05-22T15:12:13.34984351Z FinishedAt=2026-05-22T15:12:13.799152659Z
