# Explore available predefined kernel tracepoints

```bash
$ ls /sys/kernel/debug/tracing/events/       
9p          cpuhp       fs_dax        irq          mpx     oom           rcu     sunrpc    vsyscall
alarmtimer  devlink     fscache       irq_matrix   msr     pagemap       rseq    swiotlb   workqueue
block       enable      ftrace        irq_vectors  napi    percpu        rtc     syscalls  writeback
bridge      exceptions  header_event  jbd2         net     power         sched   task      x86_fpu
btrfs       ext4        header_page   kmem         netvsc  printk        scsi    tcp       xdp
cgroup      fib         huge_memory   kvm          nfs     qdisc         sctp    timer     xfs
cifs        fib6        hyperv        kvmmmu       nfs4    random        signal  tlb       xfs_scrub
clk         filelock    initcall      migrate      nfsd    ras           skb     udp
compaction  filemap     iommu         module       nmi     raw_syscalls  sock    vmscan
```

# Look for tracepoints related to a keyword

```bash
$ cd /sys/kernel/debug/tracing/events/
$ find . -name '*proc*'
./sunrpc/svc_process
./sched/sched_process_free
./sched/sched_process_exit
./sched/sched_process_wait
./sched/sched_process_fork
./sched/sched_process_exec
./syscalls/sys_enter_process_vm_readv
./syscalls/sys_exit_process_vm_readv
./syscalls/sys_enter_process_vm_writev
./syscalls/sys_exit_process_vm_writev
./syscalls/sys_enter_rt_sigprocmask
./syscalls/sys_exit_rt_sigprocmask
```

# What kprobes are available related to a keyword?

```
bpftrace -l kprobe:*execve*
kprobe:__do_execve_file.isra.40
kprobe:__ia32_compat_sys_execve
kprobe:__ia32_compat_sys_execveat
kprobe:__ia32_sys_execve
kprobe:__ia32_sys_execveat
kprobe:__x32_compat_sys_execve
kprobe:__x64_sys_execve
kprobe:__x64_sys_execveat
kprobe:__x32_compat_sys_execveat
kprobe:do_execve_file
kprobe:do_execve
kprobe:do_execveat
```



# Get documentation for a specific kernel syscall tracepoint

```bash
$ cat /sys/kernel/debug/tracing/events/syscalls/sys_enter_openat/format 
name: sys_enter_openat
ID: 631
format:
        field:unsigned short common_type;       offset:0;       size:2; signed:0;
        field:unsigned char common_flags;       offset:2;       size:1; signed:0;
        field:unsigned char common_preempt_count;       offset:3;       size:1; signed:0;
        field:int common_pid;   offset:4;       size:4; signed:1;

        field:int __syscall_nr; offset:8;       size:4; signed:1;
        field:int dfd;  offset:16;      size:8; signed:0;
        field:const char * filename;    offset:24;      size:8; signed:0;
        field:int flags;        offset:32;      size:8; signed:0;
        field:umode_t mode;     offset:40;      size:8; signed:0;

print fmt: "dfd: 0x%08lx, filename: 0x%08lx, flags: 0x%08lx, mode: 0x%08lx", ((unsigned long)(REC->dfd)), ((unsigned long)(REC->filename)), ((unsigned long)(REC->flags)), ((unsigned long)(REC->mode))
```

Notice that syscall tracepoints have the convention `syscalls/sys_enter_*` and `syscalls/sys_exit_*`.

# Does this command write to /tmp?

Specifically, does it open files for writing?

```bash
bpftrace --include fcntl.h -e 'tracepoint:syscalls:sys_enter_openat,tracepoint:syscalls:sys_enter_open /(args->flags & (O_RDWR | O_WRONLY)) && (strncmp("/tmp", str(args->filename), 4) == 0)/ { @files[str(args->filename)] = count() }' -c 'sh ./blurp.sh'
```

Note that this requires libc6-dev-i386 installed, for header files included by `fcntl.h`.

# What commands are writing to /tmp?

```bash
$ bpftrace --include fcntl.h -e \
  'tracepoint:syscalls:sys_enter_openat,tracepoint:syscalls:sys_enter_open \
   /(args->flags & (O_RDWR | O_WRONLY)) && \
    (strncmp("/tmp", str(args->filename), 4) == 0)/ \
    { printf("%s: opened by %s (%d)\n", str(args->filename), comm, pid) }' 
Attaching 2 probes...
/tmp/blurp23888.tmp: opened by blurp.sh (2297)
```

TODO: Figure out why the `pid` variable disagrees with what the target script thinks is its PID. 

# What processes does this command start?

## Using kernel tracepoints:

```bash
bpftrace -e 'tracepoint:syscalls:sys_enter_execve, tracepoint:syscalls:sys_enter_execveat { printf("%s: %s exec: %s\n", probe, comm, str(args->filename)); join(args->argv); }' -c 'sh ./blurp.sh'
```

## Using kprobes:



## Using uprobes:

```bash
bpftrace -e 'uprobe:/lib/x86_64-linux-gnu/libc.so.6:execve { printf("command %s executed by %s (%d)\n", str(arg0), comm, pid); }' -c 'sh ./blurp.sh'
```

