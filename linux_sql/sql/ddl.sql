-- ddl.sql

-- Switch to host_agent DB
\c host_agent;

-- Create host_info table if not exists
CREATE TABLE IF NOT EXISTS public.host_info
(
    id               SERIAL NOT NULL,
    hostname         VARCHAR NOT NULL,
    cpu_number       SMALLINT NOT NULL,
    cpu_architecture VARCHAR NOT NULL,
    cpu_model        VARCHAR NOT NULL,
    cpu_mhz          DOUBLE PRECISION NOT NULL,
    l2_cache         INTEGER NOT NULL,
    total_mem        INTEGER NOT NULL,
    "timestamp"      TIMESTAMP NOT NULL,
    CONSTRAINT host_info_pk PRIMARY KEY (id),
    CONSTRAINT host_info_un UNIQUE (hostname)
);

-- Create host_usage table if not exists
CREATE TABLE IF NOT EXISTS public.host_usage
(
    "timestamp"    TIMESTAMP NOT NULL,
    host_id        INTEGER NOT NULL,
    memory_free    INTEGER NOT NULL,
    cpu_idle       INTEGER NOT NULL,
    cpu_kernel     INTEGER NOT NULL,
    disk_io        INTEGER NOT NULL,
    disk_available INTEGER NOT NULL,
    CONSTRAINT host_usage_host_info_fk
        FOREIGN KEY (host_id) REFERENCES host_info(id)
);
