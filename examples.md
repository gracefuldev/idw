# Does this command write to /tmp?

Specifically, does it open files for writing?

```bash
bpftrace --include fcntl.h -e 'tracepoint:syscalls:sys_enter_openat,tracepoint:syscalls:sys_enter_open /(args->flags & (O_APPEND | O_CREAT)) && (strncmp("/tmp", str(args->filename), 4) == 0)/ { @files[str(args->filename)] = count() }' -c 'sh ./blurp.sh'
```

Note that this requires libc6-dev-i386 installed, for header files included by `fcntl.h`.

# What commands are writing to /tmp?

```bash
$ bpftrace --include fcntl.h -e \
  'tracepoint:syscalls:sys_enter_openat,tracepoint:syscalls:sys_enter_open \
   /(args->flags & (O_APPEND | O_CREAT)) && \
    (strncmp("/tmp", str(args->filename), 4) == 0)/ \
    { printf("%s: opened by %s (%d)\n", str(args->filename), comm, pid) }' 
Attaching 2 probes...
/tmp/blurp23888.tmp: opened by blurp.sh (2297)
```

TODO: Figure out why the `pid` variable disagrees with what the target script thinks is its PID. 