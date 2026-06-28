// Configuring the VM

import Virtualization

var configuration = VZVirtualMachineConfiguration()
configuration.cpuCount = 4
configuration.memorySize = (4 * 1024 * 1024 * 1024) as UInt64
