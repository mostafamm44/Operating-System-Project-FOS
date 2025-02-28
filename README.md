# FOS Project 2024 (Operating System Development)

This project is an **educational Operating System** built on top of FOS, implementing various **memory management, process scheduling, and system call mechanisms**.

## 🚀 Features Implemented

### **Milestone 1: Process Management & Memory Allocation**
- **Process Management:**
  - Implemented `process_command`
  - Created multiple system calls with parameter validation

- **Dynamic Allocator (User Heap & Kernel Heap):**
  - `sys_sbrk()`, `malloc (FIRST FIT)`, `allocate_user_mem()`
  - `free`, `free_user_mem()`, optimized `O(1) free_user_mem`

- **Shared Memory Management:**
  - `smalloc()`, `sget()`, `sfree()`
  - `createSharedObject()`, `freeSharedObject()`, `free_share()`

- **Fault Handling & Page Allocation:**
  - Implemented `Page_fault_handler`
  - Kernel dynamic allocation for processes
  - **Memory Allocation Algorithms:**
    - `alloc_block_FF`, `alloc_block_BF`
    - `free_block`, `realloc_block_FF`, `test_realloc_block_FF`

- **Sleep Locking Mechanism:**
  - `sleep()`, `wakeup one`, `wakeup all`
  - `acquire()`, `release()`

---

### **Milestone 2: Kernel Memory Management & Fast Page Allocation**
- **Memory Management (Kernel Heap):**
  - `sbrk()`, `kmalloc (FIRST FIT)`, `kfree()`
  - `kheap_virtual_address()`, `kheap_physical_address()`
  - Implemented `krealloc()`

- **Fast Page Allocator:**
  - Optimized page allocation for better performance

---

### **Milestone 3: Page Replacement, Semaphore, and Scheduling**
- **Fault Handling - Page Replacement Algorithm:**
  - Implemented **Nth Chance Clock Replacement** (Normal & Modified)

- **User-Level Semaphore Implementation:**
  - `CreateSemaphore()`, `GetSemaphore()`
  - `WaitSemaphore()`, `SignalSemaphore()`

---

## 🔧 Build & Run Instructions

### **1️⃣ Clone the Repository**
```bash
git clone https://github.com/mostafamm44/os-.git
cd os-
