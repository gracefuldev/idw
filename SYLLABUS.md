# Investigative Debugging Workshop Syllabus

## High-Level Points

- I'm not an expert in this stuff. I just know about some useful tools. Let's   explore them together!
- **Stop guessing, start investigating!**
- Scope:
  - I want you to go away knowing that these tools exist and what kinds of 
    information you can get from them. We won't cover setup or go in depth on any of them.
  - This is about **“Surveillance Tools”**: tools that enable you to get an exhaustive view of how a program is interacting with its world, and to some degree what paths it is going down internally. 
  - There’s a lot of overlap with **tracing tools**. But we’re going to be mostly ignoring the performance optimization aspects of tracing, and we’re also going to be looking at some tools outside the tracing space.
  - This is about the gray area between *debugging* and *understanding*. Tools and techniques that are useful for building understanding of what’s actually going on in your own code, the libraries you use, and the tools you rely on.
  - These tools aren't applicable to all debugging scenarios: they may not help you understand some convoluted app logic.
  - This is *not* about understanding the OS kernel. We’re going to stick to userspace.
  - I’m going to be using some Ruby examples for examining what’s going on in a high-level language. But the focus is on language-agnostic tools
- The problem: making hypotheses about what’s happening.
- Source code is great for pointers, but lousy for truth. There are 101 ways to get the wrong idea from reading source.
- Googling it should always be your first tactic. But beware of assuming that what is happening on someone else’s machine is also what’s happening on your machine.
- Every program is playing a game. Making hypotheses about why something is happening is accepting the game.
- You don’t have to accept the game: you can jump out a level and find facts.
- This is *your* machine. It has no secrets from you. Your code does not have Miranda rights.
  - If the program isn’t on your machine, either find a way to run it on a machine you own, or to elevate your privileges.
- **Stop guessing, start investigating!**
- Tools like `strace`, `dtrace`, etc. aren’t just for kernel developers and datacenter operators. They are for you, and they can give you superpowers.
- Start broader than you think you need to, and use *what is actually there* to guide how you narrow your focus. **Don’t be clever with your initial queries**!
- Tracing isn’t just for debugging, it doesn’t always require modifying (or even stopping) a program, and it doesn’t always slow the program down.
- **Stop guessing, start investigating!**
- Some of these techniques have a *significant* ramp-up. Both in terms of learning, and of making them work in your environment. If you can knock down that initial friction, they move from the realm of the “theoretically possible” to the realm of the practical.

## The Concepts

- Isolation with Docker
- Tracing
- Static vs. Dynamic tracing
- Kernel vs Userspace tracing
- realtime vs non-realtime tracing 
- internal vs external tracing in high-level languages
- Dtrace
- dtrace/usdt tracepoints
- Enhanced Berkely Packet Filter (BPF)
- BPF Compiler Collection (BCC) 
- Intercepting proxies

## The Tools

- “What is using my port? What files is this program using?”: `lsof`
- “What files does this program write to?”: `docker diff`, `strace`, `opensnoop` from BCC
- “What system calls does this program make?”: `strace`
- “What env vars does this program use?”: `ltrace`
- “What processes does this program start?”: `execsnoop` from BCC
- “What methods are (or aren’t) called in my program?”: `ucalls`, `uflow`,  `bpftrace`
- “How does this program talk to external services?”: `mitmproxy`, various BCC tools, Postman, `wireshark`.
- "Tell me more about this binary": `readelf`, `strings`, `ldd`

## Rough outline for session #1

- Brief intros
- A little about surveillance tools
- A bit about scope
- `lsof`
- `docker diff`
- `strace` for file access
- `strace` for env var access
- BCC tools TCP snooping, etc...
- `mitmproxy` for HTTP connections
- `bpftrace`, time permitting