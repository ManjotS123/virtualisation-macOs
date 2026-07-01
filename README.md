### Virtual Machine

Headless Linux VM via Apple Virtualization.framework

https://developer.apple.com/documentation/virtualization?language=objc

### Requirements

- Swift
- MacOs v11
- Linux kernel and RAM disk image

### Configurations

- `main.swift` - Creates the VM and includes the related configurations
- `build.sh` - Builds and signs the package
- `vm.plist` - Includes the entitlement that gets signed

### How to run the VM

- Create a directory in project root to supply Linux kernel and RAM disk image

`mkdir boot`

- Navigate to the boot directory and download the image files from the URLs

```
curl -O <kernel image>
curl -O <ram-disk image> 
```

- Go back to the project root, build and sign the package and the entitlement

`bash build.sh`

- Run the VM

`bash run-vm.sh`

### Notes

- If the entitlement needs to be resigned, add the `-f` flag to the bash script
- Bash scripts can be set as executables with `chmod +x <script.sh>` cmdlet