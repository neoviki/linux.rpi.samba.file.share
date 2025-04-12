### **`linux.rpi.samba.file.share`**  
**Utility to Share a Directory Over the Network Using Samba Protocol**

This utility allows you to share a local directory over the network using **Samba**, a protocol that enables file and printer sharing between Linux/Unix and Windows systems. Samba implements the SMB (Server Message Block) and CIFS (Common Internet File System) protocols, allowing seamless file access and sharing across different platforms. With this utility, you can easily share a directory from your Linux system with other systems (Windows, macOS, or Linux) over the network.

---

## **Install**

To install, clone this repository and execute the following commands:

```bash
chmod +x install.sh
./install.sh
```

---

## **Usage**

To share a directory over the network, use the following command:

```bash
net.share.directory <directory_path>
```

### **Example:**

```bash
net.share.directory /share
```

---

## **Tested On**

- Raspberry Pi 2 (Raspbian / Raspberry Pi OS)

